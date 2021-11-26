---
title: "pandoc-tcl-filter example - dot filter"
author: 
- Detlef Groth
date: Fri Nov 26 2021
abstract: >
    Some abstract ...
    on several lines...
---

## Introduction

Below are a few samples for embedding code for the GraphViz tools dot and
neato into Markdown documents. The examples should work as well in other text
markup languages like LaTeX, Asciidoc etc. This filter requires a installation of the command line tools of the GraphViz tools.

Links: 

* GraphViz Homepage: [https://graphviz.org/](https://graphviz.org/)
* Dot guide: [https://graphviz.org/pdf/dotguide.pdf](https://graphviz.org/pdf/dotguide.pdf)
* Neato guide: [https://graphviz.org/pdf/neatoguide.pdf](https://graphviz.org/pdf/neatoguide.pdf)

## Dot graph

```
     ```{.dot label=digraph echo=true}
     digraph G {
       main -> parse -> execute;
       main -> init [dir=none];
       main -> cleanup;
       execute -> make_string;
       execute -> printf
       init -> make_string;
       main -> printf;
       execute -> compare;
     }
     ```
```

Which will produce the following output:

```{.dot label=digraph echo=true}
digraph G {
  main -> parse -> execute;
  main -> init [dir=none];
  main -> cleanup;
  execute -> make_string;
  execute -> printf
  init -> make_string;
  main -> printf;
  execute -> compare;
}
```

## Neato graphs

By using the argument `app=neato` in the code chunk header you can as well
create *neato* graphs. Here an example:

```
      ```{.dot label=neato-sample app=neato}
      graph G {
          node [shape=box,style=filled,fillcolor=skyblue,
              color=black,width=0.4,height=0.4];
          n0 -- n1 -- n2 -- n3 -- n0;
      }
      ```
```

Here the output.

```{.dot label=neato-sample app=neato}
graph G {
    node [shape=box,style=filled,fillcolor=skyblue,
        color=black,width=0.4,height=0.4];
    n0 -- n1 -- n2 -- n3 -- n0;
}
```

## Document creation

Assuming that the file pandoc-tcl-filter.tapp is in your PATH, 
this document can be converted into an HTML file using the command line:

```
 pandoc -s -o sample-dot.html --filter pandoc-tcl-filter.tapp sample.md
 ## you can as well specify a style sheet to beatify the output
 pandoc -s -o sample-dot.html --css ghpandoc.css \
    --filter pandoc-tcl-filter.tapp sample.md
```



## EOF



