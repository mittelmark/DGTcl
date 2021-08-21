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

# dgw::sbuttonbar 0.6
    
### Detlef Groth, Schwielowsee, Germany
    
### 2021-08-21


## NAME

**dgw::sbuttonbar** - snit widget for buttonbar with nice buttons having rounded corners, based on old gbutton code from Steve Landers.

## <a name='toc'></a>TABLE OF CONTENTS

 - [SYNOPSIS](#synopsis)
 - [DESCRIPTION](#description)
 - [COMMAND](#command)
 - [WIDGET OPTIONS](#options)
 - [WIDGET COMMANDS](#commands)
 - [EXAMPLE](#example)
 - [INSTALLATION](#install)
 - [DEMO](#demo)
 - [DOCUMENTATION](#docu)
 - [SEE ALSO](#see)
 - [TODO](#todo)
 - [AUTHORS](#authors)
 - [LICENSE](#license)
 
## <a name='synopsis'>SYNOPSIS</a>


    package require dgw::sbuttonbar
    namespace import ::dgw::sbuttonbar
    sbuttonbar pathName options
    pathName cget option
    pathName configure option value
    pathName insert item options
    pathName itemcget item option
    pathName itemconfigure item option value 
    pathName iteminvoke item 


## <a name='description'>DESCRIPTION</a>

**dgw::sbuttonbar** - is a snit widget derived from a Steve Landers old 
gbutton code used in the old Tk Wikit application. 
It displays a nice button with rounded corners, more pleasant than 
the standard Tk button. The button can be configures as usually 
using the _-command_ or the _-state_ option. The _-text_ option is however currently not available as the text per default currently is the given text at button creation time.

## <a name='command'>COMMAND</a>

**dgw::sbuttonbar** *pathName ?options?*

> Creates and configures the **dgw::sbuttonbar**  widget using the Tk window id _pathName_ and the given *options*. 
 
## <a name='options'>WIDGET OPTIONS</a>

__-activefill__ _color_

> the fill color for the buttons if they are hovered

__-bg__ _color_

> the color used as background color for the buttonbar

__-disabledfill__ _color_

> the fill color for the buttons if they are disabled

__-fill__ _color_

> the fill color for the buttons

__-font__ _fontname_

> the font used for the sbuttonbar text

__-padx__ _integer_

> the x-padding between the buttons

__-pady__ _integer_

> the y-padding for all buttons in the buttonbar .

## <a name='commands'>WIDGET COMMANDS</a>

Each **dgw::sbuttonbar** widget supports the following widget commands. 

*pathName* **cget** *option*

> Returns the given dgw::sbuttonbar configuration value for the option.

*pathName* **configure** *option value ?option value?*

> Configures the dgw::sbuttonbar widget with the given options.

*pathName* **insert** *text* *?option value ...?

> Insert the given text as an item into the buttonbar and configures it with the given option. See _-itemconfigure_ for a list of available item options.

*pathName* **itemcget** *text option*

> Returns the given configuration value for the item labeled with text. 
  See _-itemconfigure_ for a list of available item options.

*pathName* **itemconfigure** *text option value ?option value ...?*

> Returns the given configuration value for the item labeled with text. 
  Currently the following item options should be used:

* _-state_ is the button active or disabled, defaults to active
* _-command_ the command to be executed if the button is pressed

*pathName* **iteminvoke** *text*

> Invokes the command configure with option _-command_ for the item labeled with text. 
  Please note, that *iteminvoke* works all well for disabled buttons.


## <a name='example'>EXAMPLE</a>


       proc Cmd {state} {
           global b0
           tk_messageBox -type ok -message "Cmd"
           if {$state == 0} {
               $b0 itemconfigure Forward -state normal
               $b0 itemconfigure Back -state disabled
           } else {
               $b0 itemconfigure Forward -state disabled
               $b0 itemconfigure Back -state normal
           }
       }
       pack [frame .f -bg #fff] -side top -fill x -expand no
       pack [dgw::sbuttonbar .f.t -bg #fff] -side top ;# -fill x -expand no
       set b0 .f.t
       $b0 insert Back  -command [list Cmd 0]
       $b0 insert Forward -command [list Cmd 1] -state disabled
       $b0 insert Home 
       $b0 insert End -command [list puts End]
       $b0 itemconfigure End -state disabled


## <a name='install'>INSTALLATION</a>

Installation is easy you can install and use the **dgw::sbuttonbar** package if you have a working install of:

- the snit package  which can be found in [tcllib - https://core.tcl-lang.org/tcllib](https://core.tcl-lang.org/tcllib)

For installation you copy the complete *dgw* folder into a path 
of your *auto_path* list of Tcl or you append the *auto_path* list with the parent dir of the *dgw* directory.
Alternatively you can install the package as a Tcl module by creating a file dgw/sbuttonbar-0.6.tm in your Tcl module path.
The latter in many cases can be achieved by using the _--install_ option of sbuttonbar.tcl. 
Try "tclsh sbuttonbar.tcl --install" for this purpose.

## <a name='demo'>DEMO</a>

Example code for this package can  be executed by running this file using the following command line:


    $ wish sbuttonbar.tcl --demo

The example code used for this demo can be seen in the terminal by using the following command line:


    $ wish sbuttonbar.tcl --code


## <a name='docu'>DOCUMENTATION</a>

The script contains embedded the documentation in Markdown format. To extract the documentation you should use the following command line:


    $ tclsh sbuttonbar.tcl --markdown


This will extract the embedded manual pages in standard Markdown format. You can as well use this markdown output directly to create html pages for the documentation by using the *--html* flag.


    $ tclsh sbuttonbar.tcl --html


This will directly create a HTML page `sbuttonbar.html` which contains the formatted documentation. 
Github-Markdown can be extracted by using the *--man* switch:


    $ tclsh sbuttonbar.tcl --man


The output of this command can be used to feed a markdown processor for conversion into a 
man page, html or pdf document. If you have pandoc installed for instance, you could execute the following commands:


    # man page
    tclsh sbuttonbar.tcl --man | pandoc -s -f markdown -t man - > sbuttonbar.n
    # html 
    tclsh sbuttonbar.tcl --man > sbuttonbar.md
    pandoc -i sbuttonbar.md -s -o sbuttonbar.html
    # pdf
    pandoc -i sbuttonbar.md -s -o sbuttonbar.tex
    pdflatex sbuttonbar.tex


## <a name='see'>SEE ALSO</a>

- [dgw - package homepage: http://chiselapp.com/user/dgroth/repository/tclcode/index](http://chiselapp.com/user/dgroth/repository/tclcode/index)

## <a name='todo'>TODO</a>

* probably as usually more documentation
* more, real, tests
* github url for putting the code

## <a name='authors'>AUTHOR</a>

The **sbuttonbar** widget was written by Detlef Groth, Schwielowsee, Germany.

## <a name='license'>LICENSE</a>

dgw::sbuttonbar widget dgw::sbuttonbar, version 0.6.

Copyright (c) 

   * 2001-2002 by Steve Landers <steve (at) digital-smarties(dot)com>
   * 2004 Uwe Koloska <uwe (at) koloro(dot)de>
   * 2004-2019  Dr. Detlef Groth, <detlef (at) dgroth(dot)de>

This library is free software; you can use, modify, and redistribute it
for any purpose, provided that existing copyright notices are retained
in all copies and that this notice is included verbatim in any
distributions.

This software is distributed WITHOUT ANY WARRANTY; without even the
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.



