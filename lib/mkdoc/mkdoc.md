
# mkdoc::mkdoc 0.4
    
### Dr. Detlef Groth, Schwielowsee, Germany
    
### 2020-11-09



## NAME

**mkdoc::mkdoc**  - Tcl package and command line application to extract and format 
embedded programming documentation from source code files written in Markdown and 
optionally converts them into HTML.

## <a name='toc'></a>TABLE OF CONTENTS

 - [SYNOPSIS](#synopsis)
 - [DESCRIPTION](#description)
 - [COMMAND](#command)
     - [mkdoc::mkdoc](#mkdoc)
     - [mkdoc::run](#run)
 - [EXAMPLE](#example)
 - [BASIC FORMATTING](#format)
 - [INSTALLATION](#install)
 - [SEE ALSO](#see)
 - [CHANGES](#changes)
 - [TODO](#todo)
 - [AUTHOR](#authors)
 - [LICENSE AND COPYRIGHT](#license)

## <a name='synopsis'>SYNOPSIS</a>

Usage as package:


    package require mkdoc::mkdoc
    mkdoc::mkdoc inputfile outputfile ?-html|-md|-pandoc -css file.css?


Usage as command line application for extraction of Markdown comments prefixed with `#'`:


    mkdoc inputfile outputfile ?--html|--md|--pandoc --css file.css?


Usage as command line application for conversion of Markdown to HTML:


    mkdoc inputfile.md outputfile.html ?--css file.css?


## <a name='description'>DESCRIPTION</a>

**mkdoc::mkdoc**  extracts embedded Markdown documentation from source code files and  as well converts Markdown output to HTML if desired.
The documentation inside the source code must be prefixed with the `#'` character sequence.
The file extension of the output file determines the output format. File extensions can bei either `.md` for Markdown output or `.html` for html output. The latter requires the tcllib Markdown extension to be installed. If the file extension of the inputfile is *.md* and file extension of the output files is *.html* there will be simply a conversion from a Markdown to a HTML file.

The file `mkdoc.tcl` can be as well directly used as a console application. An explanation on how to do this, is given in the section [Installation](#install).

## <a name='command'>COMMAND</a>

 <a name="mkdoc" />
**mkdoc::mkdoc** *infile outfile ?-mode -css file.css?*

> Extracts the documentation in Markdown format from *infile* and writes the documentation 
   to *outfile* either in Markdown  or HTML format. 

>  - *-infile filename* - file with embedded markdown documentation
  - *-outfile filename* -  name of output file extension
  - *-html* - (mode) outfile should be a html file, not needed if the outfile extension is html
  - *-md* - (mode) outfile should be a Markdown file, not needed if the outfile extension is md
  - *-pandoc* - (mode) outfile should be a pandoc Markdown file with YAML header, needed even if the outfile extension is md
  - *-css cssfile* if outfile mode is html uses the given *cssfile*
    
> If the *-mode* flag  (one of -html, -md, -pandoc) is not given, the output format is taken from the file extension of the output file, either *.html* for HTML or *.md* for Markdown format. This deduction from the filetype can be overwritten giving either `-html` or `-md` as command line flags. If as mode `-pandoc` is given, the Markdown markup code as well contains the YAML header.
  If infile has the extension .md than conversion to html will be performed, outfile file extension
  In this case must be .html. If output is html a *-css* flag can be given to use the given stylesheet file instead of the default style sheet embedded within the mkdoc code.
 
> Example:

> ```
package require mkdoc::mkdoc
mkdoc::mkdoc mkdoc.tcl mkdoc.html
mkdoc::mkdoc mkdoc.tcl mkdoc.rmd -md
> ```

<a name="run" />
**mkdoc::run** *infile* 

> Source the code in infile and runs the examples in the documentation section
   written with Markdown documentation. Below follows an example section which can be
   run with `tclsh mkdoc.tcl mkdoc.tcl -run`

## <a name="example">EXAMPLE</a>


    puts "Hello mkdoc package"
    puts "I am in the example section"



## <a name='format'>BASIC FORMATTING</a>

For a complete list of Markdown formatting commands consult the basic Markdown syntax at [https://daringfireball.net](https://daringfireball.net/projects/markdown/syntax). 
Here just the most basic essentials  to create documentation are described.
Please note, that formatting blocks in Markdown are separated by an empty line, and empty line in this documenting mode is a line prefixed with the `#'` and nothing thereafter. 

**Title and Author**

Title and author can be set at the beginning of the documentation in a so called YAML header. 
This header will be as well used by the document converter [pandoc](https://pandoc.org)  to handle various options for later processing if you extract not HTML but Markdown code from your documentation.

A YAML header starts and ends with three hyphens. Here is the YAML header of this document:


    #' ---
    #' title: mkdoc - Markdown extractor and formatter
    #' author: Dr. Detlef Groth, Schwielowsee, Germany
    #' ---


Those four lines produce the two lines on top of this document. You can extend the header if you would like to process your document after extracting the Markdown with other tools, for instance with Pandoc.

You can as well specify an other style sheet, than the default by adding
the following style information:


    #' ---
    #' title: mkdoc - Markdown extractor and formatter
    #' author: Dr. Detlef Groth, Schwielowsee, Germany
    #' output:
    #'   html_document:
    #'     css: tufte.css
    #' ---


Please note, that the indentation is required and it is two spaces.

**Headers**

Headers are prefixed with the hash symbol, single hash stands for level 1 heading, double hashes for level 2 heading, etc.
Please note, that the embedded style sheet centers level 1 and level 3 headers, there are intended to be used
for the page title (h1), author (h3) and date information (h3) on top of the page.

    #' ## <a name="sectionname">Section title</a>
    #'
    #' Some free text that follows after the required empty 
    #' line above ...


This produces a level 2 header. Please note, if you have a section name `synopsis` the code fragments thereafer will be hilighted different than the other code fragments. You should only use level 2 and 3 headers for the documentation. Level 1 header are reserved for the title.

**Lists**

Lists can be given either using hyphens or stars at the beginning of a line.


    #' - item 1
    #' - item 2
    #' - item 3


Here the output:

- item 1
- item 2
- item 3

A special list on top of the help page could be the table of contents list. Here is an example:


    #' ## Table of Contents
    #'
    #' - [Synopsis](#synopsis)
    #' - [Description](#description)
    #' - [Command](#command)
    #' - [Example](#example)
    #' - [Authors](#author)


This will produce in HTML mode a clickable hyperlink list. You should however create
the name targets using html code like so:


    ## <a name='synopsis'>Synopsis</a> 


**Hyperlinks**

Hyperlinks are written with the following markup code:


    [Link text](URL)


Let's link to the Tcler's Wiki:

    [Tcler's Wiki](https://wiki.tcl-lang.org/)


produces: [Tcler's Wiki](https://wiki.tcl-lang.org/)

**Indentations**

Indentations are achieved using the greater sign:


    #' Some text before
    #'
    #' > this will be indented
    #'
    #' This will be not indented again


Here the output:

Some text before

> this will be indented

This will be not indented again

Also lists can be indented:


    > - item 1
      - item 2
      - item 3


produces:

> - item 1
  - item 2
  - item 3

**Fontfaces**

Italic font face can be requested by using single stars or underlines at the beginning 
and at the end of the text. Bold is achieved by dublicating those symbols:
Monospace font appears within backticks.
Here an example:


    I am _italic_ and I am __bold__! But I am programming code: `ls -l`


> I am _italic_ and I am __bold__! But I am programming code: `ls -l`

**Code blocks**

Code blocks can be started using either three or more spaces after the #' sequence 
or by embracing the code block with triple backticks on top and on bottom. Here an example:


    #' ```
    #' puts "Hello World!"
    #' ```


Here the output:


    puts "Hello World!"


**Images**

If you insist on images in your documentation, images can be embedded in Markdown with a syntax close to links.
The links here however start with an exclamation mark:


    ![image caption](filename.png)


The source code of mkdoc.tcl is a good example for usage of this source code 
annotation tool. Don't overuse the possibilities of Markdown, sometimes less is more. 
Write clear and concise, don't use fancy visual effects.

**Includes**

mkdoc in contrast to standard markdown as well support includes. Using the `#' #include "filename.md"` syntax 
it is possible to include other markdown files. This might be useful for instance to include the same 
header or a footer in a set of related files.

## <a name='install'>INSTALLATION</a>

The mkdoc::mkdoc package can be installed either as command line application or as a Tcl module. It requires the Markdown package from tcllib to be installed.

Installation as command line application can be done by copying the `mkdoc.tcl` as 
`mkdoc` to a directory which is in your executable path. You should make this file executable using `chmod`. There exists as well a standalone script which does not need already installed tcllib package.  You can download this script named: `mkdoc-version.app` from the [chiselapp release page](https://chiselapp.com/user/dgroth/repository/tclcode/wiki?name=releases).

Installation as Tcl module is achieved by copying the file `mkdoc.tcl` to a place 
which is your Tcl module path as `mkdoc/mkdoc-0.1.tm` for instance. See the [tm manual page](https://www.tcl.tk/man/tcl8.6/TclCmd/tm.htm)

## <a name='see'>SEE ALSO</a>

- [tcllib](https://core.tcl-lang.org/tcllib/doc/trunk/embedded/index.md) for the Markdown and the textutil packages
- [dgtools](https://chiselapp.com/user/dgroth/repository/tclcode) project for example help page
- [pandoc](https://pandoc.org) - a universal document converter
- [Ruff!](https://github.com/apnadkarni/ruff) Ruff! documentation generator for Tcl using Markdown syntax as well

## <a name='changes'>CHANGES</a>

- 2019-11-19 Relase 0.1
- 2019-11-22 Adding direct conversion from Markdown files to HTML files.
- 2019-11-27 Documentation fixes
- 2019-11-28 Kit version
- 2019-11-28 Release 0.2 to fossil
- 2019-12-06 Partial R-Roxygen/Markdown support
- 2020-01-05 Documentation fixes and version information
- 2020-02-02 Adding include syntax
- 2020-02-26 Adding stylesheet option --css 
- 2020-02-26 Adding files pandoc.css and dgw.css
- 2020-02-26 Making standalone file using pkgDeps and mk_tm
- 2020-02-26 Release 0.3 to fossil
- 2020-02-27 support for \_\_DATE\_\_, \_\_PKGNAME\_\_, \_\_PKGVERSION\_\_ macros  in Tcl code based on package provide line
- 2020-09-01 Roxygen2 plugin
- 2020-11-09 argument --run supprt
- 2020-11-10 Release 0.4


## <a name='todo'>TODO</a>

- extract Roxygen2 documentation codes from R files (done)
- standalone files using mk_tm module maker (done, just using cat ;)
- support for \_\_PKGVERSION\_\_ and \_\_PKGNAME\_\_ replacements at least in Tcl files and via command line for other file types (done)

## <a name='authors'>AUTHOR(s)</a>

The **mkdoc::mkdoc** package was written by Dr. Detlef Groth, Schwielowsee, Germany.

## <a name='license'>LICENSE AND COPYRIGHT</a>

Markdown extractor and converter mkdoc::mkdoc, version 0.4

Copyright (c) 2019-20  Dr. Detlef Groth, E-mail: <detlef(at)dgroth(dot)de>

This library is free software; you can use, modify, and redistribute it
for any purpose, provided that existing copyright notices are retained
in all copies and that this notice is included verbatim in any
distributions.

This software is distributed WITHOUT ANY WARRANTY; without even the
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.



