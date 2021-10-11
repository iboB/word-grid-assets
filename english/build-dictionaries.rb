require 'fileutils'
require 'set'

OUT_DIR = 'build'
FileUtils.mkdir_p(OUT_DIR)

# Common filter for 12 dicts
# * Short words < 3
# * Long words > 20
# * Phrases and phrasal verbs (with space)
# * Caps different than plain capitalization (proper names)
# * Short forms and abbreviations (contain '.')
# * Options which contain '/'
def common_filter(word)
  return true if word.length < 3 # short
  return true if word.length > 20 # long
  return true if word.include? ' ' # has spaces
  return true if word.include? '.' # has dots
  return true if word.include? '/' # option
  return true if word =~ /.+[A-Z]/ # has non-plain caps
  false
end

###
# Load and map words to inflections from 2+2+3lem
# suffix ! means neologism - keep
# x -> [word] means a crossref, just elliminate '-> [word]' we don't care about the crossref

all_inflections = {}

puts 'Parsing 2+2+3lem'

total_223 = 0

prev_word_inflections = nil
File.foreach('2+2+3lem.txt') do |line|
  line.rstrip!
  if line.start_with?(' ')
    line.strip!
    line.split(', ').each do |s|
      pos = s =~ / -> /
      prev_word_inflections << (pos ? s[0...pos] : s).chomp('!')
    end
    total_223 += prev_word_inflections.length
  else
    all_inflections[line.chomp('!')] = prev_word_inflections = []
  end
end

puts "\tParsed #{total_223 + all_inflections.length} entries in #{all_inflections.length} keys"

###
# Load common words from 2+2+3frq from 1 to 16
# We don't care about inflections from here, so just skip lines with them
# Also look for suffix:
# suffix * - crossref, keep
# word in parens - special addition, keep

puts 'Parsing 2+2+3frq'

common_words = Set.new

File.foreach('2+2+3frq.txt') do |line|
  if line =~ /- (\d+) -/
    # frequency level
    break if $1.to_i > 16
    next # skip
  end

  line.rstrip!
  next if line.start_with?(' ') # ignore inflections
  line.chomp!('*')

  if line =~ /\((.*)\)/
    # word in parens - doesn't have inflections
    # just add
    common_words << $1 if !common_filter $1
  else
    common_words << line if !common_filter(line)
    # add inflections
    inflections = all_inflections[line]
    next if !inflections

    inflections.each do |i|
      common_words << i if !common_filter(i)
    end

    # delete common words from all_inflections
    # they are already added to common and what remains will be for uncommon
    all_inflections.delete line
  end
end

puts "\tBuilt #{common_words.length} common words"

###
# Load 3of6all and filter out common filer
#
# Also check special suffixes
# ^ - rare variants - keep
# ; - phrasal verbs - remove but don't take special care about ; as phrasal verbs have a space anyway
# & - British spelling - keep
# $ - Rare forms - remove
# : - abbreviation - remove
# > - only in specific phrases - keep
# + - signature phrase - remove but again, those contain spaces, so they will be fixed earlier
#
# Also if a word appears twice with a capitalized and a non-capitalized form, the non-capitalized wins
# as it's likely to be more common
# Here make use of the fact in such a case in 3of6all the capitalized word immediately follows the
# non-capitalized one
#
# Also check if a word starts or end with '-'
# Skip it if does, but collect it in prefix-suffix-ideas as a special

uncommon_words = Set.new

puts 'Filtering 3of6all'

pref_suf_ideas = File.open(File.join(OUT_DIR, 'prefix-suffix-ideas.txt'), 'w')

prev_word = nil
File.foreach('3of6all.txt') do |line|
  line.strip!
  next if common_filter(line)

  next if line.downcase == prev_word # capitalized copy of prev

  if line.start_with?('-') || line.end_with?('-')
    pref_suf_ideas.puts line
    next
  end

  pos = line =~ /[\^\;\&\$\:\>\+]+$/

  # suffix
  if pos
    suffix = line[pos..]
    next if suffix.include? ';' # phrasal verb
    next if suffix.include? '$' # rare
    next if suffix.include? ':' # abbreviation
    next if suffix.include? '+' # signature phrase
    line = line[0...pos]
  end

  uncommon_words << line
  prev_word = line
end

puts "\tKept #{uncommon_words.length} words"

### Remove common words from all we just loaded and filtered

puts 'Removing common from all'
uncommon_words -= common_words
puts "\t#{uncommon_words.length} uncommon words remaining"


