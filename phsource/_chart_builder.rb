#!/usr/bin/env ruby
# encoding: UTF-8

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
  
  'V',
  'VR',
  
  'w#',
  'z#',
  'z/2'
]


PHSTART_REGEXP  = /^phoneme\s+(\S+)\s*.*$/
PHEND_REGEXP    = /^endphoneme.*$/ 
    
def load_erb(filepath)
  template = ""
  File.open(filepath,"rb:UTF-8") { |f| template = f.read }
  puts template.encoding
  puts template.valid_encoding?
  ERB.new(template, 0, nil, "erb_" + SecureRandom.uuid.gsub("-","_"))
end

$ERB = load_erb("_chart_builder.html.erb")

class Phoneme
  attr_accessor :name, :pre, :code
end

class Lang
  attr_accessor :name
  attr_accessor :parent
  
  def initialize(name,parent)
    @name = name
    @parent = parent
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
  code = code.gsub(/\b(CALL|ChangePhoneme|ChangeIfDiminished|AppendPhoneme|IfNextVowelAppend|InsertPhoneme)\b/) {
    span_colorize($1, "red")    
  }
  
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
    chart_sources[l.name] = read_ph_source(l.name) 
  }
  
  ref_lang      = langs[0]
  ref_phonemes  = chart_sources[ref_lang.name].keys
  
  langs.each{|l| ref_phonemes += chart_sources[l.name].keys}
  ref_phonemes = ref_phonemes.sort{ |ph1,ph2| phoneme_sorter(ph1,ph2) }.uniq
  
  @toto = "test"
  File.open("chart_ph_tengwar.html","wb:UTF-8") { |f|
    f << $ERB.result(binding)
  }
end

en   =   Lang.new("ph_english",nil)
en_t =   Lang.new("ph_tengwar_english",nil)

build_chart([
  en,
  Lang.new("ph_english_rp",en),
  Lang.new("ph_english_us",en),
  en_t,
  Lang.new("ph_tengwar_english_gb",en_t),
  Lang.new("ph_tengwar_english_us",en_t),
])





