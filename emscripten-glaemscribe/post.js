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

/*
// Make this a worker 
if (typeof WorkerGlobalScope !== 'undefined') {
  var glue;

  Module.postRun.push(function () {
    glue = new ESpeakNGGlue();
    postMessage('ready');
  });

  onmessage = function(e) {
    if (!glue) {
      throw 'ESpeakNGGlue for worker is not initialized';
    }
    var args = e.data.args;
    var message = { callback: e.data.callback, done: true };
    message.result = [glue[e.data.method].apply(glue, args)];
    if (e.data.callback)
      postMessage(message);
  }

//  
// // Need for using embeded version in a web worker 
// shouldRunNow        = true;
// Module["calledRun"] = false;
// run();
// 
}
*/



