## Tcl Applications

This directory contains standalone executables where required libraries are
added directly to the Tcl application using concatanation.

To install them, just rename them removing the version number and then bin
extension on Unix systems. Here an example in case that you have in your home
directory a bin folder which is in your path:

```
mv mkdoc-0.4.bin ~/bin/mkdoc
chmod 755 ~/bin/mkdoc
```
