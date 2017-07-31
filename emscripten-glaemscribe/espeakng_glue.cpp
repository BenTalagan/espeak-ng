/*
 * Copyright (C) 2014-2017 Eitan Isaacson
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, see: <http://www.gnu.org/licenses/>.
 */

#include <stdio.h>
#include <stdlib.h>
#include <emscripten.h>
#include "speak_lib.h"

static int    gSamplerate = 0;
static FILE*  gCurrentWavFile = NULL;

void Write4Bytes(FILE *f, int value)
{
	// Write 4 bytes to a file, least significant first
	int ix;

	for (ix = 0; ix < 4; ix++) {
		fputc(value & 0xff, f);
		value = value >> 8;
	}
}

FILE* OpenWavFile(const char *path, int rate)
{
	static unsigned char wave_hdr[44] = {
		'R', 'I', 'F', 'F', 0x24, 0xf0, 0xff, 0x7f, 'W', 'A', 'V', 'E', 'f', 'm', 't', ' ',
		0x10, 0, 0, 0, 1, 0, 1, 0,  9, 0x3d, 0, 0, 0x12, 0x7a, 0, 0,
		2, 0, 0x10, 0, 'd', 'a', 't', 'a',  0x00, 0xf0, 0xff, 0x7f
	};

	FILE* f_wavfile = fopen(path, "wb");
	
	if (!f_wavfile)
    return NULL;

	fwrite(wave_hdr, 1, 24, f_wavfile);
	Write4Bytes(f_wavfile, rate);
	Write4Bytes(f_wavfile, rate * 2);
	fwrite(&wave_hdr[32], 1, 12, f_wavfile);

  return f_wavfile;
}

void CloseWavFile(FILE* f_wavfile)
{
	unsigned int pos;
  
  if(!f_wavfile)
    return;

	fflush(f_wavfile);
	pos = ftell(f_wavfile);

	if (fseek(f_wavfile, 4, SEEK_SET) != -1)
		Write4Bytes(f_wavfile, pos - 8);

	if (fseek(f_wavfile, 40, SEEK_SET) != -1)
		Write4Bytes(f_wavfile, pos - 44);

	fclose(f_wavfile);
}


int SynthCallback(short *wav, int numsamples, espeak_EVENT *events)
{
	if (numsamples > 0) 
  {
		fwrite(wav, numsamples*2, 1, gCurrentWavFile);
	}
	return 0;
}


class ESpeakNGGlue {
public:
  ESpeakNGGlue() : rate(espeakRATE_NORMAL), pitch(50), current_voice(NULL) {
    if (!gSamplerate) {
      gSamplerate = espeak_Initialize(AUDIO_OUTPUT_SYNCHRONOUS, 100, NULL, espeakINITIALIZE_DONT_EXIT);
    }
    samplerate = gSamplerate;
    voices = espeak_ListVoices(NULL);
  }
  
  int synth_all_(const char* aText, const char* wavVirtualFileName, const char* ipaVirtualFileName)
  {   
    bool processWav = (wavVirtualFileName != NULL);
    bool processIpa = (ipaVirtualFileName != NULL);
    
    FILE* f_phonemes_out = NULL;
    
    // Clean synth callback.
    espeak_SetSynthCallback(NULL);
    espeak_SetPhonemeTrace(0, NULL);
    
    if (current_voice)
      espeak_SetVoiceByProperties(current_voice);
    else
      espeak_SetVoiceByName("default");
    
    if(processWav)
    {
      // Open wav file
      gCurrentWavFile = OpenWavFile(wavVirtualFileName, samplerate);
      if(!gCurrentWavFile)
        return -1;
      
      // Set synth callback
      espeak_SetSynthCallback(SynthCallback);

      espeak_SetParameter(espeakPITCH, pitch, 0);
      espeak_SetParameter(espeakRATE, rate, 0);
    }
    
    if(processIpa)
    {
      // phoneme_mode
      //  bit 1:   0=eSpeak's ascii phoneme names, 1= International Phonetic Alphabet (as UTF-8 characters).
      //  bit 7:   use (bits 8-23) as a tie within multi-letter phonemes names
      //  bits 8-23:  separator character, between phoneme names
      
      int phoneme_conf = (1<<1);
      // phoneme_conf |= (1<<7)
      // int phonemes_separator = ' ';
      // phoneme_conf |= (phonemes_separator << 8);
    
      f_phonemes_out = fopen(ipaVirtualFileName,"wb");
      if(!f_phonemes_out)
        return -2;
    
      //espeak_ng_InitializeOutput(ENOUTPUT_MODE_SYNCHRONOUS, 0, NULL);
      espeak_SetPhonemeTrace(phoneme_conf, f_phonemes_out);
    }
    
    espeak_Synth(aText, 0, 0, POS_CHARACTER, 0, 0, NULL, NULL);
    
    if(processWav)
    {
      // Close current wav file
      fclose(gCurrentWavFile);
    }
    
    if(processIpa)
    {
      fclose(f_phonemes_out);   
    }
        
    // Reset callback so other instances will work too.
    espeak_SetSynthCallback(NULL);
    espeak_SetPhonemeTrace(0, NULL);
    
    return 0;
  }

  long set_voice(
        const char* aName,
        const char* aLang=NULL,
        unsigned char aGender=0,
        unsigned char aAge=0,
        unsigned char aVariant = 0
    ) {
    long result = 0;
    if (aLang || aGender || aAge || aVariant) {
      espeak_VOICE props = { 0 };
      props.name = aName;
      props.languages = aLang;
      props.gender = aGender;
      props.age = aAge;
      props.variant = aVariant;
      result = espeak_SetVoiceByProperties(&props);
    } else {
      result = espeak_SetVoiceByName(aName);
    }

    // This way we don't need to allocate the name/lang strings to the heap.
    // Instead, we store the actual global voice.
    current_voice = espeak_GetCurrentVoice();

    return result;
  }

  int getSizeOfEventStruct_() {
    return sizeof(espeak_EVENT);
  }

  const espeak_VOICE** voices;
  int samplerate;
  int rate;
  int pitch;

private:
  espeak_VOICE* current_voice;
};

#include <glue.cpp>

