require 'dependencyformat'
require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'pp'

source_file_name = ARGV[0] or raise "Filename argument required"
raise "File was not found" unless (File.exists? source_file_name)

doc = Nokogiri::XML(open(ARGV[0]))

# Get an array of <dependency> lines
deps_array = doc.search("dependency")

# ...and load each of dependency into an array of GAVLine objects, initialized
# by that <dependency> line
gavlines = DependencyFormat::GAVNodeSet.new;




exit
deps_array.each do |dep|
  gavlines << (GAVNode.new(dep.search("groupId"), 
                           dep.search("artifactId"),
                           dep.search("version")))
end
