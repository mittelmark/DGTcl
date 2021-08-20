#' ---
#' documentclass: scrartcl
#' title: dgw::tlistbox __PKGVERSION__
#' author: Detlef Groth, Schwielowsee, Germany
#' date: 2019-10-21
#' geometry: "left=2.2cm,right=2.2cm,top=1cm,bottom=2.2cm"
#' output: pdf_document
#' ---
#' 
#' ## NAME
#'
#' **dgw::tlistbox** - a tablelist based listbox with multiline text support and a search entry.
#'
#' ## <a name='toc'></A>TABLE OF CONTENTS
#' 
#'  - [SYNOPSIS](#synopsis)
#'  - [DESCRIPTION](#description)
#'  - [COMMAND](#command)
#'  - [WIDGET OPTIONS](#options)
#'  - [WIDGET COMMANDS](#commands)
#'  - [EXAMPLE](#example)
#'  - [INSTALLATION](#install)
#'  - [DEMO](#demo)
#'  - [DOCUMENTATION](#docu)
#'  - [SEE ALSO](#see)
#'  - [TODO](#todo)
#'  - [AUTHOR](#authors)
#'  - [COPYRIGHT](#copyright)
#'  - [LICENSE](#license)
#'  
#' ## <a name='synopsis'>SYNOPSIS</a>
#' 
#' ```
#' package require dgw::tlistbox
#' namespace import ::dgw::tlistbox
#' tlistbox pathName options
#' pathName configure -searchentry boolean
#' pathName configure -browsecmd script
#' pathName itemconfigure index -option value
#' pathName itemcget index -option
#' pathName iteminsert index string
#' ```
#'
#' ## <a name='description'>DESCRIPTION</a>
#' 
#' **tlistbox** - a listbox widget based on the Csaba Nemethis tablelist widget with support for multiline text which can be wrapped.
#' As **tlistbox** is based on the tablelist widget, it suppports the standard options and commands of tablelist.
#' The **tlistbox** widget is a two column tablelist widget where the second column is hidden to allow invisible 
#' storage of data belonging to a **tlistbox** item or a cell in tablelist terms.
#' 
#' For convinience, and to make the widget more **listbox** like, a few options and methods were added in addition to the tablelist options. 
#' Beside of standard listbox functionality the user of this widget can display on top of the **tlistbox** a search entry widget in order to 
#' dynamically search the **tlistbox**.


#'
#' ## <a name='command'>COMMAND</a>
#'
#' **tlistbox** *pathName ?options?*
#' 
#' > Creates and configures a new tlistbox widget  using the Tk window id _pathName_ and the given *options*. 
#'  
#' ## <a name='options'>WIDGET OPTIONS</a>
#' 
#' The **tlistbox** widget is a two column widget based on the tablelist widget of C. Nemethi where the second column is 
#' hidden, but usable for data storage. It therefore supports the standard options and commands of tablelist, 
#' i.e. all of the options mentioned in the *tablelist* manual in the entries for *configure*, *rowconfigure* and 
#' *columnconfigure* are available. As in a **tlistbox** widget a row consist of only one visible tablelist cell we call 
#' this also in agreement with the manual pages of the standard listbox widget also an **item**.
#' 
#' The **tlistbox** widgets adds the following options in addition to the options available for the tablelist widget:
    
package require Tk
package require snit
package require tablelist
package provide dgw::tlistbox 0.2
package require dgw::dgwutils


namespace eval ::dgw::tlistbox {}

