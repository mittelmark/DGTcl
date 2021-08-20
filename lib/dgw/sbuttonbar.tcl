#
#   sbuttonbar.tcl
#
#   Copyright (c) 2001-2002 by Steve Landers <steve (at) digital-smarties.com>
#   Copyright (c) 2004 by Dr. Detlef Groth <detlef (at) dgroth.de>
#                      porting to the snit framework
#   Copyright (c) 2004 by Uwe Koloska <uwe (at) koloro.de>
#                      removing the errors taken from the original
#   Copyright (c) 2019 by Dr. Detlef Groth <detlef (at) dgroth.de>
#                      get rid of gbutton, moved into the dgw namespace as dgw::sbuttonbar
#   Copyright (c) 2020 by Dr. Detlef Groth <detlef (at) dgroth.de>
#                      Version 0.6 documentation updates, man page support 
# starting source page: https://wiki.tcl-lang.org/page/snitbutton
#' ---
#' documentclass: scrartcl
#' title: dgw::sbuttonbar __PKGVERSION__
#' author: Detlef Groth, Schwielowsee, Germany
#' output: pdf_document
#' ---
#' 
#' ## NAME
#'
#' **dgw::sbuttonbar** - snit widget for buttonbar with nice buttons having rounded corners, based on old gbutton code from Steve Landers.
#'
#' ## <a name='toc'></a>TABLE OF CONTENTS
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
#'  - [AUTHORS](#authors)
#'  - [LICENSE](#license)
#'  
#' ## <a name='synopsis'>SYNOPSIS</a>
#' 
#' ```
#' package require dgw::sbuttonbar
#' namespace import ::dgw::sbuttonbar
#' sbuttonbar pathName options
#' pathName cget option
#' pathName configure option value
#' pathName insert item options
#' pathName itemcget item option
#' pathName itemconfigure item option value 
#' pathName iteminvoke item 
#' ```
#'
#' ## <a name='description'>DESCRIPTION</a>
#' 
#' **dgw::sbuttonbar** - is a snit widget derived from a Steve Landers old 
#' gbutton code used in the old Tk Wikit application. 
#' It displays a nice button with rounded corners, more pleasant than 
#' the standard Tk button. The button can be configures as usually 
#' using the _-command_ or the _-state_ option. The _-text_ option is however currently not available as the text per default currently is the given text at button creation time.
#'
#' ## <a name='command'>COMMAND</a>
#'
#' **dgw::sbuttonbar** *pathName ?options?*
#' 
#' > Creates and configures the **dgw::sbuttonbar**  widget using the Tk window id _pathName_ and the given *options*. 
#'  
#' ## <a name='options'>WIDGET OPTIONS</a>
#' 

package require Tk
package require snit
package require dgw::dgwutils
package provide dgw::sbuttonbar 0.6

