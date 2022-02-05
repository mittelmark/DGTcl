
namespace eval ::snit:: { 
    namespace export \
        boolean \
        double \
        enum \
        fpixels \
        integer \
        listtype \
        pixels \
        stringtype \
        window
}


snit::type ::snit::boolean {

    typemethod validate {value} {
        if {![string is boolean -strict $value]} {
            return -code error -errorcode INVALID \
   "invalid boolean \"$value\", should be one of: 1, 0, true, false, yes, no, on, off"

        }

        return $value
    }




    method validate {value} {
        $type validate $value
    }
}


snit::type ::snit::double {


    option -min -default "" -readonly 1


    option -max -default "" -readonly 1


    typemethod validate {value} {
        if {![string is double -strict $value]} {
            return -code error -errorcode INVALID \
                "invalid value \"$value\", expected double"
        }

        return $value
    }


    constructor {args} {
        $self configurelist $args

        if {"" != $options(-min) && 
            ![string is double -strict $options(-min)]} {
            return -code error \
                "invalid -min: \"$options(-min)\""
        }

        if {"" != $options(-max) && 
            ![string is double -strict $options(-max)]} {
            return -code error \
                "invalid -max: \"$options(-max)\""
        }

        if {"" != $options(-min) &&
            "" != $options(-max) && 
            $options(-max) < $options(-min)} {
            return -code error "-max < -min"
        }
    }


    method validate {value} {
        $type validate $value

        if {("" != $options(-min) && $value < $options(-min))       ||
            ("" != $options(-max) && $value > $options(-max))} {

            set msg "invalid value \"$value\", expected double"

            if {"" != $options(-min) && "" != $options(-max)} {
                append msg " in range $options(-min), $options(-max)"
            } elseif {"" != $options(-min)} {
                append msg " no less than $options(-min)"
            } elseif {"" != $options(-max)} {
                append msg " no greater than $options(-max)"
            }
        
            return -code error -errorcode INVALID $msg
        }

        return $value
    }
}


snit::type ::snit::enum {


    option -values -default {} -readonly 1


    typemethod validate {value} {
        return $value
    }


    constructor {args} {
        $self configurelist $args

        if {[llength $options(-values)] == 0} {
            return -code error \
                "invalid -values: \"\""
        }
    }


    method validate {value} {
        if {[lsearch -exact $options(-values) $value] == -1} {
            return -code error -errorcode INVALID \
    "invalid value \"$value\", should be one of: [join $options(-values) {, }]"
        }
        
        return $value
    }
}


snit::type ::snit::fpixels {


    option -min -default "" -readonly 1


    option -max -default "" -readonly 1


    variable min ""  ;# -min, no suffix
    variable max ""  ;# -max, no suffix


    typemethod validate {value} {
        if {[catch {winfo fpixels . $value} dummy]} {
            return -code error -errorcode INVALID \
                "invalid value \"$value\", expected fpixels"
        }

        return $value
    }


    constructor {args} {
        $self configurelist $args

        if {"" != $options(-min) && 
            [catch {winfo fpixels . $options(-min)} min]} {
            return -code error \
                "invalid -min: \"$options(-min)\""
        }

        if {"" != $options(-max) && 
            [catch {winfo fpixels . $options(-max)} max]} {
            return -code error \
                "invalid -max: \"$options(-max)\""
        }

        if {"" != $min &&
            "" != $max && 
            $max < $min} {
            return -code error "-max < -min"
        }
    }


    method validate {value} {
        $type validate $value
        
        set val [winfo fpixels . $value]

        if {("" != $min && $val < $min) ||
            ("" != $max && $val > $max)} {

            set msg "invalid value \"$value\", expected fpixels"

            if {"" != $min && "" != $max} {
                append msg " in range $options(-min), $options(-max)"
            } elseif {"" != $min} {
                append msg " no less than $options(-min)"
            }
        
            return -code error -errorcode INVALID $msg
        }

        return $value
    }
}


snit::type ::snit::integer {


    option -min -default "" -readonly 1


    option -max -default "" -readonly 1


    typemethod validate {value} {
        if {![string is integer -strict $value]} {
            return -code error -errorcode INVALID \
                "invalid value \"$value\", expected integer"
        }

        return $value
    }


    constructor {args} {
        $self configurelist $args

        if {"" != $options(-min) && 
            ![string is integer -strict $options(-min)]} {
            return -code error \
                "invalid -min: \"$options(-min)\""
        }

        if {"" != $options(-max) && 
            ![string is integer -strict $options(-max)]} {
            return -code error \
                "invalid -max: \"$options(-max)\""
        }

        if {"" != $options(-min) &&
            "" != $options(-max) && 
            $options(-max) < $options(-min)} {
            return -code error "-max < -min"
        }
    }


    method validate {value} {
        $type validate $value

        if {("" != $options(-min) && $value < $options(-min))       ||
            ("" != $options(-max) && $value > $options(-max))} {

            set msg "invalid value \"$value\", expected integer"

            if {"" != $options(-min) && "" != $options(-max)} {
                append msg " in range $options(-min), $options(-max)"
            } elseif {"" != $options(-min)} {
                append msg " no less than $options(-min)"
            }
        
            return -code error -errorcode INVALID $msg
        }

        return $value
    }
}


