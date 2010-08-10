require 'rubygems'
require 'nokogiri'

# The library for this code
require 'dependencyformat'

# Make sure we have a file
source_file_name = ARGV[0] or raise "Filename argument required"
raise "File was not found" unless (File.exists? source_file_name)

# Create a set for GAVNodes
gavlines = DependencyFormat::GAVNodeSet.new;


# Load the nodes into the set
doc = Nokogiri::XML(open(ARGV[0]))
ns = doc.search("dependency")

ns.each do |dep|
  gavlines << (DependencyFormat::GAVNode.new(dep))
end

gavlines.prepare_nodeset
puts gavlines