snit::widget ::dgw::tlistbox {
    #' 
    #'   __-browsecmd__ _script_ 
    #' 
    #'  > Set a command if the user double clicks an entry in the listbox or presses the `Return` key if the widget has the focus.
    #'    The widget path and the index of the item getting the event are appended to the script call as function arguments. 
    #'    So the implementation of the script should have two arguments in the parameter list as shown in the following example:
    #' 
    #' ```
    #'    proc click {tbl idx} {
    #'       puts [$tbl itemcget $idx -text]
    #'    }
    #'    tlistbox .tl -browsecmd click
    #' ```
    option -browsecmd ""
    #'   __-searchentry__ _boolean_ 
    #' 
    #'  > Should a search entry widget displayed on top of the **tlistbox** widget. Default: false
    #'
    #'  > The user can enter text in the search widget for searching the **tlistbox** widget, pressing `Return` in the *entry* widget 
    #'  invokes the script supplied with the *-browsecmd* option.
    option -searchentry false
    #'  
    #' Please note that the tablelist options __-listvariable__ should be here a nested list, 
    #' where each sublist should have at maximum only two values, the first value will be in the first visible cell, the second list value
    #' will be placed in the invisible cell. The latter can be retrieved via *pathName itemconfigure index -data*.
    #' 
    delegate option * to tbl
    delegate method * to tbl
    variable tbl
    variable entry
    variable oldWidth 0
    variable evar ""
    variable lasttext ""
    constructor {args} {
        install tbl using ::tablelist::tablelist $win.tbl -columns {0 Main 0 Data}  \
              -stripebackground "#ddeeff" -showhorizseparator true  \
              -showlabels false -showseparator true -resizablecolumn true
        $tbl configcolumns 0 -wrap true
        $tbl configcolumns 1 -hide true
        $self configurelist $args
        install entry using entry $win.entry -textvariable [myvar evar]
        if {$options(-searchentry)} {
            pack $entry -side top -fill x -expand false
        }
        pack $tbl -side top -fill both -expand yes
        bind $win <Configure> +[mymethod Resize]
        bind all <Double-1> +[mymethod Browse %W]
        bind all <KeyPress-Return> +[mymethod Browse %W]
        bind $entry <Key> [mymethod Search %A %K]

        
    }
    #' 
    #' ## <a name='commands'>WIDGET COMMANDS</a>
    #' 
    #' Each **tlistbox** widgets supports the tablelist widget commands. 
    #' Further two listbox like methods are implemented for convinience to configure individual cells, in listbox terms also called **items**. 
    #' Please note, that you can also use in a similar way the *cellconfigure* and *cellcget* functions of the tablelist widget.
    #'
    #'
    #' *pathName* **itemcget** *index option*
    #' 
    #' > Retrieves the given option for the item (first cell of the row). See *itemconfigure* for an explanation of the options.
    
    method itemcget {idx key} {
        if {$key eq "-data"} {
            return [$tbl cellcget $idx,1 -text]
        } else {
            return [$tbl cellcget $idx,0 $key] 
        }
    }
    #' 
    #' *pathName* **itemconfigure** *index option value ?option value ...?*
    #' 
    #' > Configure the **item** (first cell of the row) indicated by *index* with the given value. 
    #' All options mentioned in *cellconfigure* of the tablelist manual can be used, such as *-text*, *-foreground*, *-background*.
    #' In addition to the tablelist cell options for the **tlistbox** widget an option *-data* is provided which allows storage of text data in the hidden second column of the *tlistbox* widget.
    #' Beside numerical indices as well *end* can be used as index.
    #' 
    method itemconfigure {idx args} {
        foreach {key val} $args {
            if {$key eq "-data"} {
                return [$tbl cellconfigure $idx,1 -text $val]
            } else {
                return [$tbl cellconfigure $idx,0 $key $val]
            }
        }
    }
    #' 
    #' *pathName* **iteminsert** *index string*
    #' 
    #' > Insert the given string at position index into the **tlistbox** value. 
    #' This is just a convinience function which does the same as *tablelist insert index {"string"}*
    #' But here you don't need to add add extra braces. Note, that you can not insert data text into the hidden column with this method and you can only add one element per function call.
    #' Example:
    #' 
    #' ```
    #'      tlistbox .tl
    #'      .tl insert end {"Hello Text 1"}       ;# inserts all
    #'      .tl insert end "Hello Text 2"         ;# only inserts Hello
    #'      .tl iteminsert end "Hello Text 3"     ;# inserts all 
    #' ```
    method iteminsert {idx str} {
       $tbl insert $idx [list $str]
    }
    onconfigure -searchentry value {
        if {![info exists entry]} {
            set options(-entry) $value
            return
        }
        if {$value eq $options(-searchentry)} {
            return
        } elseif {$value} {
            pack $entry -before $tbl -fill x -expand false
        } else {
            pack forget $entry 
        }
        set options(-entry) $value
    }
    method Resize {} {
        set width [winfo width $win]
        if {$width == $oldWidth} {
            return
        }

        set oldWidth $width
        set charWidth [font measure [$tbl cget -font] -displayof $tbl "0"]
        set deltaWidth [expr {2 * ($charWidth + [$tbl cget -borderwidth] +
                                   [$tbl cget -highlightthickness])}]
        incr width -$deltaWidth
        if {$width > 0} {
            $tbl columnconfigure 0 -width -$width
        }
    }
    method Browse {w} {
        if {$options(-browsecmd) ne ""} {
            if {[winfo parent $w] eq $tbl || [winfo parent $w] eq [$tbl bodypath]} {
                $options(-browsecmd) $tbl [$tbl curselection]
            }
        }
    }
    method Search {key symbol} {
        set stext $evar
        if {$lasttext eq $stext && $symbol eq "Return"} {
            if {[info exists options(-browsecmd)]} {
                $options(-browsecmd) $tbl [$tbl curselection]
            }
            return
        } elseif {$symbol eq "BackSpace"} {
            set stext [string range $stext 0 end-1]
        } else {
            set stext $stext$key
        }
        set sel false
        $tbl selection clear 0 [$tbl index last]
        for {set i 0} {$i < [$tbl index end]} {incr i 1} {
            set text [$tbl cellcget $i,0 -text]
            if  {[string match -nocase "*$stext*" $text]} {
                $tbl rowconfigure $i -hide false
                if {!$sel} {
                    $tbl selection set $i $i
                    set sel true
                }
            } else {
                $tbl rowconfigure $i -hide true
            }
        }
        set lasttext $stext
    }

}
#' 
#' ## <a name='example'>EXAMPLE</a>
#' ```
#'  package require dgw::tlistbox
#'  namespace import ::dgw::tlistbox
#'  
#'  set data { {"B. Gates:\nThe Windows Operating System" "Hidden Data"} 
#'        {"L. Thorwalds: The Linux Operating System"} 
#'        {"C. Nemethi's: Tablelist Programmers Guide"}
#'        {"J. Ousterhout: The Tcl/Tk Programming Language"}
#'  }
#'  proc click {tbl idx} {
#'      puts [$tbl itemcget $idx -text]
#'  }
#'  tlistbox .tl -listvariable data -browsecmd click -searchentry true
#'  lappend data {"A. Anonymous: Some thing else matters"}
#'  .tl insert end {"L. Wall: The Perl Programming Language" "1987"}
#'  pack .tl -side top -fill both -expand yes
#'  .tl itemconfigure end -foreground red
#'  .tl itemconfigure end -data Hello
#'  puts "Hello? [.tl itemcget end -data] - yes!"
#' ```
#'
#' ![tlistbox example](../img/tlistbox-01.png "dgw::tlistbox example")
#'
#' ![tlistbox search](../img/tlistbox-02.png "dgw::tlistbox search example")