snit::type ::snit::listtype {


    option -type -readonly 1


    option -minlen -readonly 1 -default 0


    option -maxlen -readonly 1


    typemethod validate {value} {
        if {[catch {llength $value} result]} {
            return -code error -errorcode INVALID \
                "invalid value \"$value\", expected list"
        }

        return $value
    }

    
    constructor {args} {
        $self configurelist $args

        if {"" != $options(-minlen) && 
            (![string is integer -strict $options(-minlen)] ||
             $options(-minlen) < 0)} {
            return -code error \
                "invalid -minlen: \"$options(-minlen)\""
        }

        if {"" == $options(-minlen)} {
            set options(-minlen) 0
        }

        if {"" != $options(-maxlen) && 
            ![string is integer -strict $options(-maxlen)]} {
            return -code error \
                "invalid -maxlen: \"$options(-maxlen)\""
        }

        if {"" != $options(-maxlen) && 
            $options(-maxlen) < $options(-minlen)} {
            return -code error "-maxlen < -minlen"
        }
    }



    method validate {value} {
        $type validate $value

        set len [llength $value]

        if {$len < $options(-minlen)} {
            return -code error -errorcode INVALID \
              "value has too few elements; at least $options(-minlen) expected"
        } elseif {"" != $options(-maxlen)} {
            if {$len > $options(-maxlen)} {
                return -code error -errorcode INVALID \
         "value has too many elements; no more than $options(-maxlen) expected"
            }
        }

        if {"" != $options(-type)} {
            foreach item $value {
                set cmd $options(-type)
                lappend cmd validate $item
                uplevel \#0 $cmd
            }
        }
        
        return $value
    }
}


snit::type ::snit::pixels {


    option -min -default "" -readonly 1


    option -max -default "" -readonly 1


    variable min ""  ;# -min, no suffix
    variable max ""  ;# -max, no suffix


    typemethod validate {value} {
        if {[catch {winfo pixels . $value} dummy]} {
            return -code error -errorcode INVALID \
                "invalid value \"$value\", expected pixels"
        }

        return $value
    }


    constructor {args} {
        $self configurelist $args

        if {"" != $options(-min) && 
            [catch {winfo pixels . $options(-min)} min]} {
            return -code error \
                "invalid -min: \"$options(-min)\""
        }

        if {"" != $options(-max) && 
            [catch {winfo pixels . $options(-max)} max]} {
            return -code error \
                "invalid -max: \"$options(-max)\""
        }

        if {"" != $min &&
            "" != $max && 
            $max < $min} {
            return -code error "-max < -min"
        }
    }


    method validate {value} {
        $type validate $value
        
        set val [winfo pixels . $value]

        if {("" != $min && $val < $min) ||
            ("" != $max && $val > $max)} {

            set msg "invalid value \"$value\", expected pixels"

            if {"" != $min && "" != $max} {
                append msg " in range $options(-min), $options(-max)"
            } elseif {"" != $min} {
                append msg " no less than $options(-min)"
            }
        
            return -code error -errorcode INVALID $msg
        }

        return $value
    }
}


snit::type ::snit::stringtype {


    option -minlen -readonly 1 -default 0


    option -maxlen -readonly 1


    option -nocase -readonly 1 -default 0


    option -glob -readonly 1

    
    option -regexp -readonly 1
    

    typemethod validate {value} {
        return $value
    }

    
    constructor {args} {
        $self configurelist $args

        if {"" != $options(-minlen) && 
            (![string is integer -strict $options(-minlen)] ||
             $options(-minlen) < 0)} {
            return -code error \
                "invalid -minlen: \"$options(-minlen)\""
        }

        if {"" == $options(-minlen)} {
            set options(-minlen) 0
        }

        if {"" != $options(-maxlen) && 
            ![string is integer -strict $options(-maxlen)]} {
            return -code error \
                "invalid -maxlen: \"$options(-maxlen)\""
        }

        if {"" != $options(-maxlen) && 
            $options(-maxlen) < $options(-minlen)} {
            return -code error "-maxlen < -minlen"
        }

        if {[catch {snit::boolean validate $options(-nocase)} result]} {
            return -code error "invalid -nocase: $result"
        }

        if {"" != $options(-glob) && 
            [catch {string match $options(-glob) ""} dummy]} {
            return -code error \
                "invalid -glob: \"$options(-glob)\""
        }

        if {"" != $options(-regexp) && 
            [catch {regexp $options(-regexp) ""} dummy]} {
            return -code error \
                "invalid -regexp: \"$options(-regexp)\""
        }
    }



    method validate {value} {

        set len [string length $value]

        if {$len < $options(-minlen)} {
            return -code error -errorcode INVALID \
              "too short: at least $options(-minlen) characters expected"
        } elseif {"" != $options(-maxlen)} {
            if {$len > $options(-maxlen)} {
                return -code error -errorcode INVALID \
         "too long: no more than $options(-maxlen) characters expected"
            }
        }

        if {"" != $options(-glob)} {
            if {$options(-nocase)} {
                set result [string match -nocase $options(-glob) $value]
            } else {
                set result [string match $options(-glob) $value]
            }
            
            if {!$result} {
                return -code error -errorcode INVALID \
                    "invalid value \"$value\""
            }
        }
        
        if {"" != $options(-regexp)} {
            if {$options(-nocase)} {
                set result [regexp -nocase -- $options(-regexp) $value]
            } else {
                set result [regexp -- $options(-regexp) $value]
            }
            
            if {!$result} {
                return -code error -errorcode INVALID \
                    "invalid value \"$value\""
            }
        }
        
        return $value
    }
}


snit::type ::snit::window {

    typemethod validate {value} {
        if {![winfo exists $value]} {
            return -code error -errorcode INVALID \
                "invalid value \"$value\", value is not a window"
        }

        return $value
    }




    method validate {value} {
        $type validate $value
    }
}
