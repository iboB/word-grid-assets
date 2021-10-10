# check whether the current alphabet + conversion are adequate for a dictionary
require 'yaml'

MANUAL_DATA = YAML.load_file 'manual-data.yml'

AB = MANUAL_DATA["alphabet"]
CVT = MANUAL_DATA["conversion"]

DICTIONARY = ARGV[0] || 'diactrics.txt'

File.foreach(DICTIONARY) do |line|
  # note that we don't use downcase! so as to display the correct string in the log
  line.strip!.downcase.split('').each do |c|
    # c from line is neither a character nor converted
    puts "'#{line}' : '#{c}'" if !AB[c] && !CVT[c]
  end
end
