---
title: "pandoc-tcl-filter example - rplot filter"
author: 
- Detlef Groth
date: Fri Nov 29 2021
abstract: >
    Some abstract ...
    on several lines...
---

## Introduction

Below are a few samples for embedding R plotting code into Markdown documents.
The examples should work as well in other text markup languages like LaTeX,
Asciidoc etc. This filter requires a installation of the R software
environment for statistical computing and graphics. The command Rscript must
be in the PATH.

Links: 

* R-Project page: [https://www.r-project.org]

## R plot example

```
     ```{.rplot label=iris echo=true}
     data(iris)
     pairs(iris[,1:3],pch=19,col=as.numeric(iris$Species)+1)
     ```
```

Which will produce the following output:

```{.rplot label=iris echo=true}
data(iris)
pairs(iris[,1:3],pch=19,col=as.numeric(iris$Species)+1)
```


## Document creation

Assuming that the file pandoc-tcl-filter.tapp is in your PATH, 
this document can be converted into an HTML file using the command line:

```
 pandoc -s -o sample-rplot.html --filter pandoc-tcl-filter.tapp sample.md
 ## you can as well specify a style sheet to beautify the output
 pandoc -s -o sample-rplot.html --css ghpandoc.css \
    --filter pandoc-tcl-filter.tapp sample.md
```

## EOF



