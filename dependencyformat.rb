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
  include Enumerable
  
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
                :element_count, :fields

  def initialize(ns)
    # An array of children is passed in, typically a
    # a Nokogiri::XML::NodeSet, or a string (typically for testing)
    raise_message = 'GAVNode::initialize() takes either a Nokogiri::XML::Element or a String'
    s = class << self; self end 
    
    # Basic runtime checks
    raise raise_message if ns.nil?
    unless ( ns.class.to_s =~ /(String|Nokogiri::XML::Element)$/)
      raise RuntimeError, raise_message
    end
    if (ns.class.to_s == 'String' && ns !~ /[<>]/)
      raise "You passed a string without any angle brackets, probably not XML"
    end

    # Past basic argument checks
    if ns.class.to_s =~ /Element$/
      ns = ns.to_s.gsub(/\s+/,'')
    end
    
    # Build this into a nokogiri object
    if ns.class.to_s == 'String'
      # Handle comments
      if ns =~ /^<!--/
        @is_comment = true
        @comment = ns
        s.send(:define_method, 'is_comment') do
          return true
        end
        return
      end
      ns = Nokogiri::XML(ns).search("dependency").children
    end
    


    # We assume we now have an XML-ish branch on which to operate
    @element_count = ns.length
    @fields = []
  
    ns.entries.each do |e|
      # Set each name to an iVar
      name = e.name.to_s.strip
      content = e.content.strip
      
      @fields << name
      
      instance_variable_set("@#{e.name}", content)
      instance_variable_set("@#{e.name}_length", content.length)

      # Get Jiggy with some metaprogramming
      s.send(:define_method,name) do
        return self.instance_variable_get("@"+name)
      end

    end

    s.send(:define_method, :max) do
      return [@groupid_length, @artifactid_length, @version_length].max
    end

    def <=>(obj)
      @element_count <=> obj.element_count
    end
  end

  def to_s
    return @is_comment ? @comment :
      sprintf("%s has [G:%s][A:%s][V:%s]\n", "#{self.class}[#{self.object_id}]", groupId, artifactId, version);
  end
end

class GAVNodeSet
  include Enumerable

  #TODO break out , :groupid_max, :artifactid_max, :version_max, :pom_lines into fields from the longest node search
  # then get the longest length for each field, must be more meta
  
  attr_accessor :nodes, :pom_dependency_lines

  def initialize
    @nodes = []
    @longest_val_table = {}
    @pom_dependency_lines = []
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

  def max_fields_object
    @max_fields = @nodes.max
  end
  
  def max_fields_count
    return @nodes.max.element_count
  end

  def get_longest_values
    @wanted_fields.each do |f|
      @longest_val_table[f.to_sym] = 
        @nodes.map{|n| n.send(f.to_sym).length}.max
    end
  end
  
  def prepare_nodeset
    @wanted_fields = max_fields_object.fields
    get_longest_values
    
    the_line = "  "
    @nodes.each do |n|
      @wanted_fields.each do |f|
       spacer = @longest_val_table[f.to_sym].to_i - n.send(f.to_sym).length      
      the_line += sprintf("<%s>%s%s</%s>", f, n.send(f.to_sym), " " * spacer,f)
      end
    the_line += "\n"
    the_line = "<dependency>#{the_line}</dependency>"
    @pom_dependency_lines << the_line
    end
  end
  
  def dependencies_stanza
    return sprintf("%s,%s,%s", "<dependencies>\n",@pom_dependency_lines.to_s,"</dependencies>")
  end

  def to_s
    return dependencies_stanza
  end
  
end
end