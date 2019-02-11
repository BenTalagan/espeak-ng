ESpeakNGGlue.prototype.synthesize = function (aText, with_wav, with_phonemes, phonemes_are_ipa, aCallback) {
  
  // Use a unique temp file for the worker. Avoid collisions, just in case.
  var wavVirtualFileName  = null;
  // Use a unique temp file for the worker. Avoid collisions, just in case.
  var phoVirtualFileName  = null;
  
  if(with_wav)
    wavVirtualFileName = "espeak-ng-wav-tmp-"  + Math.random().toString().substring(2);
  
  if(with_phonemes)
    phoVirtualFileName  = "espeak-ng-pho-tmp-"  + Math.random().toString().substring(2);
  
  var wav = "";
  var pho = ""
  var code = this.synth_all_(aText, wavVirtualFileName, phoVirtualFileName, phonemes_are_ipa);

  if(code == 0)
  {
    if(with_wav)
      wav = FS.readFile(wavVirtualFileName, { encoding: 'binary' })
    
    if(with_phonemes)
      pho = FS.readFile(phoVirtualFileName, { encoding: 'utf8' })
  } 
  
  // Clean up the tmp file
  if(with_wav)
    FS.unlink(wavVirtualFileName);
  
  if(with_phonemes)
    FS.unlink(phoVirtualFileName);
    
  var ret = {
    code: code,
    wav: wav,
    pho: pho
  }
  
  if(aCallback)
    aCallback(ret)
  
  return ret;
};
