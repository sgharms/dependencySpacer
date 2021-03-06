require 'test/unit'
require 'rubygems'
require 'dependencyformat'
require 'nokogiri'
require 'open-uri'
require 'dependencyformat'

class TestGAVNode < Test::Unit::TestCase
  @@fixture      = 'tests/fixtures/test.xml'
  @@doc          = Nokogiri::XML(open(@@fixture))
  @@ns           = @@doc.search("dependency")
  @@basic_string = "<dependency><groupId>axis                      </groupId><artifactId>axis                             </artifactId><version>1.4         </version></dependency>"
  @@longer_string = "<dependency><groupId>axis                      </groupId><artifactId>axis                             </artifactId><version>1.4         </version><scope>test</scope></dependency>"
  def setup
  end
  def teardown
  end
  
  def testInitializer
    assert_raise RuntimeError do
      DependencyFormat::GAVNode.new(3)
    end
    assert_raise RuntimeError do
      DependencyFormat::GAVNode.new("hobo")
    end    
    assert_nothing_raised  do
      DependencyFormat::GAVNode.new(@@basic_string)
    end    
  end
  
  def testGAVNodeElementAwareness
    gn = DependencyFormat::GAVNode.new(@@basic_string)
    assert_equal(3,gn.element_count,"Expected number of fields for @@basic_string is 3")
    assert_equal(4,
      DependencyFormat::GAVNode.new(@@longer_string).element_count,
      "Expected number of fields for @@basic_string is 3")
  end
  
  def testBaselineString
    gn = DependencyFormat::GAVNode.new(@@basic_string)
    assert_equal('axis', gn.groupId)
    assert_equal('1.4',  gn.version)
    assert_equal('axis', gn.artifactId)
  end

  def testLongString
    gn = DependencyFormat::GAVNode.new(@@longer_string)
    assert_equal('axis', gn.groupId)
    assert_equal('1.4',  gn.version)
    assert_equal('axis', gn.artifactId)
    assert_equal('test', gn.scope)
  end
  
  def testAComment
    gn = DependencyFormat::GAVNode.new("<!-- This is an XML comment -->")
    assert(gn.is_comment)
    assert_equal('<!-- This is an XML comment -->',gn.to_s)
  end
end