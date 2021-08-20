[dgw](dgw.html) - 
[basegui](basegui.html) - 
[combobox](combobox.html) - 
[drawcanvas](drawcanvas.html) - 
[hyperhelp](hyperhelp.html) - 
[sbuttonbar](sbuttonbar.html) - 
[seditor](seditor.html) - 
[sfilebrowser](sfilebrowser.html) - 
[sfinddialog](sfinddialog.html) - 
[sqlview](sqlview.html) - 
[statusbar](statusbar.html) - 
[tablelist](tablelist.html) - 
[tlistbox](tlistbox.html) - 
[tvmixins](tvmixins.html) - 
[txmixins](txmixins.html) 

# dgw::hyperhelp 0.8.2
    
### Dr. Detlef Groth, Schwielowsee, Germany
    
### 2021-08-20



## NAME

**dgw::hyperhelp**   help system with hypertext facilitites and table of contents outline


## <a name='toc'></a>TABLE OF CONTENTS

 - [SYNOPSIS](#synopsis)
 - [DESCRIPTION](#description)
 - [COMMAND](#command)
 - [METHODS](#methods)
 - [EXAMPLE](#example)
 - [MARKUP LANGUAGE](#formatting)
 - [INSTALLATION](#install)
 - [SEE ALSO](#see)
 - [CHANGES](#changes)
 - [TODO](#todo)
 - [AUTHOR](#authors)
 - [LICENSE AND COPYRIGHT](#license)


## <a name='synopsis'>SYNOPSIS</a>

Usage as package:


    package require dgw::hyperhelp
    dgw::hyperhelp pathName -helpfile filename ?-option value ...?
    pathName help topic


Usage as command line application:


    tclsh hyperhelp.tcl filename ?--commandsubst true?


## <a name='description'>DESCRIPTION</a>

The **dgw::hyperhelp** package is hypertext help system which can be easily embedded into Tk applications. It is based on code
of the Tclers Wiki mainly be Keith Vetter see the [Tclers-Wiki](https://wiki.tcl-lang.org/page/A+Hypertext+Help+System)
The difference of this package to the wiki code is, that it works on external files, provides some `subst` support for variables 
and commands as well as a browser like toolbar. It can be as well used as standalone applications for browsing the help files.
Markup syntax was modified towards Markdown to simplify writing help pages as this is a common documentation language. 
In practice you can create a document which is a valid Markdown document and at the same time an usable help file. 
The file [hyperhelp-markdown-sample.md](hyperhelp-markdown-sample.md) gives an example for such a file.

## <a name='command'>COMMAND</a>

**dgw::hyperhelp** *pathName -helpfile fileName ?-option value ...?*

> creates a new *hyperhelp* widget using the given widget *pathName* and with the given *fileName*.

## <a name='options'>OPTIONS</a>

The **dgw::hyperhelp** snit widget supports the following options which 
should be set only at widget creation:

  __-bottomnavigation__ _boolean_

 > Configures the hyperhelp widget if at the bottom of each help page a textual navigation line should be displayed. Default *false*.

  __-commandsubst__ _boolean_

 > Configures the hyperhelp widget to do substitutions using Tcl commands within the text.
   This might give some security issues if you load help files from dubious sources, 
 although for this most critical commands like file, exec and socket are disaable even if this option is set to true.
 Default: false

  __-dismissbutton__ _boolean_

 > Configures the hyperhelp widget to display at the button a "Dismiss" button. Useful if the help page is direct parent in a toplevel to destroy this toplevel. Default: *false*.

  __-font__ _fontname_

 > Configures the hyperhelp widget to use the given font. 
Fontnames should be given as `[list fontname size]` such as for example 
`\[list {Linux Libertine} 12\]`. If no fontname is given the hyperhelp widget 
tries out a few standard font names on Linux and Windows System. 
If none of those fonts is found, it falls back to "Times New Roman" which should be available on all platforms.

  __-helpfile__ _fileName_

 > Configures the hyperhelp widget with the given helpfile 
   option to be displayed within the widget.

  __-toctree__ _boolean_

 > Should the toc tree widget on the left be displayed. 
   For simple help pages, consisting only of one, two, three pages the 
   treeview widget might be overkill. Please note, that this widget is also 
   not shown if there is no table of contents page, regardless of the _-toctree_ option.
   Must be set at creation time currently.
   Default: *true*

  __-toolbar__ _boolean_

 > Should the toolbar on top be displayed. For simple help pages, 
   consisting only of one, two pages the toolbar might be overkill. 
   Must be set at creation time currently.
   Default: *true*

## <a name='methods'>METHODS</a>

The *hyperhelp* widget provides the following methods:

*pathName* **getPages**

> Returns the page names for the current help file.

*pathName* **getTitle**

> Returns the current topic shown in the hyperhelp browser.

*pathName* **help** *topic*

> Displays the given topic within widget. If the page does not exists an error page is shown.

## <a name='example'>EXAMPLE</a>


    package require dgw::hyperhelp
    set helpfile [file join [file dirname [info script]] hyperhelp-docu.txt]
    set hhelp [dgw::hyperhelp .help -helpfile $helpfile]
    pack $hhelp -side top -fill both -expand true
    $hhelp help overview


## <a name='formatting'>MARKUP LANGUAGE</a>

The Markup language of the hyperhelp widget is similar to Tclers Wiki and Markdown markup.
Here are the most important markup commands. For a detailed description have a look at the 
file `hyperhelp-docu.txt` which contains the hyperhelp documentation with detailed markup rules.

*Page structure:*

A help page in the help file is basically started with the title tag at the beginning of a line and adds with 6 dashes. See here an example for three help pages. 
To shorten links in the document later as well an `alias` can be given afterwards. There is also support for Markdown headers as the last page shows.


    title: Hyperhelp Title Page
    alias: main

    Free text can be written here with standard *Markdown* 
    or ''Wiki'' syntax markup.

    ------
    title: Other Page title
    alias: other
    icon: acthelp16

    Follows more text for the second help page. You can link
    to the [main] page here also.
    ------

    ## <a name="aliasname">Page title</a>
    
    Text for the next page after this Markdown like header, the anchor is now an alis 
    which can be used for links like here [aliasname], the link [Page title] points to the same page.

For the second page an other icon than the standard file icon was given for the help page. This icon is
used for the treeview widget on the left displayed left of the page title.
The following icons are currently available: acthelp16, bookmark, idea, navhome16, help, sheet, folder, textfile.

*"Table of Contents" page:*

There is a special page called "Table of Contents". The unnumbered list, probably nested, of this page will be used
for the navigation outline tree on the left. Below is the example for the contents page which
comes with the hyperhelp help file "hyperhelp-docu.txt". The "Table of Contents" page should be the first page
in your documentation. Please indent only with standard Markdown syntax compatible, so two spaces 
for first level and four spaces for second level.

    title: Table of Contents 
    alias: TOC
      - [Welcome to the Help System]
      - [What's New]
      - Formatting
        - [Basic Formatting]
        - [Aliases]
        - [Lists]
        - [Substitutions]
        - [Images]
        - [Code Blocks]
        - [Indentation]
      - [Creating the TOC]
      - [Key Bindings]
      - [To Do]
    
    -------

*Font styles:*

> - '''bold''' - **bold** (Wiki syntax), \*\*bold\*\* - **bold** (Markdown syntax)
  - ''italic'' - *italic* (Wiki syntax), \*italic\* - *italic* (Markdown syntax)
  - \`code\`  - `code`

*Links:*

> - hyperlinks to other help pages within the same document are created using brackets: `[overview]` -> [overview](#overview)
  - image links, where images will be embedded and shown `[image.png]`
  - also image display and hyperlinks in Markdown format are supported. Therefore `![](image.png)` displays an image and 
    `[Page title](#alias)`  creates a link to the page "Page title"

*Code blocks:*

> - code blocks are started by indenting a line with three spaces
  - the block continues until less than three leading whitespace character are found on the text

*Indentation:*

> - indented blocks are done by using the pipe symbol `|` or the greater symbol  as in Markdown syntax
  - indenting ends on lines without whitespaces as can be seen the following example


     > * indented one with `code text`
       * indented two with **bold text**
       * indented three with *italic text*

     this text is again unindented


*Substitutions:*

> - you can substitute variables and commands within the help page
  - command substition is done using double brackets like in `[[package require dgw::hyperhelp]]` would embed the package version of the hyperhelp package
  - variable substitution is done using the Dollar variable prefix, for instance `$::tcl_patchLevel` would embed the actual Tcl version
  - caution: be sure to not load files from unknown sources, command substitution should not work with commands like `file`, `exec` or `socket`. 
    But anyway only use your own help files

*Lists:*

> - support for list and nested lists using the standard `* item` and `** subitem`` syntax
  - numbered lists can be done with starting a line with `1. ` followed by a white space such as in ` 1. item` and ` 11. subitem`
  - dashed lists can be done with single and double dashes 

*Key bindings:*

> The  hyperhelp  window  provides  some  standard  key bindings to navigate the content:

> * space, next: scroll down
* backspace, prior: scroll up
* Ctrl-k, Ctrl-j: scroll in half page steps up and down
* Ctrl-space, Ctrl-b: scroll down or up
* Ctrl-h, Alt-Left, b: browse back history if possible
* Ctrl-l, Alt-Right: browse forward in history if possible
* n, p: browse forward or backward in page order
* Control-Plus, Control-Minus changes in font-size
* Up, Down, Left, Right etc are used for navigation in the treeview widget

 
## <a name='install'>INSTALLATION</a>

Installation is easy you can install and use the **dgw::hyperhelp** package if you have a working install of:

- the snit package  which can be found in [tcllib - https://core.tcl-lang.org/tcllib](https://core.tcl-lang.org/tcllib)
- the dgtools::shistory package which can be found at the same side as the dgw::hyperhelp package

For installation you copy the complete *dgw* and the *dgtools* folder into a path 
of your *auto_path* list of Tcl or you append the *auto_path* list with the parent dir of the *dgw* directory.
Alternatively you can install the package as a Tcl module by creating a file dgw/hyperhelp-0.8.2.tm in your Tcl module path.
The latter in many cases can be achieved by using the _--install_ option of hyperhelp.tcl. 
Try "tclsh hyperhelp.tcl --install" for this purpose. Please note, that in the latter case you must redo this 
for the `dgtools::shistory` package.

## <a name='demo'>DEMO</a>

Example code for this package can  be executed by running this file using the following command line:


    $ wish hyperhelp.tcl --demo

The example code used for this demo can be seen in the terminal by using the following command line:


    $ wish hyperhelp.tcl --code


## <a name='docu'>DOCUMENTATION</a>

The script contains embedded the documentation in Markdown format. 
To extract the documentation you need that the dgwutils.tcl file is in 
the same directory with the file `hyperhelp.tcl`. 
Then you can use the following command lines:


    $ tclsh hyperhelp.tcl --markdown


This will extract the embedded manual pages in standard Markdown format. You can as well use this markdown output directly to create html pages for the documentation by using the *--html* flag.


    $ tclsh hyperhelp.tcl --html


This will directly create a HTML page `hyperhelp.html` which contains the formatted documentation. 
Github-Markdown can be extracted by using the *--man* switch:


    $ tclsh hyperhelp.tcl --man


The output of this command can be used to feed a markdown processor for conversion into a 
html or pdf document. If you have pandoc installed for instance, you could execute the following commands:


    tclsh ../hyperhelp.tcl --man > hyperhelp.md
    pandoc -i hyperhelp.md -s -o hyperhelp.html
    pandoc -i hyperhelp.md -s -o hyperhelp.tex
    pdflatex hyperhelp.tex


## <a name='see'>SEE ALSO</a>

- [dgw - package](http://chiselapp.com/user/dgroth/repository/tclcode/index)
- [shtmlview - package](http://chiselapp.com/user/dgroth/repository/tclcode/index)

## <a name='todo'>TODO</a>

* some more template files (done)
* tests (done, could be more)
* github url
* fix for broken TOC with four indents needed (done (?))

## <a name='changes'>CHANGES</a>

- 2020-02-01 Release 0.5 - first published version
- 2020-02-05 Release 0.6 - catching errors for missing images and wrong Tcl code inside substitutions
- 2020-02-07 Release 0.7 
    - options _-toolbar_, _-toctree_ for switchable display
    - single page, automatic hiding of toctree and toolbar
    - outline widget only shown if TOC exists
    - adding Control-Plus, Control-Minus for font changes
    - fix indentation and italic within indentation is now possible
    - basic Markdown support 
- 2020-02-16 Release 0.8.0
    - fix for Ctrl.j, Ctrk-k keys
    - disabled default command substitutions
- 2020-02-19 Release 0.8.1
    - removed bug in the within page search
    - insertion cursors for search remains in the widget
    - fixed bug in help page 
- 2020-03-02
    - adding hyperhelp-minimal example to the code
    - adding --sample option to print this to the terminal

## <a name='authors'>AUTHOR(s)</a>

The *dgw::hyperhelp* package was written by Dr. Detlef Groth, Schwielowsee, Germany using Keith Vetters code from the Tclers Wiki as starting point.

## <a name='license'>LICENSE AND COPYRIGHT</a>

The dgw::hyperhelp package version 0.8.2

Copyright (c) 2019-20  Dr. Detlef Groth, E-mail: <detlef(at)dgroth(dot)de>
This library is free software; you can use, modify, and redistribute it
for any purpose, provided that existing copyright notices are retained
in all copies and that this notice is included verbatim in any
distributions.

This software is distributed WITHOUT ANY WARRANTY; without even the
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.



