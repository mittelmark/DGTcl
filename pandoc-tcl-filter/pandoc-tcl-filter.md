## NAME

_pandoc-tcl-filter.tcl_ - filter application for the pandoc command line 
application to convert Markdown files into other formats. The filter allows you to embed Tcl code into your Markdown
documentation and offers a plugin architecture to add other command line filters easily using Tcl
and the `exec` command. As an example a dot filter plugin is given as `filter-dot.tcl`.

## SYNOPSIS 

Embed code either inline or in form of code chunks like here (triple ticks without space):

``` 
  ` ``{.tcl}
  # a code block
  # remove the space between backticks
  # to avoid Pandoc confusion
  set x 4
  ` ```
  
  Hello this is Tcl `tcl package provide Tcl`!
```

The Markdown document within this file could be processed as follows:

```
 perl -ne "s/^#' ?(.*)/\$1/ and print " > pandoc-tcl-filter.md
 pandoc pandoc-tcl-filter.md -s \
   --metadata title="pandoc-tcl-filter.tcl documentation" \
   -o pandoc-tcl-filter.html  --filter pandoc-tcl-filter.tcl  \
   --css mini.css
```


## Plugins

The pandoc-tcl-filter.tcl application allows to create custom filters for other 
command line application quite easily. The Tcl files has to be named `filter-NAME.tcl`
where NAME hast to match the code chunk marker. Below an example:

```
   ` ``{.dot label=dotgraph}
   digraph G {
     main -> parse -> execute;
     main -> init;
     main -> cleanup;
     execute -> make_string;
     execute -> printf
     init -> make_string;
     main -> printf;
     execute -> compare;
   }

   ![](dotgraph.svg)
   ` ``
```

The main script pandoc-tcl-filter.tcl looks if in the same folders as the script is,
if there any other files named `filter-NAME.tcl` and source them. In case of the dot
filter the file is named `filter-dot.tcl` and its filter function filter-dot is 
executed. Below is the code: of this file `filter-dot.tcl`:

```
proc filter-dot {cont dict cblock} {
   global n
   incr n
   set ret ""
   if {[dict get $dict label] eq "null"} {
       set fname dot-$n
   } else {
        set fname [dict get $dict label]
   }
   set out [open $fname.dot w 0600]
   puts $out $cont
   close $out
   set res [exec dot -Tsvg $fname.dot -o $fname.svg]
   if {[dict get $dict results] eq "show" && $res ne ""} {
       rl_json::json set cblock c 0 1 [rl_json::json array [list string dotout]]
       rl_json::json set cblock c 1 [rl_json::json string $res]
       set ret ",[::rl_json::json extract $cblock]"
   }
   return $ret
}
```

Automatic inclusion of the image would require more effort and dealing with the cblock
which is a copy of the current json block containing the source code. Using the label
We could create an image link and append this block after the `$cblock` part of the `$ret var`.
As an exercise you could create a filter for the neato application which creates graphics for undirected graphs.

## ChangeLog

* 2021-08-22 Version 0.1
* 2021-08-28 Version 0.2
    * adding custom filters structure (dot, tsvg examples)
    * adding attributes label, width, height, results
    
## SEE ALSO

* [Readme.html](Readme.html) - more information and small tutorial
* [Tclers Wiki page](https://wiki.tcl-lang.org/page/pandoc%2Dtcl%2Dfilter) - place for discussion
* [Pandoc filter documentation](https://pandoc.org/filters.html) - more background and information on how to implement filters in Haskell and Markdown
* [Lua filters on GitHub](https://github.com/pandoc/lua-filters)
* [Plotting filters on Github](https://github.com/LaurentRDC/pandoc-plot)
* [Github Pandoc filter list](https://github.com/topics/pandoc-filter)

## AUTHOR

Dr. Detlef Groth, Caputh-Schwielowsee, Germany, detlef(_at_)dgroth(_dot_).de
 
## LICENSE

```
MIT License

Copyright (c) 2021 Dr. Detlef Groth, Caputh-Schwielowsee, Germany

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