namespace eval dgw {}
snit::widget dgw::sbuttonbar {
    variable canvas ""
    variable over
    variable numbut 0
    variable wid
    variable ht
    variable command
    #' __-activefill__ _color_
    #'
    #' > the fill color for the buttons if they are hovered
    #' 
    option -activefill ""
    
    #' __-bg__ _color_
    #'
    #' > the color used as background color for the buttonbar
    #' 
    option -bg ""
    
    #' __-disabledfill__ _color_
    #'
    #' > the fill color for the buttons if they are disabled
    #' 
    option -disabledfill ""
    
    #' __-fill__ _color_
    #'
    #' > the fill color for the buttons
    #' 
    option -fill ""
    
    #' __-font__ _fontname_
    #'
    #' > the font used for the sbuttonbar text
    #' 
    option -font ""
    
    #' __-padx__ _integer_
    #'
    #' > the x-padding between the buttons
    #' 
    option -padx 0
    
    #' __-pady__ _integer_
    #'
    #' > the y-padding for all buttons in the buttonbar .
    #' 
    option -pady 0
    
    
    typevariable numobj 0
    typevariable textopts
    typevariable imageopts
    typevariable button
    typevariable up_img ""
    typevariable down_img ""
    typevariable disabled_img ""
    typevariable path ""
    
    constructor {args} {
        #installhull $win
        $self configurelist $args
        set ht [expr {[image height $up_img] + 2*$options(-pady)}]
        set wid [expr {[image width $up_img] + 2*$options(-padx)}]
        set canvas [canvas $win.c$numobj -height $ht -width $wid \
                        -highlightthickness 0]
        if { $options(-bg) ne ""} {
            $canvas configure -background $options(-bg)
        }
        pack $canvas -padx 0 -pady 0 ;#-fill x -expand false 
        incr numobj
     }

     proc path {dir} {
        set path $dir
     }

     proc init_opts {canv text} {
        foreach arg [lsort [$canv itemconfigure img_$text]] {
            set imageopts([lindex $arg 0]) 1
        }
        foreach arg [lsort [$canv itemconfigure txt_$text]] {
            set textopts([lindex $arg 0]) 1
        }
     }

     proc locate {text} {
        return $button($text)
     }

     proc modify {text args} {
        if {[info exists button($text)]} {
            #puts "$text  $args"
            eval $button($text) config $text $args
        }
     }
     method insert {text args} {
         $self new $text
         $button($text) config {*}$args
     }
     proc cget {text opt} {
        if {[info exists button($text)]} {
            eval $button($text) get $text $opt
        }
    }
    #' ## <a name='commands'>WIDGET COMMANDS</a>
    #' 
    #' Each **dgw::sbuttonbar** widget supports the following widget commands. 
    #' 
    #' *pathName* **cget** *option*
    #' 
    #' > Returns the given dgw::sbuttonbar configuration value for the option.
    #'
    #' *pathName* **configure** *option value ?option value?*
    #' 
    #' > Configures the dgw::sbuttonbar widget with the given options.
    #'
    #' *pathName* **insert** *text* *?option value ...?
    #' 
    #' > Insert the given text as an item into the buttonbar and configures it with the given option. See _-itemconfigure_ for a list of available item options.
    #'

    method insert {text args} {
        $self new $text
        $self config $text {*}$args
    }
    
    #' *pathName* **itemcget** *text option*
    #' 
    #' > Returns the given configuration value for the item labeled with text. 
    #'   See _-itemconfigure_ for a list of available item options.
    #'
    method itemcget {item option} {
        $self get $item {*}$option
    }
    
    #' *pathName* **itemconfigure** *text option value ?option value ...?*
    #' 
    #' > Returns the given configuration value for the item labeled with text. 
    #'   Currently the following item options should be used:
    #'
    #' * _-state_ is the button active or disabled, defaults to active
    #' * _-command_ the command to be executed if the button is pressed
    #'
    method itemconfigure {item args} {
        $self config $item {*}$args
    }
    #' *pathName* **iteminvoke** *text*
    #' 
    #' > Invokes the command configure with option _-command_ for the item labeled with text. 
    #'   Please note, that *iteminvoke* works all well for disabled buttons.
    #' 
    method iteminvoke {text} {
        
        $self release $text
    }
    # private method , public is insert
    method new {text {cmd ""}} {
        set x [expr {$numbut * $wid + $options(-padx)}]
        set y $options(-pady)
        set tag0 [$canvas create image $x $y -image $up_img -tag img_$text \
                      -anchor nw]
        $canvas bind $tag0 <ButtonPress-1> [list $self press $text down]
        $canvas bind $tag0 <ButtonRelease-1> [list $self release $text]
        set command($text) $cmd
        set x [expr {$x + $wid/2 - $options(-padx)}]
        set y [expr {$y + $ht/2 - $options(-pady)}]
        set tag1 [$canvas create text $x $y -tag txt_$text -anchor center \
                      -text $text]
        $canvas bind $tag1 <ButtonPress-1> [list $self press $text down]
        $canvas bind $tag1 <ButtonRelease-1> [list $self release $text]
        if {$disabled_img != ""} {
            $canvas itemconfigure $tag0 -disabledimage $disabled_img
        }
        if {$options(-fill) != ""} {
            $canvas itemconfigure $tag1 -fill $options(-fill)
        }
        if {$options(-activefill) != ""} {
            $canvas itemconfigure $tag1 -activefill $options(-activefill)
        }
        if {$options(-disabledfill) != ""} {
            $canvas itemconfigure $tag1 -disabledfill $options(-disabledfill)
        }
        if {$options(-font) != ""} {
            $canvas itemconfigure $tag1 -font $options(-font)
        }
        set button($text) [list $self]
        incr numbut
        if {[array size textopts] == 0} {
            init_opts $canvas $text
        }
        $self size
     }
     # private method, public interface is itemconfigure
     method config {text args} {
        foreach {opt arg} $args {
            if {$opt == "-command"} {
                set command($text) $arg
            } else {
                if {[info exists imageopts($opt)]} {
                    $canvas itemconfigure img_$text $opt $arg
                }
                if {[info exists textopts($opt)]} {
                    $canvas itemconfigure txt_$text $opt $arg
                }
            }
        }
     }
     # private method, public interface is itemcget
     method get {text opt} {
        set result ""
        if {[info exists textopts($opt)]} {
            set result [$canvas itemcget txt_$text $opt]
        } elseif {[info exists imageopts($opt)]} {
            set result [$canvas itemcget img_$text $opt]
        }
        return $result
     }

     method press {text event} {
        if {[string equal $event up]} {
            $canvas itemconfigure img_$text -image $up_img
        } else {
            $canvas itemconfigure img_$text -image $down_img
        }
     }

     method release {text}  {
        $self press $text up
        # Do we need to make this "after idle", in case the command is
        # long running?  Perhaps it is best done in the calling
        # application if needed
        uplevel #0 $command($text)
     }

     method size {} {
        $canvas configure -width [expr {$numbut * $wid}]
     }
     typeconstructor {
        set path [file dirname [info script]]
        set up_img [image create photo -data {
            R0lGODlhRQAeAMYAAP////v7++zs7N/f39XV1dHR0c3NzcLCwrm5uby8vMfH
            x7S0tL29vcDAwMHBwbi4uLe3t8vLy8/Pz9DQ0Ojo6MbGxtjY2PLy8rOzs+Tk
            5Lu7u66urtPT0/b29q+vr6urq8PDw6SkpKampra2trq6upycnKCgoKWlpaen
            p6mpqZiYmJubm6GhoZeXl7+/v56enqKioqioqJ2dnZ+fn62traOjo6ysrJaW
            ltra2pGRkYyMjLGxsb6+vtTU1MrKysTExP//////////////////////////
            ////////////////////////////////////////////////////////////
            ////////////////////////////////////////////////////////////
            ////////////////////////////////////////////////////////////
            /////////////////////////////////////////////////yH5BAEKAB0A
            LAAAAABFAB4AAAf+gB2Cg4SFhoeIiYqLjI2Oj5CRkpOUlZaXiwIDBAUFBp+g
            oaKjpKWdBAMClQIFBwgJCa+ws7S1tre4CQw8Lgc9qpEDCgsICAwNDsnKy8zN
            zs/LDQ0MEQOQAwcPEA4REhPf4OHi4+Tl4RISPg4uCtaNFNkPFRMW9fb3+Pn6
            +/wTFewUGhXAgKGBBAL8EipcaI9AhGkFGGXQsAEDtwkcCHDYyLGjx48gQ24k
            QFLjhIcIXGRYVMDDBw8JHFSYSbOmzZs4c+qs8KPBA4IRFYH4EEKEBwwjHihd
            yrSp06dQoxKkkcKDAkUCSHwoYeLECRQoUoBNQbas2bNo06o1C/aECRP+H0gA
            O0RhhAgVK0ro3cu3r9+/gAP3XaEibkBEFEiwWNGisePHkCNLnkxZ8goWJA4f
            yuDiRYnKoEOLjlzihcpEGRTAMKGitevXsGPLnk1btgkYClYiLhBDxgzBwIML
            5ztDRowCmg1RIEDixQwTfn8Pny74+YwXJAgkL6RJAQ0VMNy+HU++vPnz6NN3
            haGCRru5mwu4qNGiBA0bMfLr38+/v////dlAw2c1uFCAboloYgAJMdygQgkw
            0EDQhBRWaOGFGE5IAwwlqHBDDCQYkAojFOCwIA013JCDDiy26OKLMMYoo4s5
            3FADDSHisB1qJoJAwg405FfDkEQWaeSRSCZTmR8NO5AAggE4IPjOAJ6A4AIJ
            JIyg5ZZcdunll2Bi6cKTBQywIyMCZLBJJ6W06eabpwyQAXyRCEBBBmoOoOee
            fPbp55+AypkBBXRiYuihiCb6SCAAOw==
        }]
        set disabled_img [image create photo -data {
            R0lGODlhRQAeAKUAAP////39/ff39/Hx8e3t7ezs7Orq6uXl5eLi4uPj4+Tk
            5Ofn5+Dg4Onp6eHh4evr6/X19e/v7/n5+d/f3/T09N3d3fv7+9zc3Obm5tnZ
            2dra2tvb29bW1tfX19TU1NXV1djY2NPT09HR0c/Pz97e3v//////////////
            ////////////////////////////////////////////////////////////
            /////////////////////////////////yH5BAEKAD8ALAAAAABFAB4AAAb+
            wJ9wSCwaj8ikcslsOp/QqHRKrVqvzkLBwO16v+CwWIv9FQ6IRCKtbrvf8Lhc
            rVAcqgsGIn3o+/+AgYKDggkNUgcODgcND46PkJGSk5STDQcKC1CJDgsPEaCh
            oqOkpaanDwuZWRMTBw8Ep7KztKEElwkFTQgVro0FBFrCw8TFxsfCBMrBD5cI
            CkwFFRcVCQcL2Nna29zd3t8LGImtukoYFxkavQyK7e7v8PHy8w6tFRsVmkoI
            FxwdGek0bNAgcIPBgwgTKlzI8CDBDB06XECwhIEGDx84aNzIsaPHjyBDdvzg
            YeISBCBIeljJsqXLlzBjynz5AQRFJQo0ztzJs+e+S43QlCwA0cGn0aMwO4DQ
            l6TABn8io0qdyrEDhw3l9vmz2pEr1a8hI1q9uWRBBQ8gIIpdy7at27dwxWYA
            4SFfkwIKMnjgMK2h37+AqXHwkEFB1iUGEGwIsRdEr1aQI0ueTLmyPRCDQ2xA
            YABK4goZQogYQbq06dOoU6s2LSJEhgqcpRjAgIDEvQ0Ac+vezbu37wwGK5BA
            gKHzlC0YFOxhwLy58+fQo0vfo6D4YSpaxGjfzp1Mme/gw4sfTx5LEAA7
        }
                         ]
        set down_img [image create photo -data {
            R0lGODlhRQAeAMYAAP////n5+eXl5dLS0sXFxb+/v7i4uKWrsZGfsZGluIul
            xYufxZGlxZelv5+lsb/FxauxuIuXsZGly5Gry5ery5eluLG4uIufuIWfv6W4
            2au/2bG/2aW40pelxd/f34WfxZ+x0rjL3+zs7IuXq36Xv7jF37/L39nZ2Z+f
            q3eRuLHF36Wlq/Ly8oWRpXGLuHeRv5ex0ouXpaurq3eLq2SFsWuFuH6XxX6f
            xXGRv2uLuH6RsbGxsZ+fn1d3sV1+uGSFuGuFv2uLv5eXl1FxsVF3uFd3uGR+
            q0pxuKWlpWt3l1F3v0pxv3d+i1d+xUpxxYWFi2R3pVF+0kp30nF3hV13v1F+
            2Up32Up+2YuLi2RxhWR+v1eF2X5+fmRxd113pWSR312R31eL34WFhWtrcWRx
            fmR3l2uR0nGX38vLy2tra2RkZF1dXZGRkf//////////////////////////
            /////////////////////////////////////////////////yH5BAEKAH8A
            LAAAAABFAB4AAAf+gH+Cg4SFhoeIiYqLjI2Oj5CRkpOUlZaXiwIDBAUFBp+g
            oaKjpKWdBAMClQIFBwgJCgsKs7S1tre4uQoMDQ4HD6qRAxARCwsSExTKy8zN
            zs/QzBMTFRYDkAMHFxgUGRob4OHi4+Tl5uIaGhwUHRDXjR7aHyAbIfb3+Pn6
            +/z9GyDtPDASUWAEiQkaSoQwwbChw4cQI0qMGKJEBmoFRCw6gSIFiW4bVJRQ
            QbKkyZMoU6okWaLlyA0XF6w4sahACxcvFFAAwbOnz59AgwodCgLGhA8kYhRQ
            JELGDBo1Xti48aGq1atYs2rdytWGDRw5dOzQiEgADxc9fPz4AQRIkLb+QeLK
            nUu3rt27c9v+8OHDBY9ghzwIqTGESJHDiBMrXsy4sWPFRIb4FXhIhAceRogc
            2cy5s+fPoEOLBk3ECA8PZAuJOIEkiZIlsGPLnk27tu3btZUkQXIiNaHVO5g0
            cUK8uPHjyJMrX568CZMdvSt7KPAEShQp2LNr3869u/fv26NAeVIANSIPBHhM
            oVLFivv3V97Ln0+/vv36V6pQmcKDAOVDmuyARRZabFHFgQgmqOCCDDboYBVb
            aJEFFjukkshqBSDBRRdefAFGGCCGKOKIJJZoIolgfOFFF1wgUUB0iWhiAA9i
            jEFGGVqYccaOPPbo449ABrmjGVqUQcYYYvCXYICFTHmAxoxYcJGGGmtUaeWV
            WGap5ZZXqpEGF1goiYZ5i6z2pAw8sIGFGGJw4eabcMYp55x0sokFGzzIYAAa
            MA7kwQCeyIAEDzwIYeihiCaq6KKMEoqEngUMQKYjIghwwiadlKLpppyeMsAJ
            Avj2SKUenHDpAKimquqqrLbq6qcneBAqJiLUauutuOaq6665YuLrr4gEAgA7
        }
                     ]
     }

}

