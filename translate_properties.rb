#!/usr/bin/env ruby
require 'rubygems'
require 'easy_translate'
require 'orderedhash'

if ARGV.length != 2
   $stderr.puts """Usage: ./translate_properties.rb properties_file target_lang
target_lang can be one of:
\t#{EasyTranslate::LANGUAGES.values.join("\n\t")}
"""
  exit 1
end

properties = OrderedHash.new
File.open(ARGV[0], 'r') do |file|
  file.read.each_line do |line|
    line.strip!
    if (line[0] != ?# and line[0] != ?=)
      i = line.index('=')
      if (i)
        properties[line[0..i - 1].strip] = line[i + 1..-1].strip
      else
        properties[line] = ''
      end
    end
  end
end

properties.each_slice(100) { |slice|
  h = OrderedHash[*slice.flatten]
  begin
    translated = EasyTranslate.translate(h.values, :to=>ARGV[1])
    translated.each_with_index {|value, i| 
      print h.keys[i] + "=" + value + "\n"
    }
    sleep 60
  rescue EasyTranslate::EasyTranslateException => e
    $stderr.puts "Error occurred translating\n"
    $stderr.puts "Start line: #{slice.first}\n"
    $stderr.puts "End line:   #{slice.last}\n"
    $stderr.puts e
    exit 1
  end

}
