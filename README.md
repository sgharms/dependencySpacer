## INTRODUCTION

This is a simple script for pretty-re-formatting Maven pom.xml <dependency>
stanzas. 

## Requirements

   * Ruby
   * [Nokogiri library](http://github.com/tenderlove/nokogiri)

## USAGE

There are two primary use modes, as a Textmate plugin, and as a stand-alone
CLI app (for taking the output and pasting it into a less-macho editor).

### CLI

`[from ~dependencySpacer checkout dir]ruby spacer.rb /path/to/pom.xml`

### Textmate
   * Go into the Bundle Editor
   * Go into the XML drop-down
   * Use the "Add command" button
   * I entitled my command "Dependency Prettyify"
   * Paste 'plugin' into that box
   * Change the scope to text.xml
   * Make sure the Ruby shebang at the top is present
   * Edit a pom.xml file
   * Hi-light from the left gutter the <dependencies> tag all the way through
     the </dependencies> tag
   * Select the command
   * Use command+] to re-indent as needed


## CONTENTS
   * dependencyformat:  the library that's resourced by this
   * plugin:    the source to a Textmate command version of this script
   * Rakefile:  For rake:  rake (testgav|tests|testset); use rake -T
   * README.md: This file
   * spacer.rb: the code that re-formats the markup
   * tests:  unit tests


