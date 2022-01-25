#' ---
#' title: "filter-cmd.tcl documentation"
#' author: "Detlef Groth, Caputh-Schwielowsee, Germany"
#' date: 2021-12-27
#' cmd:
#'     results: show
#' ---
#' 
#' ## Name
#' 
#' _filter-cmd.tcl_ - Filter which can be used to execute terminal
#' applications using the Tcl filter driver `pandoc-tcl-filter.tcl` and showing or hiding the output. 
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
#'   - file - the output filename for the code which will be executed using the given shebang line on top, if not given, code will be evaluated line by line, default: null
#'   - results - should the output of the command line application been shown, should be asis, show or hide, default: show
#' 
#' To change the defaults the YAML header can be used. Here an example to change the 
#' default results option to hide.
#' 
#' ```
#'  ----
#'  title: "filter-cmd.tcl documentation"
#'  author: "Detlef Groth, Caputh-Schwielowsee, Germany"
#'  date: 2021-12-27
#'  cmd:
#'      results: hide
#'  ----
#' ```
#'
#' ## Examples
#' 
#' ### Line by line commands
#' 
#' Here an example for executing the `ls` command on a Unix system for all Tcl files in the current folder (chunk options: `{.cmd results="show"}`).
#' 
#' ```{.cmd results="show"}
#' ls -l *.tcl
#' ```
#' 
#' Here an example to execute the sqlite3 command line application (chunk options: `{.cmd results="asis"}`).
#' 
#' ```{.cmd results="asis"}
#' sqlite3 -markdown uni.sqlite "select * from Student limit 5"
#' ```
#' 
#' Let's now demonstrate a more extended example where we first create a 
#' script which can createimage buttons. The script uses PlantUML and looks like this:
#' 
#' 
#' ```
#' #!/bin/sh
#' if [ -z $2 ] ; then
#'     echo "Usage: hwbutton.sh 'rectangle \" title \" color'" outfile.png
#'     return
#' fi
#' echo "@startuml" > temp.uml
#' echo "skinparam handwritten true" >> temp.uml
#' echo "<style> " >> temp.uml
#' echo "rectangle { " >> temp.uml
#' echo "    FontSize 20" >> temp.uml
#' echo "    FontStyle bold" >> temp.uml
#' echo "    FontName Purisa" >> temp.uml  
#' echo "}" >> temp.uml
#' echo "</style>" >> temp.uml
#' echo $1 >> temp.uml
#' echo "@enduml" >> temp.uml
#' plantuml -o out temp.uml 
#' mv out/temp.png $2
#' ```
#' 
#' Let's save this script as an executbable shell script hwbutton.sh in 
#' a directory beloning to our PATH. We can thereafter create a few image buttons
#' in one go (`{.cmd results="hide"}`):
#' 
#' ```{.cmd results="hide"}
#' hwbutton.sh 'rectangle "  Bob   " #ccddee' hw-bob.png 
#' hwbutton.sh 'rectangle " Alice  " #eeddcc' hw-alice.png
#' hwbutton.sh 'rectangle " <i>E=mc<sup>2</sup></i> " #ffaaaa' hw-emc2.png
#' ```
#' 
#' So we created three png files in this directory (`{.cmd}`):
#' 
#' ```{.cmd}
#' ls -l hw-*png
#' ```
#' 
#' Let's now display these images side by side using standard Markdown syntax:
#' 
#' ![](hw-bob.png) ![](hw-alice.png) ![](hw-emc2.png)
#' 
#' ## Standalone scripts
#' 
#' ### Python scripts
#' 
#' The chunk option *file* allows as as well to embed code for other programming languages and interprete them. Here an example to execute a Python script.
#' 
#' ```
#'      ```{.cmd file="sample.py"}
#'      #!/usr/bin/env python3
#'      import sys
#'      print ("Hello Python World!")
#'      print (sys.version)
#'      ```
#' ```
#' 
#' This is the output:
#' 
#' ```{.cmd file="sample.py"}
#' #!/usr/bin/env python3
#' import sys
#' print ("Hello Python World!")
#' print (sys.version)
#' ```
#' 
#' ### Gnu Octave scripts
#' 
#' As usually using the code chunk option echo=false you can hide the Python code and only show the output.
#' Here an Octave script which does a little plot.
#' 
#' ```
#'     ```{.cmd file="sample.m"}
#'     #!/usr/bin/env octave
#'     x = -10:0.1:10;
#'     aux=figure();
#'     plot (x, sin (x));
#'     saveas(aux, 'octave.png', 'png');
#'     ```
#' ```
#' 
#' And again here its output:
#' 
#' ```{.cmd file="sample.m"}
#' #!/usr/bin/env octave
#' x = -10:0.1:10;
#' aux=figure();
#' plot (x, sin (x));
#' saveas(aux, 'octave.png', 'png');
#' ```
#' 
#' ![](octave.png)
#' 
#' To reuse functions etc you can source the created source code files 
#' into subsequent code blocks.
#' 
#' ### R scripts
#' 
#' Now an example for an R-script and how functions created in one code 
#' chunk can be reused in an other code chunk.
#' 
#' ```
#'     ```{.cmd file="plot.R" eval=false results=hide}
#'     #!/usr/bin/env/Rscript
#'     doPlot = function (x,y,pch=19,col="red",...) {
#'        plot(y~x,pch=pch,col=col,...)
#'     }
#'     ```
#' ```
#' 
#' This is the output, just code display:
#' 
#' ```{.cmd file="plot.R" eval=false results=hide}
#' #!/usr/bin/env/Rscript
#' doPlot = function (x,y,pch=19,col="red",...) {
#'    plot(y~x,pch=pch,col=col,...)
#' }
#' ```
#' 
#' In the next chunk we use this function by sourcing the file.
#' 
#' ```
#'     ```{.cmd file="doplot.R" results="hide"}
#'     #!/usr/bin/env Rscript
#'     source('plot.R') # file was created in the previous chunk.
#'     x=seq(0,8,by=0.1)
#'     y=sin(x)
#'     y=y+rnorm(length(y),sd=0.1)
#'     png("plotR.png")
#'     doPlot(x,y)
#'     dev.off()
#'     ```
#' ```
#' 
#' And here the output:
#' 
#' ```{.cmd file="doplot.R" results="hide"}
#' #!/usr/bin/env Rscript
#' source('plot.R') # file was created in the previous chunk.
#' set.seed(123)
#' x=seq(0,8,by=0.1)
#' y=sin(x)
#' y=y+rnorm(length(y),sd=0.1)
#' png("plotR.png",width=900,height=600)
#' par(mfrow=c(1,2))
#' doPlot(x,sin(x),main="y=sin(x)")
#' doPlot(x,y,main="y=sin(x)+noise")
#' dev.off()
#' ```
#' 
#' ![](plotR.png)
#' 
#' There is as well a separate filter for R called *rplot*, see [filter-rplot.html](filter-rplot.html). 
#' This filter supports as well session management, so that separate code chunks share the same R-session and syntax hightlighting.
#' 
#' ### Gnuplot scripts
#' 
#' Next a Gnuplot script (`{.cmd file="sin.gp"}`):
#' 
#' ```{.cmd file="sin.gp"}
#' #!/usr/bin/env gnuplot
#' # Set the output to a png file
#' set terminal png size 800,500
#' # The file we'll write to
#' set output 'sin-gp.png'
#' # The graphic title
#' set title 'sin(x) - Gnuplot'
#' #plot the graphic
#' plot sin(x)
#' ```
#' 
#' ![](sin-gp.png)
#' 
#' ### GraphViz dot scripts
#' 
#' Here an example for a standalone dot-script (`{.cmd file="digraph.dot"}`): 
#' 
#' ```{.cmd file="digraph.dot"}
#' #!/usr/bin/env -S dot -Tpng -odot.png
#' digraph G {
#'   node[style=filled,fillcolor=skyblue];
#'   A -> B ;
#' }
#' ```
#' 
#' ![](dot.png)
#' 
#' ### Simple shell scripts
#' 
#' First a mathematical calculation (`{.cmd file="calc.sh"}`):
#' 
#' ```{.cmd file="calc.sh"}
#' #!/bin/sh
#' x=6
#' y=7
#' echo $(($x+$y))
#' ```
#' 
#' Then a mathematical equation (`{.cmd file="math.eqn"}`):
#' 
#' ```{.cmd file="math.eqn"}
#' #!/bin/sh
#' echo "x = {-b +- sqrt{b sup 2 - 4ac}} over 2a" \
#'       | eqn2graph -colorspace RGB -density 144 > eqn.png
#' ```
#' 
#' ![](eqn.png)
#' 
#' And here let's use this for the formula of the most important biochemical reaction on planet Earth (`{.cmd file="photo.eqn"}`):
#' 
#' ```{.cmd file="photo.eqn"}
#' #!/bin/sh
#' echo "6H sub 2 O + 6CO sub 2 + Light -> C sub 6 H sub 12 O sub 6 + 6 O sub 2" \
#'       | eqn2graph -colorspace RGB -density 144 > photo.png
#' ```
#' 
#' Afterwards you can embed the png image using your Markdown code.
#' 
#' ![](photo.png)
#' 
#' For more information on how to typeset equations using the EQN syntax have a look here: [https://www.oreilly.com/library/view/unix-text-processing/9780810462915/Chapter09.html](https://www.oreilly.com/library/view/unix-text-processing/9780810462915/Chapter09.html).
#'
#' ### Lilypond example
#' 
#' A typical problem are programming languages which do not support the shebang line. 
#' We can create for such languages a wrapper script which pipe the input of a script but not the very first 
#' line into the interpreter. Here an example for the lilypond interpreter, a tool to process music notation. Here the wrapper script:
#' 
#' ```
#' #!/usr/bin/env bash
#' # file lilyscript.sh
#' if [ -z $2 ]; then
#'     out=out
#'     ext=svg
#' else
#'     out=$2
#'     ext=${out##*.}
#'     out=`basename $out .$ext`
#' fi
#' # echo all lines bit not the shebang line and 
#' # pipe this into lilypond
#' perl -ne '$x++ >= 1 and print' $1 > temp.ly
#' # crop page support for png and pdf output
#' echo "
#' \paper {
#'   indent = 0\mm
#'   line-width = 110\mm
#'   oddHeaderMarkup = \"\"
#'   evenHeaderMarkup = \"\"
#'   oddFooterMarkup = \"\"
#'   evenFooterMarkup = \"\"
#' }
#' " >> temp.ly
#' lilypond -dbackend=eps -dresolution=300 --output=$out --$ext temp.ly
#' if [ -e "$out-systems.texi" ]; then
#'      rm $out-* 
#' fi     
#' # EOF
#' ```
#' 
#' If we copy this file as lilyscript.sh into a folder belonging to our PATH variable we can then embed lilypond code into a executable script easily. Here an example (chunk options are: `{.cmd file="mini.ly" results="hide"}`):
#' 
#' ```{.cmd file="mini.ly" results="hide"}
#' #!/usr/bin/env -S lilyscript.sh mini.ly mini.svg
#' \version "2.14.1"
#' % required for svg to manually crop the image
#' #(set! paper-alist
#'   (cons '("my size" . (cons (* 3 in) (* 1 in))) paper-alist))
#' \paper {
#'   #(set-paper-size "my size")
#' }
#' {
#'   % middle tie looks funny here:
#'   <c' d'' b''>8. ~ <c' d'' b''>8
#' }
#' ```
#' 
#' We then embed the image using Markdown syntax. Using the border-style we can
#' as well adapt the width and height of the paper size see:
#' 
#' ```
#' ![](mini.svg){#id width=240 style="border: 3px solid #ddd;"}
#' ```
#' 
#' Gives:
#' 
#' ![](mini.svg){#id width=300 style="border: 3px solid #ddd;"}
#'
#' Png and Pdf images are automatically cropped, so we do not need to set the paper size (`{.cmd file="mini2.ly" results="hide"}`).
#' 
#' ```{.cmd file="mini2.ly" results="hide"}
#' #!/usr/bin/env -S lilyscript.sh mini2.ly mini.png
#' \version "2.14.1"
#' {
#'   % middle tie looks funny here:
#'   <c' d'' b''>8. ~ <c' d'' b''>8
#' }
#' ```
#' 
#' We can then include the created 
#' image using standard Markdown syntax with setting as well a width to scale the image (`![](mini.png){#id width=140}`):
#' 
#' ![](mini.png){#id width=140}
#'
#' Alternativly you can as well create a shell script without the need of a wrapper script like this (`{.cmd file="mini4.ly" results="hide"}`):
#' 
#' ```{.cmd file="mini4.ly" results="hide"}
#' #!/usr/bin/bash
#' exec perl -ne '$x++ > 1 and print' $0 | lilypond --out=mini4 --png - && exit
#' % now follows the Lilypond code
#' \version "2.22.0"
#' #(set! paper-alist
#'   (cons '("my size" . (cons (* 3 in) (* 0.8 in))) paper-alist))
#' \paper {  #(set-paper-size "my size") }
#' \header { tagline="" }
#' {
#' c'4 c' g' g' a' a' g'2
#' }
#' ```
#' 
#' ![](mini4.png)
#' 
#' ### C and C++ code
#' 
#' Using the approach with the lilypond examples we can as well embed C code by creating a wrapper for the compiler.
#' We here use the shebang script implementation for gcc found here: 
#' [https://rosettacode.org/wiki/Native_shebang#2nd_version._Pure_C.2C_no_extra_bash_script](https://rosettacode.org/wiki/Native_shebang#2nd_version._Pure_C.2C_no_extra_bash_script)
#' 
#' Now an example (`{.cmd file="test.csr"}`):
#' 
#' ```{.cmd file="test.csr"}
#' #!/usr/bin/env -S script_gcc -lm
#' 
#' #include <stdio.h>
#' #include <math.h>
#' 
#' int main (int argc, char** argv) {
#'     printf("Hello C World!\n");
#'     float pi = 3.141492653;
#'     printf("pi is: %f\n",pi);
#'     printf("sin(pi) is: %f\n",sin(pi));
#'     return(0);
#' }
#' ```
#' 
#' Again there is a simpler approach without a wrapper function using a pseudo-shebang line (`{.cmd file="hello2.c"}`): 
#' ```{.cmd file="hello2.c"}
#' ///usr/bin/cc -o "${0%.c}" "$0" -lm && exec "./${0%.c}"
#' 
#' #include <stdio.h>
#' #include <math.h>
#' 
#' int main (int argc, char** argv) {
#'     printf("Hello C Compiler World!\n");
#'     float pi = 3.141492653;
#'     printf("pi is: %f\n",pi);
#'     printf("sin(pi) is: %f\n",sin(pi));
#'     return(0);
#' }
#' ```
#' 
#' The same mechanism can be used for C++ code:
#' 
#' ```{.cmd file="hello.cxx"}
#' ///usr/bin/g++ -o "${0%.cxx}" "$0" && exec "./${0%.cxx}"
#' #include <iostream> 
#' 
#' int main(int argc, char** argv) {
#'   using namespace std;
#'   int ret = 0;
#'   cout << "Hello C++ World!" << endl;
#'   return ret;
#' } 
#' ```
#' 
#' And as well for the Go language:
#' 
#' ```{.cmd file="hello.go"}
#' ///usr/bin/go run $0 $@  2>&1 && exit 0
#' package main
#' 
#' func main() {
#'     println("Hello Go World!")
#' }
#' ```
#' ### Other programming languages
#' 
#' I left it as an exercise to embed Perl, Ruby, Julia scripts using the standard Shebang mechanism. 
#' 
#' 
#' ## TODO:
#' 
#' * compile option to embed C/C++/Java etc code
#' * own Python filter with terminal mode and line by line interpretation
#' * lilypond required version statement into liliscript.sh script
#' 
#' ## See also:
#' 
#' * [pandoc-tcl-filter Readme](../Readme.html)
#' * [dot filter](filter-dot.html)
#' * [Rplot filter](filter-rplot.html)
#' * [Tcl filter](../pandoc-tcl-filter.html)
#' * [Abc filter](filter-abc.html)
#' 


proc filter-cmd {cont dict} {
    global n
    incr n
    set def [dict create results asis eval true label null file null\
             include true app sh]
    # TODO: dict app using
    set dict [dict merge $def $dict]
    set res ""
    if {[dict get $dict file] eq "null"} {
        if {[dict get $dict eval]} {
            foreach line [split $cont "\n"] {
                if { [ catch {set resl [exec echo $line | sh] } ] } {
                    append res "Error in line `$line`\n"
                } else {
                    append res "$resl\n"
                }
            }
        }
    } else {
        set out [open [dict get $dict file] w 0755]
        puts $out $cont
        close $out
        if {[dict get $dict eval]} {
            if {[catch { set res [exec ./[dict get $dict file]] }] } {
                set res $::errorInfo
            } 
        }
    }
    if {!([dict get $dict results] in [list show asis])} {
        set res ""
    }
    return [list $res ""]
}
