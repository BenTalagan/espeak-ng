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

// The two following lines seems to be required now
global.__dirname = __dirname;
global.require = require;

// Use the following trick to load the javascript that we would use normally in a web browser
function include(path) { var code = Fs.readFileSync(path, 'utf-8'); Vm.runInThisContext(code, path); }

include(__dirname + "/js/espeakng.for.glaemscribe.wasm.async.js")
include(__dirname + "/demo_common.js")

loadGlaemscribeEspeakNGAsync(function() {
  console.log(benchmark());    
});