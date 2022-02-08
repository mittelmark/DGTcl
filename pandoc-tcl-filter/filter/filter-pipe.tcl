#' ---
#' title: "filter-pipe.tcl documentation"
#' author: "Detlef Groth, Caputh-Schwielowsee, Germany"
#' date: 2022-01-12
#' cmd:
#'     results: show
#' ---
#' 
#' ------
#' 
#' ```{.tcl results="asis" echo=false}
#' include header.md
#' ```
#' 
#' ------
#'
#' ## Name
#' 
#' _filter-pipe.tcl_ - Filter which can be used to execute various programming
#' languages using a pipe mechanism using the Tcl filter driver `pandoc-tcl-filter.tcl` and showing or hiding the output. 
#' 
#' ## Usage
#' 
#' The conversion of the Markdown documents via Pandoc should be done as follows:
#' 
#' ```
#' pandoc input.md --filter pandoc-tcl-filter.tcl -s -o output.html
#' ```
#' 
#' The file `filter-cmd.tcl` is not used directly but sourced automatically by the `pandoc-tcl-filter.tcl` file.
#' If code blocks with the `.cmd` marker are found, the contents in the code block is processed via standard
#' shell as command line application.
#' 
#' The following options can be given via code chunks or in the YAML header.
#' 
#' > - eval - should the code in the code block be evaluated, default: true
#'   - echo - should the input code been shown, default: false
#'   - pipe - the programming language to be used, either R or python, which is python3, default: python3
#'   - results - should the output of the command line application been shown, should be asis, show or hide, default: show
#' 
#' To change the defaults the YAML header can be used. Here an example to change the 
#' default pipe command to R.
#' 
#' ```
#'  ----
#'  title: "filter-pipe.tcl documentation"
#'  author: "Detlef Groth, Caputh-Schwielowsee, Germany"
#'  date: 2022-01-12
#'  cmd:
#'      pipe: R
#'  ----
#' ```
#'
#' ## Examples
#' 
#' ### Python examples
#' 
#' Here an example for very simple python code.
#' 
#' ```{.pipe pipe="python3" results="show" terminal=true}
#' x=1
#' print(x)
#' y=x+1
#' print(y)
#' ```
#' 
#' In contrast to the [.cmd filter](filter-cmd.html) the code chunks are
#' in the same session, so we can continue to add more Python code which knows about the existing variables from the session before.
#' 
#' Here an example declaring a function:
#' 
#' ```{.pipe pipe="python3" results="show" terminal=true}
#' def test (x):
#'     return(x+1)
#' 
#' print(test(y))
#' ```
#' 
#' We can as well omit the terminal mode by setting the chunk option "terminal to false". You will then only see the output.
#' 
#' ```{.pipe terminal=false}
#' def test2 (x):
#'     return(x+2)
#' 
#' print(test2(y))
#' ```
#' 
#' Let's finish the Python section with an image created with *matplotlib* (`{.pipe terminal=false results="hide"}`).
#' 
#' ```{.pipe terminal=false results="hide"}
#' import matplotlib.pyplot as plt
#'  
#' # frequencies
#' ages = [2,5,70,40,30,45,50,45,43,40,44,
#'         60,7,13,57,18,90,77,32,21,20,40]
#'  
#' # setting the ranges and no. of intervals
#' range = (0, 100)
#' bins = 10
#'  
#' # plotting a histogram
#' plt.hist(ages, bins, range, color = 'skyblue',
#'         histtype = 'bar', rwidth = 0.8)
#'  
#' # x-axis label
#' plt.xlabel('age')
#' # frequency label
#' plt.ylabel('No. of people')
#' # plot title
#' plt.title('My histogram')
#' 
#' # save the file
#' plt.savefig('pyhist.png')
#' ```
#' 
#' We then just display the image file using standard Markdown.
#'  
#' ![](pyhist.png)
#' 
#' There is as well the possibility to add inline Python code to display the values of variables or the output of short python commands here an example:
#' 
#' ```{.pipe pipe="python3"}
#' l = [1,2,3,4]
#' g = [1,2,3,4,5]
#' print(len(l))
#' ```
#' 
#' ```{.pipe pipe="python3"}
#' g.append(6)
#' print(len(g))
#' ```
#' 
#' Let's now display the length of the list g, g has a length 
#' of `py print(len(g));`!
#' 
#' Another trial: *py 3+2=* `py 3+2`? Should be five!
#' 
#' Let's finish with Python code containing an error:
#' 
#' ```{.pipe pipe="python3"}
#' y=3
#' # a type
#' print(y00)
#' ```
#' 
#' ### R examples
#' 
#' ```{.pipe pipe="R" results="show"}
#' source("~/R/dlibs/chords.R")
#' data(iris)
#' png("testr.png")
#' boxplot(iris$Sepal.Length ~ iris$Species,col=2:4)
#' dev.off()
#' print(2)
#' 1
#' ```
#' 
#' ![](testr.png)
#' 
#' Now a table example:
#' 
#' ```{.pipe pipe="R" results="asis"}
#' data(mtcars)
#' knitr::kable(head(mtcars[, 1:4]), "pipe")
#' ```
#' 
#' There is as well the possibility to display inline R code. So for instance we can use the nrow function to 
#' get the number of cars in the dataset.
#' The mtchars dataset has `R nrow(mtcars)` cars!
#' 
#' Let's now simulate an R error:
#' 
#' ```{.pipe pipe="R"}
#' x=3+2
#' print(ls())
#' x
#' print(y)
#' 2+3
#' ```
#' 
#' ### Octave example
#' 
#' ```{.pipe pipe="oc"}  
#' x=1;
#' disp(x);
#' y=2;
#' disp(y);
#' ```
#' 
#' Now let's do a plot:
#' 
#' ```{.pipe pipe="octave"}
#' aux=figure('visible','off');
#' tx = ty = linspace (-8, 8, 41);
#' [xx, yy] = meshgrid (tx, ty);
#' r = sqrt (xx .^ 2 + yy .^ 2) + eps;
#' tz = sin (r) ./ r;
#' mesh (tx, ty, tz);
#' saveas(aux, 'mesh-octave.png', 'png');
#' ```
#' 
#' ![](mesh-octave.png)
#' 
#' What about inline code? What is the value of y? 
#' It should be `oc disp(y)`.  Hmm, not yet working.
#' 
#' ```{.pipe pipe="octave"}
#' z=x+y
#' disp(z)
#' ```
#' 
#' Let's now do an Octave error:
#' 
#' ```{.pipe pipe="octave"}
#' z
#' disp(k)
#' ```
#' 
#' ### Tcl example (not a pipe)
#' 
#' ```{.tcl}
#' puts "Hello Tcl"
#' set x 1
#' ```
#' 
#' This is inline Tcl which shows the value of $x and x is: `tcl set x`!
#'
#' However until inside lists and in nested structure this is not yet evaluated like here in this list:
#' 
#' * a list item with Tcl code, x is: `tcl set x`
#' * an other list item
#' * a longer Tcl statement: `tcl set h "Hello World Number [incr x]!"`.
#' * and here the current date and time: `tcl clock format [clock seconds] -format "%m %b, %Y"`
#' 
#' ## TODO:
#' 
#' * support Python (done) - inline (done) - error catching (done)
#' * support R (done) - inline (done) - error catching (done)
#' * support Octave (done) - inline (not working) - error catching (done)
#' * support Julia??
#' * terminal mode on/off
#' 
#' ## See also:
#' 
#' * [pandoc-tcl-filter Readme](../Readme.html)
#' * [Rplot filter](filter-rplot.html)
#' * [Tcl filter](../pandoc-tcl-filter.html)
#' 

