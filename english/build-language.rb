require 'fileutils'
require 'yaml'
require 'json'

OUT_DIR = 'build'
FileUtils.mkdir_p(OUT_DIR)

DIC = ARGV[0] || 'sowpods+12d.txt'

language = YAML.load_file('manual-data.yml')

language[:dictionary] = DIC

File.write File.join(OUT_DIR, 'index.json'), JSON.pretty_generate(language)
