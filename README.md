# eSpeak NG - Glaemscribe fork

[Glaemscribe](https://github.com/BenTalagan/glaemscribe) is a transcription engine dedicated to Tolkien's writing systems. It uses (will use in a near future) [eSpeak NG](https://github.com/eSpeak%20NG/eSpeak%20NG) for its phonemic modes, and thus integrates an emscripten compiled version of eSpeak NG.
 
Forking is needed for that purpose, but this fork is very close to the original version of [eSpeak NG](https://github.com/eSpeak%20NG/eSpeak%20NG), so it lives in parallel and is updated with [eSpeak NG](https://github.com/eSpeak%20NG/eSpeak%20NG)'s fixes. Glaemscribe's fork integrates a few custom patches to make [eSpeak NG](https://github.com/eSpeak%20NG/eSpeak%20NG) compatible with [Glaemscribe](https://github.com/BenTalagan/glaemscribe). The main differences/additions of this fork are :

- It has additionnal phonemic rules to handle virtual chars that are used to instrument the original text and are kept in the output IPA to restore the punctuation. This is a needed, but dirty hack.
- It has its own phoneme files to augment IPA for the needs of tengwar transcription ; the phoneme files have a different inheritance hierarchy, and will try to keep phonological distinctions as much as possible in the IPA so that they are available during transcription (for example standard intra-word phonetic r handling vs linking r vs intrusive r).
- It has also its own way of building the emscripten files.
- It has it's own unit tests.

## Build info

See the `/emscripten-glaemscribe` folder.

## Tests

See the `/tests-glaemscribe` folder.

## License Information

[eSpeak NG](https://github.com/eSpeak%20NG/eSpeak%20NG) Text-to-Speech is released under the [GPL version 3](COPYING) or
later license.

The `ieee80.c` implementation is taken directly from
[ToFromIEEE.c.txt](http://www.realitypixels.com/turk/opensource/ToFromIEEE.c.txt)
which has been made available for use in Open Source applications per the
[license statement](COPYING.IEEE) on http://www.realitypixels.com/turk/opensource/.
The only modifications made to the code is to comment out the `TEST_FP` define
to make it useable in the [eSpeak NG](https://github.com/eSpeak%20NG/eSpeak%20NG) library, and to fix compiler warnings.

The `getopt.c` compatibility implementation for getopt support on Windows is
taken from the NetBSD `getopt_long` implementation, which is licensed under a
[2-clause BSD](COPYING.BSD2) license.

Android is a trademark of Google Inc.
