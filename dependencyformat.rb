module DependencyFormat

=begin rdoc

=NAME spacer.rb

=DESCRIPTION

This is a script that takes the <dependencies></dependencies> stanza in a
Maven pom.xml and re formats the selection (provided it's written with
well-structured XML in the first place). The purpose here is not XML
validation, rather this serves as a baseline for a Textmate scriptlet.

The process takes the XML dependencies XPath, gets the <dependency> elements
and then matches each element line into a GAVNode (groupId, artifactId,
version) node. Like most *ML parsers, these entities are then aggregated into
a NodeSet object which is used for aggregation functions.

=Requirements

   * Nokogiri

=Author

Steven G. Harms

=Date

9 August 2010

=end

require 'pp'
require 'nokogiri'
require 'open-uri'

class GAVNode
  
=begin rdoc
=DESCRIPTION

The atomic node, initialized by passing in a G,A,V, likely derived from
an XML parsing function that has handled a branch of XML and returned
the <dependencies> branch.

=end

  # How wide is a tab?  In the context of the code I use spaces-as-tab, but
  # it's foreseeable someone could want to branch this and make use of Tabs
  # (evil!)

  TAB_WIDTH=4

  # an iVar for each GAV component
  attr_accessor :groupid, :artifactid, :version, :max,
                :groupid_length, :artifactid_length, :version_length,
                :element_count

  def initialize(ns)
    # An array of children is passed in, typically a
    # a Nokogiri::XML::NodeSet, or a string (typically for testing)
    raise_message = 'GAVNode::initialize() takes either a Nokogiri::XML::Nodeset or a String'
    raise raise_message if ns.nil?

    unless ( ns.class.to_s =~ /(String|Nokogiri::XML::Nodeset)$/)
      raise RuntimeError, raise_message
    end
    
    if (ns.class.to_s == 'String' && ns !~ /[<>]/)
      raise "You passed a string without any angle brackets, probably not XML"
    end

    # Build this into a nokogiri object
    if ns.class.to_s == 'String'
      ns =  Nokogiri::XML(ns).search("dependency").children
    end

    @element_count = ns.length
    
        # 
        # @groupid = g.first.to_s
        # @artifactid = a.first.to_s
        # @version = v.first.to_s
        # 
        # [@groupid, @artifactid, @version].each_with_index do |x,i| 
        #   # De-whitespace the iVars      
        #   x.gsub!(/[\s\t]+/,'')
        # 
        #   # Remove the tags.  Surely there's a better way to do this than by
        #   # gsub(), though.
        #   x.gsub!(/<[\/\w]+>/,'')      
        # end
        # 
        # @groupid_length     = @groupid.length
        # @artifactid_length  = @artifactid.length
        # @version_length     = @version.length    
        # 
        # @max = [@groupid_length, @artifactid_length, @version_length].max
  end

  def to_s
    return sprintf("%s has [%s]\n\t[%s]\n\t[%s]\n\n", "#{self.class}[#{self.object_id}]", @groupid, @artifactid, @version);
  end
end

class GAVNodeSet
  include Enumerable

  attr_accessor :nodes, :groupid_max, :artifactid_max, :version_max, :pom_lines

  def initialize
    @nodes = @pom_lines = []
    @groupid_max    = 0
    @artifactid_max = 0
    @version_max    = 0

  end

  def push(obj)
    @nodes.push(obj)
  end

  def <<(obj)
    @nodes.push(obj)
  end

  def each(&block)
    @nodes.each(&block)
  end

  def calculate_maxima
    @groupid_max    = (@nodes.map{|n|n.groupid_length}).max
    @artifactid_max = (@nodes.map{|n|n.artifactid_length}).max
    @version_max    = (@nodes.map{|n|n.version_length}).max    
  end

  def return_maxima
    [@groupid_max, @artifactid_max, @version_max]
  end

  def generate_pom_lines
    pom_lines = Array.new

    # Just say no to drugs, kids.  Don't do lines.
    @nodes.each do |line|
      begin
        theline = ""

        theline += "<dependency>"
        filler = self.groupid_max - line.groupid_length


        theline += sprintf("%s%s%s%s", "<groupId>", line.groupid, " " * filler, "</groupId>" )


        filler = @artifactid_max - line.artifactid_length
        theline += sprintf("%s%s%s%s", "<artifactId>", line.artifactid, " " * filler, "</artifactId>" )
        filler = version_max - line.version_length

        theline += sprintf("%s%s%s%s", "<version>", line.version, " " * filler, "</version>" )
        theline += "</dependency>\n"
        pom_lines.push("  " + theline)
      rescue Exception => e
        STDERR.puts("An error occurred: #{e}")
      end      
    end

    # Return the entries uniquely and sorted.
    @pom_lines = pom_lines.sort.uniq
  end

  def prepare_nodeset
    self.calculate_maxima
    self.generate_pom_lines
  end

  def to_s
    return sprintf("%s\n%s%s\n", "<dependencies>", @pom_lines.to_s, "</dependencies>")
  end
end
end