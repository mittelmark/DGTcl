# DGTcl - Project

This repository contains the following Tcl packages and Pandoc filters written in the Tcl programming language:

## Pandoc filters

The [Pandoc](https://pandoc.org) application is a great document converter and processing tool. 
The pandoc-tcl-filter folder contains two Pandoc filters for Tcl code and for Graphviz dot files. To know more about Pandoc filters have a look at Pandocs manual pages [https://pandoc.org/filters.html](https://pandoc.org/filters.html). 
These filter allow you to directly embed Tcl code and Dot file code into your documents and produce code output or figures using these code chunks.

* [pandoc-tcl-filter Readme](http://htmlpreview.github.io/?https://github.com/mittelmark/DGTcl/blob/master/pandoc-tcl-filter/Readme.html) 
* [pandoc-tcl-filter Presentation](https://github.com/mittelmark/DGTcl/blob/master/pandoc-tcl-filter/doc/Groth-S-and-T-2021.pdf) 
* [pandoc-tcl-filter Manual](http://htmlpreview.github.io/?https://github.com/mittelmark/DGTcl/blob/master/pandoc-tcl-filter/pandoc-tcl-filter.html) 
* [Gitdown-Download](https://downgit.github.io/#/home?url=https://github.com/mittelmark/DGTcl/tree/master/pandoc-tcl-filter).
* [single file Tcl script pandoc-tcl-filter.tapp build with tpack](https://mittelmark.github.io/release/pandoc-tcl-filter.tapp)

_Please note, that for the installation of this package you need as well the Tcl package [rl_json](https://github.com/RubyLane/rl_json) from Ruby Lane. I will try to make some binaries of this package available for Windows, Linux and OSX._

For other filters have a look at the Pandoc topic list [https://github.com/topics/pandoc-filter](https://github.com/topics/pandoc-filter).

## Tk Widgets

* [dgw](http://htmlpreview.github.io/?https://github.com/mittelmark/DGTcl/blob/master/lib/dgw/dgw.html) - 
  collection of various snit widgets and snit widget adaptors,   
  [Gitdown-Download](https://downgit.github.io/#/home?url=https://github.com/mittelmark/DGTcl/tree/master/lib/dgw).
* [chesschart](http://htmlpreview.github.io/?https://github.com/mittelmark/DGTcl/blob/master/lib/chesschart/chesschart.html) - 
  a pure Tcl/Tk widget to make flowcharts using the chess coordinate system. 
  Here the link to the [chesschart tutorial](http://htmlpreview.github.io/?https://github.com/mittelmark/DGTcl/blob/master/lib/chesschart/doc/intro.html) and the 
  [Gitdown-Download](https://downgit.github.io/#/home?url=https://github.com/mittelmark/DGTcl/tree/master/lib/chesschart).
* [shtmlview::shtmlview](http://htmlpreview.github.io/?https://github.com/mittelmark/DGTcl/blob/master/lib/shtmlview/shtmlview.html) - 
    a pure Tcl/Tk widget to render a reasonable subset of html,   [Gitdown-Download](https://downgit.github.io/#/home?url=https://github.com/mittelmark/DGTcl/tree/master/lib/shtmlview).

## Tcl Libraries / Applications    

* tdot - the Thingy DOT writer. Create DOT files and images for DOT graphs with ease. Syntax is very close to the Graphviz DOT language.
  * [tdot manual](http://htmlpreview.github.io/?https://github.com/mittelmark/DGTcl/blob/master/lib/tdot/tdot.html)
  * [Gitdown-Download](https://downgit.github.io/#/home?url=https://github.com/mittelmark/DGTcl/tree/master/lib/tdot)
  
* tpack - deployment system for Tcl 8.4+ using uncompressed tar file format.  
  * [tpack manual](http://htmlpreview.github.io/?https://github.com/mittelmark/DGTcl/blob/master/apps/tpack/tpack.html) 
  * [Gitdown-Download](https://downgit.github.io/#/home?url=https://github.com/mittelmark/DGTcl/tree/master/apps/tpack)

* mkdoc - extract Markdown documentation from source code files and produce HTML files
  * [mkdoc manual](http://htmlpreview.github.io/?https://github.com/mittelmark/DGTcl/blob/master/lib/mkdoc/mkdoc.html) - Markdown based source code documentation
  * [Gitdown-Download](https://downgit.github.io/#/home?url=https://github.com/mittelmark/DGTcl/tree/master/lib/mkdoc)

* tmdoc - embed and execute Tcl code in Markdown or LaTex documents
  * [tmdoc manual](http://htmlpreview.github.io/?https://github.com/mittelmark/DGTcl/blob/master/lib/tmdoc/tmdoc.html) - literate programming using Tcl for embedding Tcl code into Markdown and LaTeX documents.
  * [tmdoc Markdown based tutorial](http://htmlpreview.github.io/?https://github.com/mittelmark/DGTcl/blob/master/lib/tmdoc/tutorial/tmd.html) - Tutorial about on how to use the package.
  * [tmdoc LaTeX based tutorial](https://github.com/mittelmark/DGTcl/blob/master/lib/tmdoc/latex/tmdoc-template.pdf)
  * [Gitdown-Download](https://downgit.github.io/#/home?url=https://github.com/mittelmark/DGTcl/tree/master/lib/tmdoc)

* tsvg - the Thingy SVG writer. Create SVG files with ease. Either using a Tclish or a SVGish syntax.
  * [tsvg manual](http://htmlpreview.github.io/?https://github.com/mittelmark/DGTcl/blob/master/pandoc-tcl-filter/lib/tsvg/tsvg.html)
  * [Gitdown-Download](https://downgit.github.io/#/home?url=https://github.com/mittelmark/DGTcl/tree/master/pandoc-tcl-filter/lib/tsvg)
  
  

* dgtools - various small snit objects, some are required by the dgw package
  * [argvparse manual](http://htmlpreview.github.io/?https://github.com/mittelmark/DGTcl/blob/master/lib/dgtools/argvparse.html) - command line argument parser
  * [dgtutils manual](http://htmlpreview.github.io/?https://github.com/mittelmark/DGTcl/blob/master/lib/dgtools/dgtutils.html) - command line tools for the dgtools package
  * [recover manual](http://htmlpreview.github.io/?https://github.com/mittelmark/DGTcl/blob/master/lib/dgtools/recover.html) - debugging tool
  * [repo manual](http://htmlpreview.github.io/?https://github.com/mittelmark/DGTcl/blob/master/lib/dgtools/repo.html) - install Tcl package from github or chiselapp
  * [shistory manual](http://htmlpreview.github.io/?https://github.com/mittelmark/DGTcl/blob/master/lib/dgtools/shistory.html) - snit history type to manage lists with history
  * [Gitdown-Download](https://downgit.github.io/#/home?url=https://github.com/mittelmark/DGTcl/tree/master/lib/dgtools)
  
## Download

Currently there is no version based individual download for the different packages. 
You can download the entire project using the github project-zip feature at this link:

* [https://github.com/mittelmark/DGTcl/archive/master.zip](https://github.com/mittelmark/DGTcl/archive/master.zip)

If the project size starts exceeding 1MB I will create individual packages.
