require 'test/unit'
require 'rubygems'
require 'dependencyformat'
require 'nokogiri'
require 'open-uri'
require 'dependencyformat'
require 'pp'

class TestGAVNodeSet < Test::Unit::TestCase
  @@fixture      = 'tests/fixtures/test.xml'
  @@doc          = Nokogiri::XML(open(@@fixture))
  @@ns           = @@doc.search("dependency")
  @@basic_string = "<dependency><groupId>axis                      </groupId><artifactId>axis                             </artifactId><version>1.4         </version></dependency>"
  @@longer_string = "<dependency><groupId>axis                      </groupId><artifactId>axis                             </artifactId><version>1.4         </version><scope>test</scope></dependency>"

  def setup
  end
  def teardown
  end
  
  def testCompare
    gn1 = DependencyFormat::GAVNode.new(@@basic_string)
    gn2 = DependencyFormat::GAVNode.new(@@longer_string)
  
    themin = [gn1,gn2].min
    themax = [gn1,gn2].max
  
    assert_equal(themin.element_count,gn1.element_count)
    assert_equal(themax.element_count,gn2.element_count)
  end
  
  def testNSFromFile
    gavlines = DependencyFormat::GAVNodeSet.new;

    @@ns.each do |dep|
      gavlines << (DependencyFormat::GAVNode.new(dep))
    end
    
    gavlines.prepare_nodeset
    puts gavlines
  end
  
end