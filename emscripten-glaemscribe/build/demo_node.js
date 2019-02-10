#!/usr/bin/env node

// ======================
// === ENV LOADING ======
// ======================

Fs       = require("fs")
Vm       = require("vm")
Glob     = require("Glob") // npm install glob
Path     = require("path")
Util     = require("util")
print    = console.log;

Espeak = require(__dirname + "/js/espeakng.for.glaemscribe.embed.js")

// Use the following trick to load the javascript that we would use normally in a web browser
function include(path) { var code = Fs.readFileSync(path, 'utf-8'); Vm.runInThisContext(code, path); }


//include(__dirname + "/packed/espeakng.for.glaemscribe.embed.js")
// include(__dirname + "/js/espeakng.for.glaemscribe.embed.js")

function transcribe() {
  client = new Espeak.ESpeakNGGlue();
  result = client.synthesize("A letter for toto", false, true, true, function(result) {});
  console.log(result)
}

transcribe()
 
console.log("yo")
