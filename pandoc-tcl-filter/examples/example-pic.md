---
title: "pandoc-tcl-filter example - PIC/EQN filter"
author: 
- Detlef Groth
date: Fri Nov 26 2021
---

## Introduction

Below are a few samples for embedding code for the PIC diagram language and
for the EQN equation language into kdown documents. The examples should work
as well in other text markup languages like LaTeX, Asciidoc etc. This filter
requires a installation of the groff command line tools where the required
command line applications *pic2graph* and *eqn2graph* are as well installed.

Links: 

* Groff Homepage: [https://www.gnu.org/software/groff/](https://www.gnu.org/software/groff)
* Unix Text Processing Book: [https://www.oreilly.com/openbook/utp/](https://www.oreilly.com/openbook/utp/)

## PIC diagrams

Here a code example for PIC diagrams. The indentation at the beginning must be
removed. It is just here to avoid interpretation.

```{.pic ext=png}
circle "circle" rad 0.5 fill 0.3; arrow ;
ellipse "ellipse" wid 1.4 ht 1 fill 0.1 ; line;
box wid 1 ht 1 fill 0.05 "A";
spline;
box wid 0.4 ht 0.4 fill 0.05 "B";
arc;
box wid 0.2 ht 0.2 fill 0.05 "C";
```

Please note, that there exists the [Pikchr](https://pikchr.org) diagram processor which is a modern update on the PIC language with many more features. See here the example documentation for the [pikchr-filter](example-pik.html).


## EQN equations

This is an old possibilty to create images out of equations.
Here the input code where we have to tweak the image size.

The code  (the indentation of five spaces is just to avoid interpretation):

```
     ```{.eqn echo=false}
     x = {-b +- sqrt{b sup 2 - 4ac}} over 2a
     ```
```

And here the output:

```{.eqn echo=false}
x = {-b +- sqrt{b sup 2 - 4ac}} over 2a
```

As the standard figure size is quite large we have to modify the code slightly:

```
     ```{.eqn label=eqnsam include=false echo=false}
     x = {-b +- sqrt{b sup 2 - 4ac}} over 2a
     ```
    
     ![](images/eqnsam.png){#id width=130}
```

By using `echo=false` we avoid automatic embedding, below we manually display
the image and decrease the width.

Here the output:

```{.eqn label=eqnsam include=false echo=false}
x = {-b +- sqrt{b sup 2 - 4ac}} over 2a
```
   
![](images/eqnsam.png){#id width=150}


## Document creation

Assuming that the file pandoc-tcl-filter.tapp is in your PATH, 
this document can be converted into an HTML file using the command line:

```
 pandoc -s -o sample-dot.html --filter pandoc-tcl-filter.tapp sample.md
 ## you can as well specify a style sheet to beautify the output
 pandoc -s -o sample-dot.html --css ghpandoc.css \
    --filter pandoc-tcl-filter.tapp sample.md
```



## EOF



