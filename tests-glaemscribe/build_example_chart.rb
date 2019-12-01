#!/usr/bin/env ruby
# encoding: UTF-8

require "securerandom"
require "erb"

Dir.chdir(File.dirname(__FILE__))

SPECS = {
  "en-tengwar":     "build/examples.tengwar.jrrt.txt",
  "en-gb-x-rp":     "build/examples.normal.rp.txt",
  "en-tengwar-rp":  "build/examples.tengwar.rp.txt",
  "en-gb":          "build/examples.normal.gb.txt",
  "en-tengwar-gb":  "build/examples.tengwar.gb.txt",
  "en-us":          "build/examples.normal.us.txt",
  "en-tengwar-us":  "build/examples.tengwar.us.txt"
}
  
def load_erb(filepath)
  template = ""
  File.open(filepath,"rb:UTF-8") { |f| template = f.read }
  ERB.new(template, 0, nil, "erb_" + SecureRandom.uuid.gsub("-","_"))
end

$ERB = load_erb("example_chart_template.html.erb")  
  
class Line
  attr_accessor :type
  attr_accessor :content
  attr_accessor :idx
  attr_accessor :translations
  
  def initialize
    @translations = {}
  end
end

def read_example_file(filename)
  
  lidx    = 0
  lines   = File.open(filename,"rb:UTF-8").readlines.map{|l| l.strip }.reject!{|l| l == ""}.map{ |l|
  
    ll = Line.new
    if l.start_with? "#"
      # This is a comment
      ll.type = :comment
      l.gsub!(/^\#\s*/,"")
    else
      ll.type       = :example
      ll.idx        = lidx
      lidx += 1
    end
    
    ll.content    = l
    
    ll
  }
  
  lines
end

def dump_as_raw_example_file(content, filename)
  f = File.open(filename, "wb:UTF-8") {|f|
    content.each{|ll|
      if ll.type == :example
        f << ll.content + "\n"
      end
    }  
  }  
end

def translate_raw_example_file
  SPECS.each{ |k,v|
    %x(espeak-ng -v #{k} --ipa -f build/_examples.txt > #{v})
  }
end

def assemble_result(lines)
  lookup = {}
  lines.each{|l| lookup[l.idx] = l if l.idx }

  SPECS.each{ |k,v|
    slines = File.open(v,"rb:UTF-8").readlines
    slines.each_with_index{ |sline,lidx|
      lookup[lidx].translations[k] = sline
    }
  }
  
  File.open("build/example_chart.html","wb:UTF-8") { |f|
    f << $ERB.result(binding)
  }
end

def build_full_chart
  lines = read_example_file("examples.txt")
  dump_as_raw_example_file(lines, "build/_examples.txt")
  translate_raw_example_file
  assemble_result(lines)
end

puts "Building example chart on data set ..."
build_full_chart
