function transcribe(text) {

  if(typeof(client)==='undefined') {
    client = new ESpeakNGGlue();
    client.set_voice("ent");
  }

  var d1          = new Date();
  result          = client.synthesize(text, false, true, true, function(result) {});
  result.version  = client.version();
  result.time     = new Date() - d1;
  
  return JSON.stringify(result);
}

function benchmark() {

  var ret = "\n";
  ret += transcribe("A letter for toto");
  ret += transcribe("A letter for toto");
  ret += transcribe("A letter for toto");
  ret += transcribe("A letter for toto");
  ret += transcribe("A letter for toto");
  ret += transcribe("A letter for toto");
  ret += transcribe("A letter for toto");
  ret += transcribe("A letter for toto");

  var h = "A letter for toto. "
  var r = h;

  for(var i=0;i<1000;i++)
    r += h;

  ret += transcribe(r);
  return ret;
}

function loadGlaemscribeEspeakNGAsync(callback) {
  
  if(typeof(GlaemscribeEspeakNG) === 'undefined')
    throw "Trying to load GlaemscribeEspeakNG asynchronously but the async version is not present in your env!";
  
  GlaemscribeEspeakNG().then(function(Module) { 
    ESpeakNGGlue = Module.ESpeakNGGlue;
    callback(); 
  })
};
