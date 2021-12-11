---
title: Table tests for pandoc-tcl-filter
author: Detlef Groth, Caputh-Schwielowsee, Germany
date: 2021-12-10
---

## Test normal table given in text

A Markdown table written directly in Markdown:

***
| Col1          | Col2          |
| ------------- | ------------- |
| cell 1,1      | cell 1,2      |
| cell 2,1      | cell 2,2      |

**Table 1:** Markdown table

***

This is some text.

## Test normal Tcl code

```{.tcl}
set x 1
puts $x
```

## Test results="asis" with normal Tcl code

```{.tcl results="asis"}
set y 2
puts $y
```

## Test results="asis" with  Tcl code creating a Markdown table

Let's now create our own table in Tcl:

```{.tcl results="asis"}
set tab {
| Col1          | Col2          | Col3          | Col4          |
| ------------- | ------------- | ------------- | ------------- |
}
foreach i [list 1 2 3 4 5] {
    append tab "| cell $i,1   | cell $i,2 | cell $i,3 | cell $i,3 |\n"
}
set tab
```
**Table 2:** Table created with Tcl

And the table is displayed!


## Test results="asis" with  Tcl code creating a Markdown table and echo=false

```{.tcl results="asis" echo=false}
foreach i [list 6 7 8 9] {
    append tab "| cell $i,1   | cell $i,2 | cell $i,3 | cell $i,3 |\n"
}
set tab
```
**Table 3:** Table extended with Tcl

The table above was extended by invisible Tcl code. 

## list2table example

Below a method list2table method which can visualize flat and nested lists. Let's start with a flat list:

```{.tcl results="asis"}
proc list2table {header values} {
    set ncol [llength $header]
    set nval [llength $values]
    if {[llength [lindex $values 0]] > 1 && [llength [lindex $values 0]] != [llength $header]} {
        error "Error: list2table - number of values if first row is not a multiple of columns!"
    } elseif {[expr {int(fmod($nval,$ncol))}] != 0} {
        error "Error: list2table - number of values is not a multiple of columns!"
    }
    set res "|" 
    foreach h $header {
        append res " $h |"
    }   
    append res "\n|"
    foreach h $header {
        append res " ---- |"
    }
    append res "\n"
    set c 0
    foreach val $values {
        if {[llength $val] > 1} {    
            # nested list
            append res "| "
            foreach v $val {
                append res " $v |"
            }
            append res "\n"
        } else {
            if {[expr {int(fmod($c,$ncol))}] == 0} {
               append res "| " 
            }    
            append res " $val |"
            incr c
            if {[expr {int(fmod($c,$ncol))}] == 0} {
               append res "\n" 
            }    
        }
    }
    return $res
}

list2table [list A B C] [list 1 2 3 4 5 6 7 8 9]
```
**Table 4:** list2table flat list example

****

Nested list:

```{.tcl results="asis"}
list2table [list A B C] [list [list 10 11 12] [list 13 14 15] [list 16 17 18]]
```
**Table 5:** list2table nested list example

***

## Creating tables using list2mdtab

The Tcl filter contains the function shown above already predefined as
*list2mdtab*. So there is no need to define your own. Here an example:

```{.tcl results="asis"}
list2mdtab [list Col1 Col2 Col3] [list 21 22 23 24 25 26 27 28 29]
```
**Table 6:** list2mdtab example


## Document processing 

This document was created from the file *table.md* using the following terminal command line:

```
$ tclsh pandoc-tcl-filter.tcl tests/table.md table.html -s  --css mini.css
```

## End of file
