# Main differences/additions

The build flow is different from the original demo :

- Reworked the Makefile to use a more recent version of emscripten.
- Will generate multiple async/sync wasm/nowasm versions for different purposes.
- Removed worker logic from demos : too much overhead here and not useful.

==Only MacOS is covered.==

### Preinstall requirements

- install xcode command line tools
- install emscripten from sources (in ~/emsdk for example)
- install cmake from brew

### Build From root directory

#### First run

Should call ./autogen.sh in the `root` and `src/ucd-tools` directories !!  

#### General espeakng rebuild flow

```
make clean
make distclean
./configure --prefix=/usr/local
make en
make install
```

#### General emscripten rebuild flow

Activate emscripten

```
source ~/emsdk/emsdk_env.sh 
```

This can be a good idea to exchange `phonemes` and `phonemes_light` files in ph_source. This will result in a smaller compiled library.

```
mv phsource/phonemes phsource/phonemes.orig
mv phsource/phonemes.light phsource/phonemes 
```

Then

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
cd ..
```

Restore phonemes

```
mv phsource/phonemes phsource/phonemes.light
mv phsource/phonemes.orig phsource/phonemes
```

### Troubleshoot

Last compilation was done with emscripten 1.39.13 . 

Had to comment C99 checks in configure.ac or the configure step would fail, emcc would be rejected as a compiler not supporting C99.