namespace eval ::fpipe {
    variable n 0
    variable pipecode ""
    variable pypipe ""
    variable rpipe ""
    variable opipe ""
    #set n 0
    #set pipecode ""
}
proc piperead {pipe args} {
    if {![eof $pipe]} {
        set got [gets $pipe]
        if {$got ne "flush(stdout)"} {
            # not sure why python does this
            if {[regexp {^>>>} $got]} {
                append ::fpipe::pipecode [regsub {^.*>>> } "$got" ""]
            } else {
                # R and Octave
                append ::fpipe::pipecode "$got\n"
            }
            
        }
    } else {
        close $pipe
    }
}


# TODO: 
# * namespace vars
# * cleanup pipes if blocking true
# * trace add execution exit enter YourCleanupProc

proc filter-pipe {cont dict} {
    incr ::fpipe::n
    set ::fpipe::pipecode ""
    set def [dict create results show eval true label null \
             include true pipe python3 terminal true]
    set dict [dict merge $def $dict]
    if {$::fpipe::pypipe eq "" && [string range [dict get $dict pipe] 0 1] eq "py"} {
        set ::fpipe::pypipe [open "|python3 -ui 2>@1" r+]
        fconfigure $::fpipe::pypipe -buffering line -blocking false
        fileevent $::fpipe::pypipe readable [list piperead $::fpipe::pypipe]
    }
    if {$::fpipe::opipe eq "" && [string range [dict get $dict pipe] 0 1] eq "oc"} {
        set ::fpipe::opipe [open "|octave --interactive --no-gui --norc --silent 2>@1" r+]
        fconfigure $::fpipe::opipe -buffering none -blocking false
        fileevent $::fpipe::opipe readable [list piperead $::fpipe::opipe]
        puts $::fpipe::opipe {PS1("")}
        puts $::fpipe::opipe "page_screen_output(1);"
        puts $::fpipe::opipe "page_output_immediately(1);"
        puts $::fpipe::opipe "fflush(stdout)"
        flush $::fpipe::opipe
        after 100 [list append wait ""]
        vwait wait
        set ::fpipe::pipecode ""
    }
    #  
    if {$::fpipe::rpipe eq "" && [string range [dict get $dict pipe] 0 0] eq "R"} {
        set ::fpipe::rpipe [open "|R -q --interactive --vanilla  2>@1" r+]
        fconfigure $::fpipe::rpipe -buffering line -blocking false
        fileevent $::fpipe::rpipe readable [list piperead $::fpipe::rpipe]
        
    }
    set wait [list]
    set term ">>>"
    if {[string range [dict get $dict pipe] 0 1] eq "oc"} {
        set term "octave>"
    }
    if {[string range [dict get $dict pipe] 0 0] ne "X"} {
        foreach line [split $cont \n] {
            #  && [string range [dict get $dict pipe] 0 0] ne "R"
            if {[dict get $dict terminal] && [string range [dict get $dict pipe] 0 1] in [list "py" "oc"]}  {
                append ::fpipe::pipecode "$term $line\n" 
                
            }
            if {[string range [dict get $dict pipe] 0 1] eq "py"} {
                puts $::fpipe::pypipe "$line"
            }
            if {[string range [dict get $dict pipe] 0 1] eq "oc"} {
                puts $::fpipe::opipe "$line"
                flush $::fpipe::opipe
            }
            if {[string range [dict get $dict pipe] 0 0] eq "R"} {
                puts $::fpipe::rpipe "$line"
                flush $::fpipe::rpipe
            }
            if {[regexp {^[^\s]} $line]} {
                # delay only if first letter is non-whitespace
                # to allow to flush output
                after 100 [list append wait ""]
                vwait wait
            }
        }
    }
    after 100 [list append wait ""]
    vwait wait
    set res $::fpipe::pipecode
    # TODO: dict app using
    if {!([dict get $dict results] in [list show asis])} {
        set res ""
    } 
    if {[dict get $dict results] eq "asis" && [string range [dict get $dict pipe] 0 0] eq "R"} {
        set nres ""
        foreach line [split $res \n] {
            if {![regexp {^[+>]} $line]} {
                append nres "$line\n"
            }
        }
        set res $nres
    }
    if {[dict get $dict results] in [list show asis] && [string range [dict get $dict pipe] 0 1] eq "oc"} {
        set nres ""
        set i 0
        foreach line [split $res \n] {
            if {![regexp {^.*ans = 0\s*$} $line] && ![regexp {^>\s*$} $line]} {
                append nres "$line\n"
            } elseif {$i == 2  && [regexp {^\s*$} $line]} {
                continue
            } else {
                set i 1
            }
            incr i
        }
        set res $nres
    }
    return [list $res ""]
}