#'
#' ## <a name='install'>INSTALLATION</a>
#'
#' Installation is easy you can easily install and use this **tlistbox** package if you have a working install of:
#'
#' - the snit package  which can be found in [tcllib](https://core.tcl-lang.org/tcllib/doc/trunk/embedded/index.md)
#' - the tablelist package which can be found on [C. Nemethi's webpage](http://www.nemethi.de/tablelist/)
#' 
#' If you have those Tcl packages installed, you can either use the tlistbox package by sourcing it with: 
#' `source /path/to/tlistbox.tcl`, by copying the folder `dgw` to a path belonging to your Tcl `$auto_path` variable or by installing it as an Tcl-module. 
#' To do this, make a copy of `tlistbox.tcl` to a file like `tlistbox-0.1.tm` and put this file into a folder named `dgw` where the parent folder belongs to your module path.
#' You must now adapt eventually your Tcl-module path by using in your Tcl code the command: 
#' `tcl::tm::path add /parent/dir/` of the `dgw` directory. 
#' For details of the latter consult see the [manual page of tcl::tm](https://www.tcl.tk/man/tcl/TclCmd/tm.htm).
#'
#' Alternatively there is an install option you can use as well. 
#' Try `tclsh tlistbox.tcl --install` which should perform the procedure described above automatically. 
#' This requires eventually the setting of an environment variables like if you have no write access to all 
#' your module paths. For instance on my computer I have the following entry in my `.bashrc`
#'
#' ```
#' export TCL8_6_TM_PATH=/home/groth/.local/lib/tcl8.6
#' ```
#' 
#' If I execute `tclsh tlistbox.tcl --install` the file `tlistbox.tcl` will be copied to <br/>
#' `/home/groth/.local/lib/tcl8.6/dgw/tlistbox-0.1.tm` and is thereafter available for a<br/> `package require dgw::tlistbox`.
#'
#' ## <a name='demo'>DEMO</a>
#'
#' Example code for this package can  be executed by running this file using the following command line:
#'
#' ```
#' $ wish tlistbox.tcl --demo
#' ```

