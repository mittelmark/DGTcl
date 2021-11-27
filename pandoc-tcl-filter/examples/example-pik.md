---
title: "pandoc-tcl-filter example - Pikchr filter"
author: 
- Detlef Groth
date: Fri Nov 26 2021
---

## Introduction

Below are a few samples for embedding code for the Pikchr diagram language
which is an extension of the PIC diagram language. Pikchr is embedded in recent
releases of the *fossil* software versioning system as subcommand `fossil pikchr`
The examples below should work as well in other text markup languages like LaTeX, Asciidoc etc. This filter
requires a installation of the *fossil* software or the standalone *pikchr* command.

Links: 

* Fossil Homepage: [https://fossil-scm.org](https://fossil-scm.org)
* Pikchr Homepage: [https://pikchr.org](https://pikchr.org)
* Pikchr Manual: [https://pikchr.org/home/doc/trunk/doc/userman.md](https://pikchr.org/home/doc/trunk/doc/userman.md)
* Pikchr Grammar: [https://pikchr.org/home/doc/trunk/doc/grammar.md](https://pikchr.org/home/doc/trunk/doc/grammar.md)

## Pikchr diagrams

Here a code example for Pikchr diagrams. The indentation at the beginning must
be removed. It is just here to avoid interpretation. To use a new downloaded
version of the fossil application like *fossil-2.17* you could change the app
option *app=fossil-2.17* for instance. Alternatively you could as well add
*app=pikchr* if you have commpiled the *pikchr* command line application
yourself.

The code for a sample diagram follows below:

```
     ```{.pikchr app=fossil}
     box "box"
     circle "circle" fill cornsilk at 1 right of previous
     ellipse "ellipse" at 1 right of previous
     oval "oval" at .8 below first box
     cylinder "cylinder" at 1 right of previous
     file "file" at 1 right of previous
     ```
```

Here the output:

```{.pikchr app=fossil}
box "box"
circle "circle" fill cornsilk at 1 right of previous
ellipse "ellipse" at 1 right of previous
oval "oval" at .8 below first box
cylinder "cylinder" at 1 right of previous
file "file" at 1 right of previous
```

We can resize as well the image by removing the automatic inclusion. Below an
example.

```
     ```{.pikchr label=pikchr app=fossil include=false}
     box "box"
     circle "circle" fill cornsilk at 1 right of previous
     ellipse "ellipse" at 1 right of previous
     oval "oval" at .8 below first box
     cylinder "cylinder" at 1 right of previous
     file "file" at 1 right of previous
     ```
    ![](images/pikchr.svg){#id width=400}
```

And here the resulting output:

```{.pikchr label=pikchr app=fossil include=false}
box "box"
circle "circle" fill cornsilk at 1 right of previous
ellipse "ellipse" at 1 right of previous
oval "oval" at .8 below first box
cylinder "cylinder" at 1 right of previous
file "file" at 1 right of previous
```

![](images/pikchr.svg){#id width=400}

## Hiding the Code

To avoid that the reader sees the diagram code just add the option
`echo=false` to the code chunk options.

```{.pikchr app=fossil ext=svg echo=false}
arrow right 200% "Markdown" "Source" 
box rad 10px "Markdown" "Formatter" "(markdown.c)" fill beige fit
arrow right 200% "HTML+SVG" "Output"
arrow <-> down 70% from last box.s
box same "Pikchr" "Formatter" "(pikchr.c)" fit
```

The code to create this document was:

```
     ```{.pikchr app=fossil ext=svg echo=false}
     arrow right 200% "Markdown" "Source" 
     box rad 10px "Markdown" "Formatter" "(markdown.c)" fill beige fit
     arrow right 200% "HTML+SVG" "Output"
     arrow <-> down 70% from last box.s
     box same "Pikchr" "Formatter" "(pikchr.c)" fit
     ```
```


## Document creation

Assuming that the file pandoc-tcl-filter.tapp is in your PATH, 
this document can be converted into an HTML file using the command line:

```
 pandoc -s -o sample-pik.html --filter pandoc-tcl-filter.tapp sample.md
 ## you can as well specify a style sheet to beatify the output
 pandoc -s -o sample-pik.html --css ghpandoc.css \
    --filter pandoc-tcl-filter.tapp sample.md
```


## EOF



