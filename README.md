# eSpeak NG - Glaemscribe fork

eSpeak NG fork for Glaemscribe.

Glaemscribe uses (will use) espeak-ng for its phonemic modes, and thus integrates an emscripten compiled version of espeak-ng. It integrates a few custom patches to make espeak-ng compatible with glaemscribe, especially to make the punctuation work. It has also its own way of building the emscripten files.

See here for the [espeak-ng](https://github.com/espeak-ng/espeak-ng) main repository.
See here for [Glaemscribe](https://github.com/BenTalagan/glaemscribe)'s official git repository.

## Build info

See the emscripten-glaemscribe folder.

## Tests

See the tests-glaemscribe folder.

## License Information

eSpeak NG Text-to-Speech is released under the [GPL version 3](COPYING) or
later license.

The `ieee80.c` implementation is taken directly from
[ToFromIEEE.c.txt](http://www.realitypixels.com/turk/opensource/ToFromIEEE.c.txt)
which has been made available for use in Open Source applications per the
[license statement](COPYING.IEEE) on http://www.realitypixels.com/turk/opensource/.
The only modifications made to the code is to comment out the `TEST_FP` define
to make it useable in the eSpeak NG library, and to fix compiler warnings.

The `getopt.c` compatibility implementation for getopt support on Windows is
taken from the NetBSD `getopt_long` implementation, which is licensed under a
[2-clause BSD](COPYING.BSD2) license.

Android is a trademark of Google Inc.