#' The example code used for this demo can be seen in the terminal by using the following command line:
#'
#' ```
#' $ wish tlistbox.tcl --code
#' ```
#'
#' ## <a name='docu'>DOCUMENTATION</a>
#'
#' The script contains embedded the documentation in Markdown format. To extract the documentation you should use the following command line:
#' 
#' ```
#' $ tclsh __BASENAME__.tcl --markdown
#' ```
#'
#' This will extract the embedded manual pages in standard Markdown format. You can as well use this markdown output directly to create html pages for the documentation by using the *--html* flag.
#' 
#' ```
#' $ tclsh __BASENAME__.tcl --html
#' ```
#' 
#' This will directly create a HTML page `__BASENAME__.html` which contains the formatted documentation. 
#' Github-Markdown can be extracted by using the *--man* switch:
#' 

#' ```
#' $ tclsh tlistbox.tcl --man
#' ```
#'
#' The output of this command can be used to feed a markdown document for conversion into a markdown 
#' processor for instance to convert it into a man page a html or a pdf document you could execute the following commands:
#'
#' ```
#' # man page
#' tclsh __BASENAME__.tcl --man | pandoc -s -f markdown -t man - > __BASENAME__.n
#' # html page
#' tclsh ../__BASENAME__.tcl --man > __BASENAME__.md
#' pandoc -i __BASENAME__.md -s -o __BASENAME__.html
#' # pdf
#' pandoc -i __BASENAME__.md -s -o __BASENAME__.tex
#' pdflatex __BASENAME__.tex
#' ```
#' 
#' ## <a name='see'>SEE ALSO</a>
#'
#' - [tablelist man page: http://www.nemethi.de/tablelist/tablelistWidget.html](http://www.nemethi.de/tablelist/tablelistWidget.html)
#'
#  Todo - dgw - **D**etlef **G**roth's **w**idgets
#'
#' ## <a name='todo'>TODO</a>
#'
#' * probably as usually more documentation
#' * github url for putting the code
#'
#' ## <a name='authors'>AUTHORS</a>
#'
#' The **tlistbox** widget is based on Csaba Nemethi's great tablelist widget.
#' 
#' The **tlistbox** widget was written with his help by Detlef Groth, Schwielowsee, Germany.
#'
#' ## <a name='copyright'>COPYRIGHT</a>
#'
#' Copyright (c) 2019  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de
#'
#' ## <a name='license'>LICENSE</a>
# LICENSE START
#' 
#' Single-column listbox widget with multiline text and search entry,  __PKGNAME__ widget, version __PKGVERSION__.
#'
#' Copyright (c) 2019  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de
#' 
#' This library is free software; you can use, modify, and redistribute it
#' for any purpose, provided that existing copyright notices are retained
#' in all copies and that this notice is included verbatim in any
#' distributions.
#' 
#' This software is distributed WITHOUT ANY WARRANTY; without even the
#' implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#' 
# LICENSE END
namespace eval dgw {
    namespace export tlistbox
}

