#' ---
#' title: "filter-sqlite.tcl documentation"
#' author: "Detlef Groth, Caputh-Schwielowsee, Germany"
#' date: 2021-12-12
#' sqlite:
#'     app: sqlite3
#'     mode: markdown
#' ---
#' 
# a simple pandoc filter using Tcl the script pandoc-tcl-filter.tcl 
# must be in the in the parent directory of the filter directory
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
#' _filter-sqlite.tcl_ - Filter which can be used to execute SQLite3 statements within a Pandoc processed
#' document using the Tcl filter driver `pandoc-tcl-filter.tcl` and showing the output. 
#' 
#' ## Usage
#' 
#' The conversion of the Markdown documents via Pandoc should be done as follows:
#' 
#' ```
#' pandoc input.md --filter pandoc-tcl-filter.tcl -s -o output.html
#' ```
#' 
#' The file `filter-sqlite.tcl` is not used directly but sourced automatically by the `pandoc-tcl-filter.tcl` file.
#' If code blocks with the `.sqlite` marker are found, the contents in the code block is processed via the sqlite3
#' command line application which must be in the path.
#' 
#' The following options can be given via code chunks or in the YAML header.
#' 
#' > - app - the application to be called, such as sqlite3, default: sqlite3
#'   - results - should the output of the command line application been shown, should be asis, show or hide, default: asis
#'   - eval - should the code in the code block be evaluated, default: true
#'   - mode - the output mode, default: markdown
#' 
#' To change the defaults the YAML header can be used. Here an example to change the 
#' default command line application to sqlite3-35
#' 
#' ```
#'  ----
#'  title: "filter-sqlite.tcl documentation"
#'  author: "Detlef Groth, Caputh-Schwielowsee, Germany"
#'  date: 2021-12-12
#'  sqlite:
#'      app: sqlite3-35
#'  ----
#' ```
#'
#' ## Examples
#' 
#' Here an example for a new database created on the fly and the we check for the created table ({.sqlite results="asis"}).
#' 
#' ```{.sqlite results="asis"}
#' CREATE TABLE contacts (
#' 	contact_id INTEGER PRIMARY KEY,
#' 	first_name TEXT NOT NULL,
#' 	last_name TEXT NOT NULL,
#' 	email TEXT NOT NULL UNIQUE,
#' 	phone TEXT NOT NULL UNIQUE
#'         );
#' INSERT INTO contacts (contact_id, first_name, last_name, email, phone)
#'        VALUES       (1, "Max", "Musterman", "musterm@mail.de","1234");
#' INSERT INTO contacts (contact_id, first_name, last_name, email, phone)
#'        VALUES       (2, "Maxi", "Musterwoman", "musterw@mail.de","1235");
#' select * from contacts;
#' ```
#' 
#' And here an example for a existing database ({.sqlite results="asis" file="uni.sqlite"}):
#' 
#' ```{.sqlite results="asis" file="uni.sqlite"}
#'  select type,name from sqlite_master;
#' ```
#' 
#' Let's query the Student table ({.sqlite results="asis" file="uni.sqlite"}):
#' 
#' ```{.sqlite results="asis" file="uni.sqlite"}
#'  select * from Student limit 5;
#' ```
 
#' ## See also:
#' 
#' * [pandoc-tcl-filter Readme](../Readme.html)
#' * [Pikchr filter](filter-pik.html)
#' * [PlantUML filter](filter-puml.html)
#' 


proc filter-sqlite {cont dict} {
    global n
    incr n
    set def [dict create results asis eval true file null \
             include true app sqlite3 label null mode markdown]
    set dict [dict merge $def $dict]
    set ret ""
    set owd [pwd] 
    if {[auto_execok [dict get $dict app]] eq ""} {
        return [list "Error: [dict get $dict app] is not installed, please install it!" ""]
    }
    set version [exec [dict get $dict app] --version]
    if {[regexp {^3.[12]} $version] || [regexp {^3.3[0-2]} $version]} {
        return [list "Error: You need at least sqlite3 version 3.33 which supports Markdown mode!" ""]
    }
    if {[dict get $dict label] eq "null"} {
        set fname [file join $owd sqlite-$n]
    } else {
        set fname [file join $owd [dict get $dict label]]
    }
    set out [open $fname.sqlite w 0600]
    puts $out $cont
    close $out

    if {[dict get $dict file] eq "null"} {
        # TODO: error catching
        set res [exec cat $fname.sqlite | [dict get $dict app] -[dict get $dict mode]]
    } else {
        set res [exec cat $fname.sqlite | [dict get $dict app] [dict get $dict file] -[dict get $dict mode]]
    }
    if {[dict get $dict results] in [list show asis]} {
        # should be usually empty
        set res $res
    } else {
        set res ""
    }
    #puts stderr $res
    return [list $res ""]
}
