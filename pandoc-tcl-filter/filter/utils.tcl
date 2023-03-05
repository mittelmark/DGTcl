proc getTempDir {} {
    if {[file exists /tmp]} {
        # standard UNIX
        return /tmp
    } elseif {[info exists ::env(TMP)]} {
        # Windows
        return $::env(TMP)
    } elseif {[info exists ::env(TEMP)]} {
        # Windows
        return $::env(TEMP)
    } elseif {[info exists ::env(TMPDIR)]} {
        # OSX
        return $::env(TMPDIR)
    }
}
# convert a chunk start to a dictionary
# ```{.mtex packages="sudoku"}
proc chunk2dict {line} {
    set dchunk [dict create]    
    set ind ""
    regexp {```\{\.([a-zA-Z0-9]+)\s*(.*).*\}.*} $line -> filt options    
    foreach {op} [split $options " "] {
        foreach {key val} [split $op "="] {
            set val [regsub -all {"} $val ""] ;#"
            dict set dchunk $key $val         
        }
    }
    return $dchunk
}
                 
                 