#' 
#' ## <a name='example'>EXAMPLE</a>
#'
#' ```
#'    proc Cmd {state} {
#'        global b0
#'        tk_messageBox -type ok -message "Cmd"
#'        if {$state == 0} {
#'            $b0 itemconfigure Forward -state normal
#'            $b0 itemconfigure Back -state disabled
#'        } else {
#'            $b0 itemconfigure Forward -state disabled
#'            $b0 itemconfigure Back -state normal
#'        }
#'    }
#'    pack [frame .f -bg #fff] -side top -fill x -expand no
#'    pack [dgw::sbuttonbar .f.t -bg #fff] -side top ;# -fill x -expand no
#'    set b0 .f.t
#'    $b0 insert Back  -command [list Cmd 0]
#'    $b0 insert Forward -command [list Cmd 1] -state disabled
#'    $b0 insert Home 
#'    $b0 insert End -command [list puts End]
#'    $b0 itemconfigure End -state disabled
#' ```
#'
#' ## <a name='install'>INSTALLATION</a>
#'
#' Installation is easy you can install and use the **dgw::sbuttonbar** package if you have a working install of:
#'
#' - the snit package  which can be found in [tcllib - https://core.tcl-lang.org/tcllib](https://core.tcl-lang.org/tcllib)
#' 
#' For installation you copy the complete *dgw* folder into a path 
#' of your *auto_path* list of Tcl or you append the *auto_path* list with the parent dir of the *dgw* directory.
#' Alternatively you can install the package as a Tcl module by creating a file dgw/__BASENAME__-__PKGVERSION__.tm in your Tcl module path.
#' The latter in many cases can be achieved by using the _--install_ option of __BASENAME__.tcl. 
#' Try "tclsh __BASENAME__.tcl --install" for this purpose.
#' 
#' ## <a name='demo'>DEMO</a>
#'
#' Example code for this package can  be executed by running this file using the following command line:
#'
#' ```
#' $ wish __BASENAME__.tcl --demo
#' ```

