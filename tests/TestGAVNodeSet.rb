require 'test/unit'
require 'rubygems'
require 'dependencyformat'
require 'nokogiri'
require 'open-uri'
require 'dependencyformat'

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
  
  
  
end