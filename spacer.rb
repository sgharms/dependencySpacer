require 'dependencyformat'
require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'pp'

source_file_name = ARGV[0] or raise "Filename argument required"
raise "File was not found" unless (File.exists? source_file_name)



