# one-shot script to extract the common contractions from 2+2+3cmn
cc = []
File.foreach('2+2+3cmn.txt') do |line|
  line.strip!.split(', ').each do |word|
    cc << word if word.chomp!('+')
  end
end

File.write('common-contractions.txt', cc.join("\n"))
