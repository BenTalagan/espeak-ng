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

// Use the following trick to load the javascript that we would use normally in a web browser
function include(path) { var code = Fs.readFileSync(path, 'utf-8'); Vm.runInThisContext(code, path); }
include(__dirname + "/js/glaemscribe.espeakng.js")

client = new GlaemscribeEspeakClient(__dirname + "/js/")
client.load()
client.synthesize("toto",{voice:'en-jrrt-tengwar'},function(wav) {
  console.log(wav)
});

/*
espeak = require("./js/espeakng.library.node.js")
glue = new espeak.ESpeakNGGlue();
console.log(glue.synthesize("toto"))
*/