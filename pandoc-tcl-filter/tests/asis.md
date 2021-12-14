---
title: "Tests for asis chunks"
author: Detlef Groth
date:  Dec 14, 2021
---

## Introduction

This document contains tests for code chunks with the results="asis" option.

## Headers

Using puts:

``` {.tcl results="asis"}

puts {## huhu 1}

```

Using as last statement (return)

``` {.tcl results="asis"}
return {## huhu 2}
```

## Bold and Italic
  
```{.tcl results="asis"}
return "**this is bold** and _this is italic_ text!"
```
  
## Tables

```{.tcl results="asis"}
list2mdtab [list Col1 Col2 Col3] [list 1 2 3 4 5 6 7 8 9 10 11 12]
```

## EOF


