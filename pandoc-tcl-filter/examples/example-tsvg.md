---
title: "pandoc-tcl-filter example - tsvg filter"
author: 
- Detlef Groth
date: Fri Nov 26 2021
---

## Introduction

Below are a few samples for embedding code for the Tcl tsvg package into
Markdown documents. The examples should work as well in other text markup
languages like LaTeX, Asciidoc etc. This filter requires no additional
software installations as the package and the filter are directly included in
the pandoc-tcl-filter release.

Links: 

* DGTcl Homepage: [https://github.com/mittelmark/DGTcl](https://github.com/mittelmark/DGTcl)
* tsvg guide: [http://htmlpreview.github.io/?https://github.com/mittelmark/DGTcl/blob/master/pandoc-tcl-filter/lib/tsvg/tsvg.html](http://htmlpreview.github.io/?https://github.com/mittelmark/DGTcl/blob/master/pandoc-tcl-filter/lib/tsvg/tsvg.html)

## tsvg graphics

```
 ` ``{.tsvg label=tsvg-hello-world results=hide echo=false}
 tsvg circle cx 50 cy 50 r 45 stroke black stroke-width 2 fill salmon
 tsvg text x 29 y 45 Hello
 tsvg text x 26 y 65 World!
 ` ```
```

Will produce this:

```{.tsvg fig=true label=tsvg-hello-world results=hide echo=true}
tsvg circle cx 50 cy 50 r 45 stroke black stroke-width 2 fill salmon
tsvg text x 29 y 45 Hello
tsvg text x 26 y 65 World!
```

## Document creation

Assuming that the file pandoc-tcl-filter.tapp is in your PATH, 
this document can be converted into an HTML file using the command line:

```
 pandoc -s -o sample-tsvg.html --filter pandoc-tcl-filter.tapp sample.md
 ## you can as well specify a style sheet to beatify the output
 pandoc -s -o sample-tsvg.html --css ghpandoc.css \
    --filter pandoc-tcl-filter.tapp sample.md
```



## EOF



