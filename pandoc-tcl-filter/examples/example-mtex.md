---
title: "pandoc-tcl-filter example - mtex filter"
author: 
- Detlef Groth
date: Fri Nov 26 2021
---

## Introduction

Below are a few samples for embedding LaTeX equations into Markdown documents.
The examples should work as well in other text markup languages like LaTeX,
Asciidoc etc. This filter requires a installation of the LaTeX command line tools and of the *varwidth* LaTeX package.

Links: 

* LaTeX Homepage: [https://www.latex-project.org/](https://www.latex-project.org/)
* LaTeX tutorial: [https://ftp.gwdg.de/pub/ctan/info/lshort/english/lshort-a5.pdf](https://ftp.gwdg.de/pub/ctan/info/lshort/english/lshort-a5.pdf)

Here a famous example:

```{.mtex fontsize=LARGE}
E = m \times c^2
```

And here the second example:

```{.mtex fontsize=LARGE}
 F(x) = \int^a_b \frac{1}{3}x^3
```

And here the code for the two examples:

```
     ```{.mtex fontsize=LARGE}
     E = m \times c^2
     ```

     text ...

     ```{.mtex fontsize=LARGE}
     F(x) = \int^a_b \frac{1}{3}x^3
     ```
```

## Document creation

Assuming that the file pandoc-tcl-filter.tapp is in your PATH, 
this document can be converted into an HTML file using the command line:

```
 pandoc -s -o sample-mtex.html --filter pandoc-tcl-filter.tapp sample.md
 ## you can as well specify a style sheet to beatify the output
 pandoc -s -o sample-mtex.html --css ghpandoc.css \
    --filter pandoc-tcl-filter.tapp sample.md
```



## EOF



