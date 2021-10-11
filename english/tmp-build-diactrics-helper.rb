# oneshot script to prepare the diactrics map for the builders
require 'yaml'

CVT = YAML.load_file('manual-data.yml')["conversion"]

map = {}
File.foreach('diactrics.txt') do |pretty|
  plain = pretty.strip!.downcase.split('').map { |c|
    next c if c == '-' || c == "'"
    CVT[c] || c
  }.join

  map[plain] = pretty

  # add capitalized entry if pretty is capitalized
  map[plain.capitalize] = pretty if pretty =~ /^[A-Z]/
end

File.write 'diactrics-map.yml', map.to_yaml
