desc "Run TestGAVNode unit tests in tests/ directory"
task :testgav do
  ruby 'tests/TestGAVNode.rb'
end

desc "Run TestGAVNodeSet unit tests in tests/ directory"
task :testset do
  ruby 'tests/TestGAVNodeSet.rb'
end


desc "Run the basic script with fixtures/test.xml"
task :basic do
  ruby 'spacer.rb tests/fixtures/test.xml'
end

desc "The command to run the full test suite."
task :tests => [:testgav, :testset] do
  puts "Tests complete!"
end