#' The example code used for this demo can be seen in the terminal by using the following command line:
#'
#' ```
#' $ wish __BASENAME__.tcl --code
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
#' $ tclsh __BASENAME__.tcl --man
#' ```
#'
#' The output of this command can be used to feed a markdown processor for conversion into a 
#' man page, html or pdf document. If you have pandoc installed for instance, you could execute the following commands:
#'
#' ```
#' # man page
#' tclsh __BASENAME__.tcl --man | pandoc -s -f markdown -t man - > __BASENAME__.n
#' # html 
#' tclsh __BASENAME__.tcl --man > __BASENAME__.md
#' pandoc -i __BASENAME__.md -s -o __BASENAME__.html
#' # pdf
#' pandoc -i __BASENAME__.md -s -o __BASENAME__.tex
#' pdflatex __BASENAME__.tex
#' ```
#' 
#' ## <a name='see'>SEE ALSO</a>
#'
#' - [dgw - package homepage: http://chiselapp.com/user/dgroth/repository/tclcode/index](http://chiselapp.com/user/dgroth/repository/tclcode/index)
#'
#' ## <a name='todo'>TODO</a>
#'
#' * probably as usually more documentation
#' * more, real, tests
#' * github url for putting the code

#'
#' ## <a name='authors'>AUTHOR</a>
#'
#' The **__BASENAME__** widget was written by Detlef Groth, Schwielowsee, Germany.
#'
#' ## <a name='license'>LICENSE</a>
# LICENSE START
#' 
#' dgw::sbuttonbar widget __PKGNAME__, version __PKGVERSION__.
#'
#' Copyright (c) 
#' 
#'    * 2001-2002 by Steve Landers <steve (at) digital-smarties(dot)com>
#'    * 2004 Uwe Koloska <uwe (at) koloro(dot)de>
#'    * 2004-2019  Dr. Detlef Groth, <detlef (at) dgroth(dot)de>
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
if {[info exists argv0] && $argv0 eq [info script] && [regexp sbuttonbar $argv0]} {
    set dpath dgw
    set pfile [file rootname [file tail [info script]]]
    if {[llength $argv] == 1 && [lindex $argv 0] eq "--version"} {    
        puts [dgw::getVersion [info script]]
        destroy .
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--demo"} {    
        dgw::runExample [info script]
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--code"} {
        puts [dgw::runExample [info script] false]
        destroy .
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--test"} {
        package require tcltest
        set argv [list] 
        tcltest::test dummy-1.1 {
            Calling my proc should always return a list of at least length 3
        } -body {
            set result 1
        } -result {1}
        tcltest::cleanupTests
        destroy .
    } elseif {[llength $argv] == 1 && ([lindex $argv 0] eq "--license" || [lindex $argv 0] eq "--man" || [lindex $argv 0] eq "--html" || [lindex $argv 0] eq "--markdown")} {
        dgw::manual [lindex $argv 0] [info script]
    } elseif {[llength $argv] == 1 && [lindex $argv 0] eq "--install"} {
        dgw::install [info script]
    } else {
        destroy .
        puts "\n    -------------------------------------"
        puts "     The ${dpath}::$pfile package for Tcl"
        puts "    -------------------------------------\n"
        puts "Copyright (c) 2019  Dr. Detlef Groth, E-mail: detlef(at)dgroth(dot)de\n"
        puts "License: MIT - License see manual page"
        puts "\nThe ${dpath}::$pfile package provides a button toolbar with nice graphical buttons."
        puts ""
        puts "Usage: [info nameofexe] [info script] option\n"
        puts "    Valid options are:\n"
        puts "        --help    : printing out this help page"
        puts "        --demo    : runs a small demo application."
        puts "        --code    : shows the demo code."
        puts "        --test    : running some test code"
        puts "        --license : printing the license to the terminal"
        puts "        --install : install ${dpath}::$pfile as Tcl module"        
        puts "        --man     : printing the man page in pandoc markdown to the terminal"
        puts "        --markdown: printing the man page in simple markdown to the terminal"
        puts "        --html    : printing the man page in html code to the terminal"
        puts "                    if the Markdown package from tcllib is available"
        puts "        --version : printing the package version to the terminal"
        puts ""
        puts "    The --man option can be used to generate the documentation pages as well with"
        puts "    a command like: "
        puts ""
        puts "    tclsh [file tail [info script]] --man | pandoc -t html -s > temp.html\n"
    }

}
