#!/usr/bin/env ruby
# encoding: UTF-8

Dir.chdir(File.dirname(__FILE__))

require "erb"
require "securerandom"

EN_PHONEMES_SORTED = [
  
  # Variants of A
  'a',
  'aa',
  'a#',
  'a#2',
  'a2',
  'A#',
  'A:',
  'A@',
  'A~',
  
  # A Diphtongs
  'aI',
  'aI3',
  'aI@',
  'aU',
  'aU@',
  
  # Variants of E
  'e#',
  'e:',
  'E',
  'E#',
  'E2',
  
  'e@',
  'eI',
  
  # Variants of I
  'i',
  'i:',
  'I',
  'I#',
  'I2',
  'I2#',
  'IR',

  'i@',
  'i@3',
  
  # Variants of O
  'o:',
  'O',
  'O2',
  'O:',
  'OI',
  'O~',
  'O@',
  '0',  
  '0#',
  '02',
  
  'o@',
  'oU',
  'oU#',
  
  # Variants of U
  'V',
  'VR',
  'u:',
  'U',
  'U@',
 
  # Variants of Schwa
  '@',
  '@#',
  '@2',
  '@5',
  '@L',

  # Rhoticized
  '3',
  '32',
  '3:',
  
  # Glottal Stop
  '?',
  
  'c#',
  'd#',
  
  'l',
  
  'n',
  'N2',
  
  'r-',
  'r/',
  
  't',
  't#',
  't2',

  
  'w#',
  'z#',
  'z/2'
]


PHSTART_REGEXP  = /^phoneme\s+(\S+)\s*.*$/
PHEND_REGEXP    = /^endphoneme.*$/ 
    
def load_erb(filepath)
  template = ""
  File.open(filepath,"rb:UTF-8") { |f| template = f.read }
  ERB.new(template, 0, nil, "erb_" + SecureRandom.uuid.gsub("-","_"))
end

$ERB = load_erb("ph_chart_template.html.erb")

class Phoneme
  attr_accessor :name, :pre, :code
end

class Lang
  attr_reader :name
  attr_reader :parent
  attr_reader :ref_langs
  
  def initialize(name,parent,ref_langs=nil)
    @name = name
    @parent = parent
    @ref_langs = ref_langs || []
  end
end
  

# Read a phoneme file
# Return { "ph": Phoneme }
def read_ph_source(file_path)
  phonemes = {}
  
  in_phon     = false
  cphon       = ""
  cphon_name  = ""
  interphon   = ""
  File.open(file_path,"rb:UTF-8") { |f|
    f.read.lines.each{ |l|
    
      if(!in_phon && PHSTART_REGEXP =~ l)
        in_phon = true
        cphon += l
        cphon_name = $1
        pre = interphon
      elsif PHEND_REGEXP =~ l
        in_phon = false
        cphon += l
        
        ph = Phoneme.new
        ph.name = cphon_name
        ph.code = cphon
        ph.pre  = interphon.strip
        ph.pre += "\n" if !ph.pre.empty?
        
        phonemes[cphon_name] = ph
        cphon = ""
        interphon = ""
      else
        if in_phon
          cphon += l 
        else
          interphon += l
        end
      end
    }
  }
  phonemes
end

def span_colorize(s, color)
  "<span class='#{color}'>#{s}</span>"
end

def colorize(code)
  code = code.gsub(/(\/\/.*)$/) {
    span_colorize($1,"grey")
  }
  code = code.gsub(/^(phoneme|endphoneme)/) {
    span_colorize($1, "blue")
  }
  code = code.gsub(/\b(END|IF|NOT|THEN|ELSE|ELSEIF|ENDIF)\b/) {
    span_colorize($1, "green")    
  }
  code = code.gsub(/\b(CALL|ChangePhoneme|ChangeIfDiminished|AppendPhoneme|IfNextVowelAppend|InsertPhoneme|import_phoneme)\b/) {
    span_colorize($1, "red")    
  }
  
  code  
end

def compile(code)
  code = code.gsub(/(\/\/.*)$/) { "" }
  code = code.lines.map{ |l| l.gsub(/\s+/, " ").strip }.join("\n").strip
  code
end

def phoneme_sorter(ph1,ph2)
  if !$PHLKUP
    $PHLKUP = {}
    EN_PHONEMES_SORTED.each_with_index { |p,i|
      $PHLKUP[p] = i
    }
  end
  
  i1 = $PHLKUP[ph1]
  i2 = $PHLKUP[ph2]
  
  if i1
    if i2
      i1 <=> i2
    else
      -1
    end
  else
    if i2
      1
    else
      ph1 <=> ph2
    end
  end
end

def build_chart(langs)  
  chart_sources = {}
  
  langs.each{ |l| 
    chart_sources[l.name] = read_ph_source("../phsource/" + l.name) 
  }
  
  ref_lang      = langs[0]
  ref_phonemes  = chart_sources[ref_lang.name].keys
  
  langs.each{|l| ref_phonemes += chart_sources[l.name].keys}
  ref_phonemes = ref_phonemes.sort{ |ph1,ph2| phoneme_sorter(ph1,ph2) }.uniq
  
  @toto = "test"
  File.open("build/ph_chart.html","wb:UTF-8") { |f|
    f << $ERB.result(binding)
  }
end

def build_full_chart

  en     = Lang.new("ph_english",nil)
  en_rp  = Lang.new("ph_english_rp",en)
  en_us  = Lang.new("ph_english_us",en)
  
  ref_langs = [en,en_rp,en_us]
  
  teng_t = Lang.new("ph_ent",nil,ref_langs)
  
  build_chart([
    en,
    en_rp,
    en_us,
    teng_t,
    Lang.new("ph_ent_gb",teng_t,ref_langs),
    Lang.new("ph_ent_us",teng_t,ref_langs)
  ])
end

puts "Building phoneme comparison chart from phsource data for lang 'en' and 'ent'..."
build_full_chart




