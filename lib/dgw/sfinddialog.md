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

# dgw::sfinddialog 0.4
    
### Detlef Groth, Schwielowsee, Germany
    
### 2021-08-20


## NAME

**dgw::sfinddialog** - snit toplevel dialog for text search in other widgets. A implementation to search a text widget inbuild.

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
 - [AUTHOR](#authors)
 - [COPYRIGHT](#copyright)
 - [LICENSE](#license)
 
## <a name='synopsis'>SYNOPSIS</a>


    package require dgw::sfinddialog
    namespace import ::dgw::sfinddialog
    sfinddialog pathName options
    pathName configure -findcmd script
    pathName configure -findnextcmd script
    pathName configure -textvariable varname
    pathName configure -nocase boolean
    pathName configure -word boolean
    pathName configure -regexp boolean
    pathName configure -title string
    pathName cancel cmd options
    pathName entry cmd options
    pathName find cmd options
    pathName next cmd options


## <a name='description'>DESCRIPTION</a>

**sfinddialog** - is a toplevel search dialog to perform a text search in other widgets.
As such functionalitye is mostly required for the Tk text widget, a implementation to search a Tk text widget is embedded within the **sfinddialog** widget. 
The buttons and the text entry are exposed to the programmer, so the programmer has for instance the possibility to manually insert a value in the search entry or to click a button programmatically.

## <a name='command'>COMMAND</a>

**sfinddialog** *pathName ?options?*

> Creates and configures the sfinddialog toplevel widget using the Tk window id _pathName_ and the given *options*. 
 
## <a name='options'>WIDGET OPTIONS</a>






  __-findcmd__ _script_ 

 > Set a command if the user clicks on the find button. Please note, that if you would like to add search functionality to a Tk text
   widget, just use the _-textwidget_ option described below.

  __-findnext__ _script_ 

 > Set a command if the clicks on the next button. Please note, that if you would like to add search functionality to a Tk text
   widget, just use the _-textwidget_ option described below.

        global textvar
        testing mFind
        proc Next {} {
           global textvar
           wm title .s "Next $textvar words: [.s cget -word]"
           puts "Next $textvar words: [.s cget -word]"
        }
        proc Find {} {
           global textvar
           wm title .s "Find $textvar words: [.s cget -word]"
           puts "Find $textvar words: [.s cget -word]"
        }
        set textvar test
        dgw::sfinddialog .s -nocase 1 -findnextcmd Next -findcmd Find -textvariable textvar
        wm title .s "Search "


 __-forward__ _boolean_ 

> Checkbox configuration to indicate the search direction. This value can be modified by the user later by clicking the checkbutton belonging to this option.

 __-nocase__ _boolean_ 

> Sets the default value for the checkbox related to case insensitive search. This value can be modified by the user later by clicking the checkbutton belonging to this option.

 __-regexp__ _boolean_ 

> Checkbox configuration to indicate if the search string should be used as regular expression. This value can be modified by the user later by clicking the checkbutton.

  __-textvariable__ _varname_ 

 > Configures the entry text to be synced with the variable  _varname_.

  __-textwidget__ _pathname_ 

 > The existing textwidget will get functionality to be searched by the sfinddialog. Here is an example on how to use it for a text widget:

         pack [text .text]
         dgw::sfinddialog .st -nocase 0 -textwidget .text -title "Search"
         .text insert end "Hello\n"
         .text insert end "Hello World!\n"
         .text insert end "Hello Search Dialog!\n"
         .text insert end "End\n"
         .text insert end "How are your?\n"
         .text insert end "I am not prepared :(\n"
       
         bind .text <Control-f> {wm deiconify .st}

  __-title__ _string_ 

 > Sets the title of the sfinddialog toplevel.

  __-word__ _boolean_ 

 > Checkbox configuration to indicate that the search should be performed on complete words. 
   This value can be modified by the user later by clicking the checkbutton belonging to this option. 
   Please note that this works currently only together with regular expressions, even if the option is not set in the dialog.

## <a name='commands'>WIDGET COMMANDS</a>

*pathName* **cancel** *cmd ?option ...?*

> This function provides access for the programmer to the cancel button. For instance 
to close the dialog it is possible to use: _pathName cancel invoke_. See the button manual page for other commands.

*pathName* **cget** *option*

> Returns the given sfinddialog configuration value for the option.

*pathName* **configure** *option value ?option value?*

> Configures the sfinddialog toplevel with the given options.

*pathName* **entry** *cmd ?option ...?*

> This function provides access for the programmer to the embedded entry widget. For instance 
to get the current text you could use:  _pathName entry get_. See the entry manual page for other commands available for the entry widget.

*pathName* **find** *cmd ?option ...?*

> This function provides access for the programmer to the find button. For instance 
to execute the search it is possible to use: _pathName find invoke_. See the button manual page for other commands.

*pathName* **findnext** *cmd ?option ...?*

> This function provides access for the programmer to the findnext button. For instance 
to execute the next search it is possible to use: _pathName findnext invoke_. See the button manual page for other commands.


Each **sfinddialog** toplevel supports the following widget commands. 

## <a name='example'>EXAMPLE</a>


    proc Test_Find {} {
       global textvar
       # testing mFind
       proc Next {} {
           global textvar
           wm title .s "Next $textvar words: [.s cget -word]"
           puts "Next $textvar words: [.s cget -word]"
       }
       proc Find {} {
           global textvar
           wm title .s "Find $textvar words: [.s cget -word]"
          puts "Find $textvar words: [.s cget -word]"
       }
       
       set textvar test
       dgw::sfinddialog .s -nocase 1 -findnextcmd Next -findcmd Find -textvariable textvar
       wm title .s "Search "
      
       .s find configure -bg red
       set btn [.s find]
       $btn configure -bg blue
       bind .s <Control-f> {wm deiconify .s}
       pack [button .btn -text "Open find dialog again ..." -command {wm deiconify .s}]
       pack [text .text]
       dgw::sfinddialog .st -nocase 0 -textwidget .text -title "Search"
       .text insert end "Hello\n"
       .text insert end "Hello World!\n"
       .text insert end "Hello Search Dialog!\n"
       .text insert end "End\n"
       .text insert end "How are your?\n"
       .text insert end "I am not prepared :(\n"
       
       bind .text <Control-f> {wm deiconify .st}
    }
    Test_Find


## <a name='install'>INSTALLATION</a>

Installation is easy you can install and use the **dgw::sfinddialog** package if you have a working install of:

- the snit package  which can be found in [tcllib - https://core.tcl-lang.org/tcllib](https://core.tcl-lang.org/tcllib)

If you have the snit Tcl packages installed, you can either use the sfinddialog package by sourcing it with: 
`source /path/to/sfinddialog.tcl`, by copying the folder `dgw` to a path belonging to your Tcl `$auto_path` variable or by installing it as a Tcl module. 
To do the latter, make a copy of `sfinddialog.tcl` to a file like `sfinddialog-0.4.tm` and put this file into a folder named `dgw` where the parent folder belongs to your module path.
You must eventually adapt your Tcl-module path by using in your Tcl code the command: 
`tcl::tm::path add /parent/dir/` of the `dgw` directory. 
For details of the latter, consult the [manual page of tcl::tm](https://www.tcl.tk/man/tcl/TclCmd/tm.htm).

Alternatively there is an `--install` option you can use as well. 
Try: `tclsh sfinddialog.tcl --install` which should perform the procedure described above automatically. 
This requires eventually the setting of an environment variables like if you have no write access to all 
your module paths. For instance on my computer I have the following entry in my `.bashrc`


    export TCL8_6_TM_PATH=/home/groth/.local/lib/tcl8.6


If I execute `tclsh sfinddialog.tcl --install` the file `sfinddialog.tcl` will be copied to <br/>
`/home/groth/.local/lib/tcl8.6/dgw/sfinddialog-0.1.tm` and is thereafter available for a<br/> `package require dgw::sfinddialog`.

## <a name='demo'>DEMO</a>

Example code for this package can  be executed by running this file using the following command line:


    $ wish sfinddialog.tcl --demo

The example code used for this demo can be seen in the terminal by using the following command line:


    $ wish sfinddialog.tcl --code


## <a name='docu'>DOCUMENTATION</a>

The script contains embedded the documentation in Markdown format. To extract the documentation you should use the following command line:


    $ tclsh sfinddialog.tcl --markdown


This will extract the embedded manual pages in standard Markdown format. You can as well use this markdown output directly to create html pages for the documentation by using the *--html* flag.


    $ tclsh sfinddialog.tcl --html


This will directly create a HTML page `sfinddialog.html` which contains the formatted documentation. 
Github-Markdown can be extracted by using the *--man* switch:


    $ tclsh sfinddialog.tcl --man


The output of this command can be used to feed a markdown processor for conversion into a 
man page, a html or a pdf document. If you have pandoc installed for instance, you could execute the following commands:


    # man page
    tclsh sfinddialog.tcl --man | pandoc -s -f markdown -t man - > sfinddialog.n
    # html page
    tclsh ../sfinddialog.tcl --man > sfinddialog.md
    pandoc -i sfinddialog.md -s -o sfinddialog.html
    # pdf
    pandoc -i sfinddialog.md -s -o sfinddialog.tex
    pdflatex sfinddialog.tex


## <a name='see'>SEE ALSO</a>

- [dgw - package homepage: http://chiselapp.com/user/dgroth/repository/tclcode/index](http://chiselapp.com/user/dgroth/repository/tclcode/index)

## <a name='todo'>TODO</a>

* probably as usually more documentation
* more, real, tests
* github url for putting the code

## <a name='authors'>AUTHOR</a>

The **sfinddialog** widget was written by Detlef Groth, Schwielowsee, Germany.

## <a name='copyright'>COPYRIGHT</a>

Copyright (c) 2019  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de

## <a name='license'>LICENSE</a>

Text search dialog widget dgw::sfinddialog, version 0.4.

Copyright (c) 2019  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de

This library is free software; you can use, modify, and redistribute it
for any purpose, provided that existing copyright notices are retained
in all copies and that this notice is included verbatim in any
distributions.

This software is distributed WITHOUT ANY WARRANTY; without even the
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.



