#!/usr/bin/env ruby
# encoding: UTF-8

require "securerandom"
require "erb"
require "json"

Dir.chdir(File.dirname(__FILE__))

SPECS = {
  "en-tengwar":     "tengwar.jrrt",
  "en-gb-x-rp":     "normal.rp",
  "en-tengwar-rp":  "tengwar.rp",
  "en-gb":          "normal.gb",
  "en-tengwar-gb":  "tengwar.gb",
  "en-us":          "normal.us",
  "en-tengwar-us":  "tengwar.us"
}

BUILD_DIR = "./build/"

def example_entries_file
  "#{BUILD_DIR}/examples/_examples.txt"
end

def example_file(base_name)
  "#{BUILD_DIR}/examples/examples.#{base_name}.txt"
end

def unit_test_file(base_name)
  "#{BUILD_DIR}/unit_tests/expected.#{base_name}.json"
end
  
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
  SPECS.each{ |voice, file_name|
    %x(espeak-ng -v #{voice} --ipa -f #{example_entries_file} > #{example_file(file_name)})
  }
end

def dump_unit_tests(lines)
  SPECS.each{ |voice, file_name|
    r = {}
    r[:trans] = {}
    lines.each { |l, lidx|
      if l.type == :example
        r[:trans][l.content] = l.translations[voice]
      end
    }
    File.open(unit_test_file(file_name),"wb:UTF-8") { |f|
      f << JSON.pretty_generate(r)
    }
  }
end

def unit_test(lines)
  error_count = 0
  SPECS.each{ |voice, file_name|
    errors = []
    
    r      = {}
    tested = {}
    
    File.open(unit_test_file(file_name),"rb:UTF-8") { |f|
      r = JSON.parse(f.read)['trans']
    }
    
    headline = "Unit testing #{voice} ... ".ljust(40)
    
    lines.each { |l|
      next if l.type != :example
      if r[l.content]
        good = r[l.content]
        done = l.translations[voice]
        if good != done
          errors << "D: #{done}\n    G: #{good}\n"
        end
        tested[l.content] = true
      else
        errors << "Entry #{l.content} is missing !"
      end
    }
    
    r.each { |k,v|
      if !tested[k]
        errors << "Entry #{k} is no longer tested !"
      end
    }
    
    headline += (errors.count > 0)?("[FAILED]"):("[  OK  ]")
    puts headline
    errors.each{|e|
      puts "*** #{e}"
    }
    error_count = errors.count
  }
  puts ""
  puts "Unit tests : #{error_count} error(s)."
  puts ""
end

def gather_transcription_results(lines)
  lookup = {}
  lines.each{|l| lookup[l.idx] = l if l.idx }

  SPECS.each{ |voice,file_name|
    slines = File.open("#{example_file(file_name)}","rb:UTF-8").readlines
    slines.each_with_index{ |sline,lidx|
      lookup[lidx].translations[voice] = sline.strip
    }
  }
end
  

def assemble_html_result(lines)
  File.open("#{BUILD_DIR}/example_chart.html","wb:UTF-8") { |f|
    f << $ERB.result(binding)
  }
end

def build_full_chart_and_unit_test
  lines = read_example_file("examples.txt")
  dump_as_raw_example_file(lines, "#{example_entries_file}")
  
  translate_raw_example_file
  gather_transcription_results(lines)
  assemble_html_result(lines)
  
  if ARGV.include? "--dump-unit-tests"
    puts "DUMPING UNIT TESTS !!!"
    dump_unit_tests(lines)
  else
    puts ""
    puts "Unit testing ..."  
    puts ""
    unit_test(lines)
  end
end

puts "Building example chart on data set ..."
build_full_chart_and_unit_test
