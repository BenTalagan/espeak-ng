Fast recompile resources and js, in the root directory :

- Preinstall requirements (version may be different for binaryen)

brew install emscripten
python /usr/local/Cellar/emscripten/1.38.25/libexec/embuilder.py build binaryen

- 1.a. If emscripten is installed from source
source ~/emsdk-portable/emsdk_set_env.sh 

- 1.b. If emscripten is installed from brew
=> Nothing to do

- 2. From root directory

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