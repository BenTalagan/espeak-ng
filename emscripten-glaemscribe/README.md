Reworked the Makefile to use a more recent version of emscripten.
Will generate multiple async/sync wasm/nowasm versions for different purposes.
Removed worker logic from demos : too much overhead here and not useful.

### Preinstall requirements (version may be different for binaryen)

brew install emscripten
python /usr/local/Cellar/emscripten/1.38.25/libexec/embuilder.py build binaryen

#### 1.a. If emscripten is installed from source (for an install in ~/emsdk)

source ~/emsdk/emsdk_set_env.sh 

#### 1.b. If emscripten is installed from brew

=> Nothing to do (emscripten is in the env)

#### 2. BUILD From root directory

#### First runs

Should call ./autogen.sh in the 

  root and src/ucd-tools
 
directories !!

#### General espeakng rebuild flow

````
make clean
make distclean
./configure --prefix=/usr/local
make en
make install
```

#### General emscripten rebuild flow

```
make clean
make distclean
./configure --prefix=/usr --without-async --without-mbrola --without-sonic
make en
cd src/ucd-tools
make clean
emconfigure ./configure
emmake make clean
emmake make
cd ../..
emconfigure ./configure --prefix=/usr --without-async --without-mbrola --without-sonic
emmake make clean
emmake make src/libespeak-ng.la
cd emscripten-glaemscribe
emmake make clean
emmake make
```