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

# dgw::tlistbox 0.2
    
### Detlef Groth, Schwielowsee, Germany
    
### 2019-10-21


## NAME

**dgw::tlistbox** - a tablelist based listbox with multiline text support and a search entry.

## <a name='toc'></A>TABLE OF CONTENTS

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
 - [AUTHOR](#authors)
 - [COPYRIGHT](#copyright)
 - [LICENSE](#license)
 
## <a name='synopsis'>SYNOPSIS</a>


    package require dgw::tlistbox
    namespace import ::dgw::tlistbox
    tlistbox pathName options
    pathName configure -searchentry boolean
    pathName configure -browsecmd script
    pathName itemconfigure index -option value
    pathName itemcget index -option
    pathName iteminsert index string


## <a name='description'>DESCRIPTION</a>

**tlistbox** - a listbox widget based on the Csaba Nemethis tablelist widget with support for multiline text which can be wrapped.
As **tlistbox** is based on the tablelist widget, it suppports the standard options and commands of tablelist.
The **tlistbox** widget is a two column tablelist widget where the second column is hidden to allow invisible 
storage of data belonging to a **tlistbox** item or a cell in tablelist terms.

For convinience, and to make the widget more **listbox** like, a few options and methods were added in addition to the tablelist options. 
Beside of standard listbox functionality the user of this widget can display on top of the **tlistbox** a search entry widget in order to 
dynamically search the **tlistbox**.

## <a name='command'>COMMAND</a>

**tlistbox** *pathName ?options?*

> Creates and configures a new tlistbox widget  using the Tk window id _pathName_ and the given *options*. 
 
## <a name='options'>WIDGET OPTIONS</a>



  __-browsecmd__ _script_ 

 > Set a command if the user double clicks an entry in the listbox or presses the `Return` key if the widget has the focus.
   The widget path and the index of the item getting the event are appended to the script call as function arguments. 
   So the implementation of the script should have two arguments in the parameter list as shown in the following example:

       proc click {tbl idx} {
          puts [$tbl itemcget $idx -text]
       }
       tlistbox .tl -browsecmd click
Please note that the tablelist options __-listvariable__ should be here a nested list, 
where each sublist should have at maximum only two values, the first value will be in the first visible cell, the second list value
will be placed in the invisible cell. The latter can be retrieved via *pathName itemconfigure index -data*.


  __-searchentry__ _boolean_ 

this also in agreement with the manual pages of the standard listbox widget also an **item**.

 > The user can enter text in the search widget for searching the **tlistbox** widget, pressing `Return` in the *entry* widget 
 invokes the script supplied with the *-browsecmd* option.
 


## <a name='commands'>WIDGET COMMANDS</a>

> Configure the **item** (first cell of the row) indicated by *index* with the given value. 
All options mentioned in *cellconfigure* of the tablelist manual can be used, such as *-text*, *-foreground*, *-background*.
*pathName* **itemcget** *index option*

> Retrieves the given option for the item (first cell of the row). See *itemconfigure* for an explanation of the options.

*pathName* **itemconfigure** *index option value ?option value ...?*

*pathName* **iteminsert** *index string*

Further two listbox like methods are implemented for convinience to configure individual cells, in listbox terms also called **items**. 
Please note, that you can also use in a similar way the *cellconfigure* and *cellcget* functions of the tablelist widget.


> Insert the given string at position index into the **tlistbox** value. 
This is just a convinience function which does the same as *tablelist insert index {"string"}*
But here you don't need to add add extra braces. Note, that you can not insert data text into the hidden column with this method and you can only add one element per function call.
Example:

         tlistbox .tl
         .tl insert end {"Hello Text 1"}       ;# inserts all
         .tl insert end "Hello Text 2"         ;# only inserts Hello
         .tl iteminsert end "Hello Text 3"     ;# inserts all 

## <a name='example'>EXAMPLE</a>

     package require dgw::tlistbox
     namespace import ::dgw::tlistbox
     
     set data { {"B. Gates:\nThe Windows Operating System" "Hidden Data"} 
           {"L. Thorwalds: The Linux Operating System"} 
           {"C. Nemethi's: Tablelist Programmers Guide"}
           {"J. Ousterhout: The Tcl/Tk Programming Language"}
     }
     proc click {tbl idx} {
         puts [$tbl itemcget $idx -text]
     }
     tlistbox .tl -listvariable data -browsecmd click -searchentry true
     lappend data {"A. Anonymous: Some thing else matters"}
     .tl insert end {"L. Wall: The Perl Programming Language" "1987"}
     pack .tl -side top -fill both -expand yes
     .tl itemconfigure end -foreground red
     .tl itemconfigure end -data Hello
     puts "Hello? [.tl itemcget end -data] - yes!"


![tlistbox example](../img/tlistbox-01.png "dgw::tlistbox example")

![tlistbox search](../img/tlistbox-02.png "dgw::tlistbox search example")

## <a name='install'>INSTALLATION</a>

Installation is easy you can easily install and use this **tlistbox** package if you have a working install of:

- the snit package  which can be found in [tcllib](https://core.tcl-lang.org/tcllib/doc/trunk/embedded/index.md)
- the tablelist package which can be found on [C. Nemethi's webpage](http://www.nemethi.de/tablelist/)

If you have those Tcl packages installed, you can either use the tlistbox package by sourcing it with: 
`source /path/to/tlistbox.tcl`, by copying the folder `dgw` to a path belonging to your Tcl `$auto_path` variable or by installing it as an Tcl-module. 
To do this, make a copy of `tlistbox.tcl` to a file like `tlistbox-0.1.tm` and put this file into a folder named `dgw` where the parent folder belongs to your module path.
You must now adapt eventually your Tcl-module path by using in your Tcl code the command: 
`tcl::tm::path add /parent/dir/` of the `dgw` directory. 
For details of the latter consult see the [manual page of tcl::tm](https://www.tcl.tk/man/tcl/TclCmd/tm.htm).

Alternatively there is an install option you can use as well. 
Try `tclsh tlistbox.tcl --install` which should perform the procedure described above automatically. 
This requires eventually the setting of an environment variables like if you have no write access to all 
your module paths. For instance on my computer I have the following entry in my `.bashrc`


    export TCL8_6_TM_PATH=/home/groth/.local/lib/tcl8.6


If I execute `tclsh tlistbox.tcl --install` the file `tlistbox.tcl` will be copied to <br/>
`/home/groth/.local/lib/tcl8.6/dgw/tlistbox-0.1.tm` and is thereafter available for a<br/> `package require dgw::tlistbox`.

## <a name='demo'>DEMO</a>

Example code for this package can  be executed by running this file using the following command line:


    $ wish tlistbox.tcl --demo

The example code used for this demo can be seen in the terminal by using the following command line:


    $ wish tlistbox.tcl --code


## <a name='docu'>DOCUMENTATION</a>

The script contains embedded the documentation in Markdown format. To extract the documentation you should use the following command line:


    $ tclsh tlistbox.tcl --markdown


This will extract the embedded manual pages in standard Markdown format. You can as well use this markdown output directly to create html pages for the documentation by using the *--html* flag.


    $ tclsh tlistbox.tcl --html


This will directly create a HTML page `tlistbox.html` which contains the formatted documentation. 
Github-Markdown can be extracted by using the *--man* switch:


    $ tclsh tlistbox.tcl --man


The output of this command can be used to feed a markdown document for conversion into a markdown 
processor for instance to convert it into a man page a html or a pdf document you could execute the following commands:


    # man page
    tclsh tlistbox.tcl --man | pandoc -s -f markdown -t man - > tlistbox.n
    # html page
    tclsh ../tlistbox.tcl --man > tlistbox.md
    pandoc -i tlistbox.md -s -o tlistbox.html
    # pdf
    pandoc -i tlistbox.md -s -o tlistbox.tex
    pdflatex tlistbox.tex


## <a name='see'>SEE ALSO</a>

- [tablelist man page: http://www.nemethi.de/tablelist/tablelistWidget.html](http://www.nemethi.de/tablelist/tablelistWidget.html)


## <a name='todo'>TODO</a>

* probably as usually more documentation
* github url for putting the code

## <a name='authors'>AUTHORS</a>

The **tlistbox** widget is based on Csaba Nemethi's great tablelist widget.

The **tlistbox** widget was written with his help by Detlef Groth, Schwielowsee, Germany.

## <a name='copyright'>COPYRIGHT</a>

Copyright (c) 2019  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de

## <a name='license'>LICENSE</a>

Single-column listbox widget with multiline text and search entry,  dgw::tlistbox widget, version 0.2.

Copyright (c) 2019  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de

This library is free software; you can use, modify, and redistribute it
for any purpose, provided that existing copyright notices are retained
in all copies and that this notice is included verbatim in any
distributions.

This software is distributed WITHOUT ANY WARRANTY; without even the
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.