# test code if run standalone

if {[info exists argv0] && $argv0 eq [info script]} {
    if {[llength $argv] == 1 && [lindex $argv 0] eq "--version"} {    
        puts [dgw::getVersion [info script]]
        destroy .
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "-d" || [lindex $argv 0] eq "--demo"} {
        # DEMO START
        package require Tk
        package require tablelist
        package require snit
        catch {
            # to make demo work well within the file where the package
            # is actually defined, so here within tlistbox.tcl
            package require dgw::tlistbox
        }
        namespace import ::dgw::tlistbox
        set data { {"B. Gates:\nThe Windows Operating System" "Hidden data"} 
            {"L. Thorwalds: The Linux Operating System"} 
            {"C. Nemethi: Tablelist Programmers Guide"}
            {"J. Ousterhout: The Tcl/Tk Programming Language" "1988"}
        }
        proc click {tbl idx} {
            puts [$tbl rowcget $idx -text]
        }
        proc lclick {} {
            puts "label clicked"
        }
        tlistbox .tl -listvariable data -browsecmd click -searchentry true
        lappend data {"A. Anonymous: Some thing else matters"}
        pack .tl -side top -fill both -expand yes
        pack [label .lb -text label]
        bind .lb <Double-1> lclick
        .tl configure -searchentry false
        after 1000
        update idletasks
        after 1000
        .tl configure -searchentry true
        .tl itemconfigure end -foreground red
        .tl itemconfigure end -data Hello
        puts "is hello hello?? [.tl itemcget end -data]"
        .tl insert end {"L. Wall: The Perl Programming Language" "1987"}
        .tl insert end {"Hello Text 1"}     ;#inserts all
        .tl insert end "Hello Text 2"       ;# only inserts Hello
        .tl iteminsert end "Hello Text 3"   ;# inserts all 
        # DEMO END
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--code"} {
        set filename [info script]
        dgw::displayCode $filename
    } elseif {[llength $argv] == 1 && ([lindex $argv 0] eq "--license" || [lindex $argv 0] eq "--man" || [lindex $argv 0] eq "--html" || [lindex $argv 0] eq "--markdown")} {
        dgw::manual [lindex $argv 0] [info script]
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--install"} {
        dgw::install [info script]
    } else {
        destroy .
        puts "\n    ---------------------------------"
        puts "     The tlistbox package for Tcl/Tk"
        puts "    ---------------------------------\n"
        puts "Copyright (c) 2019  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de\n"
        puts "License: MIT - License see manual page"
        puts "\nThe tlistbox package provides a listbox widget with multiline text support"
        puts "and a search entry. It is used for programming graphical user interfaces with"
        puts "the Tcl/Tk Programming language"
        puts ""
        puts "Usage: [info nameofexe] [info script] option\n"
        puts "    Valid options are:\n"
        puts "        --help    : printing out this help page"
        puts "        --demo    : starting a demo"
        puts "        --code    : show code of the demo"
        puts "        --license : printing the license to the terminal"
        puts "        --install : install tlistbox as Tcl module"        
        puts "        --man     : printing the man page in Github-markdown to the terminal"
        puts "        --markdown: printing the man page in simple markdown to the terminal"
        puts "        --html    : printing the man page in html code to the terminal"
        puts "                    if the Markdown package from tcllib is available"
        puts "        --version : printing the package version to the terminal"                
        puts ""
        puts "    The --man option can be used to generate the documentation pages as well with"
        puts "    a command like: "
        puts ""
        puts "    tclsh tlistbox.tcl --man | pandoc -t html -s > temp.html && surf temp.html\n"

    }
}

