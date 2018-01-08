Fast recompile resources and js, in the root directory :

- 1.a. If installed from source
source ~/emsdk-portable/emsdk_set_env.sh 

- 1.b. If installed from brew
=> Nothing to do

- 2.

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
emmake make -f Makefile.node
