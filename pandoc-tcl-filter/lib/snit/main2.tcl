

namespace eval ::snit:: {
    namespace export \
        compile type widget widgetadaptor typemethod method macro
}


namespace eval ::snit:: {
    variable reservedArgs {type selfns win self}

    variable hulltypes {
	toplevel tk::toplevel
	frame tk::frame ttk::frame
	labelframe tk::labelframe ttk::labelframe
    }
}


namespace eval ::snit:: {

    variable typeTemplate

    variable nominalTypeProc

    variable simpleTypeProc
}

set ::snit::typeTemplate {


    namespace eval %TYPE% {%TYPEVARS%
    }


    interp alias {} %TYPE%::installhull  {} ::snit::RT.installhull %TYPE%
    interp alias {} %TYPE%::install      {} ::snit::RT.install %TYPE%
    interp alias {} %TYPE%::typevariable {} ::variable
    interp alias {} %TYPE%::variable     {} ::snit::RT.variable
    interp alias {} %TYPE%::mytypevar    {} ::snit::RT.mytypevar %TYPE%
    interp alias {} %TYPE%::typevarname  {} ::snit::RT.mytypevar %TYPE%
    interp alias {} %TYPE%::myvar        {} ::snit::RT.myvar
    interp alias {} %TYPE%::varname      {} ::snit::RT.myvar
    interp alias {} %TYPE%::codename     {} ::snit::RT.codename %TYPE%
    interp alias {} %TYPE%::myproc       {} ::snit::RT.myproc %TYPE%
    interp alias {} %TYPE%::mymethod     {} ::snit::RT.mymethod 
    interp alias {} %TYPE%::mytypemethod {} ::snit::RT.mytypemethod %TYPE%
    interp alias {} %TYPE%::from         {} ::snit::RT.from %TYPE%


    namespace eval %TYPE% {
        typevariable Snit_info
        set Snit_info(ns)      %TYPE%::
        set Snit_info(hasinstances) 1
        set Snit_info(simpledispatch) 0
        set Snit_info(canreplace) 0
        set Snit_info(counter) 0
        set Snit_info(widgetclass) {}
        set Snit_info(hulltype) frame
        set Snit_info(exceptmethods) {}
        set Snit_info(excepttypemethods) {}
        set Snit_info(tvardecs) {%TVARDECS%}
        set Snit_info(ivardecs) {%IVARDECS%}

        typevariable Snit_typemethodInfo
        array unset Snit_typemethodInfo

        typevariable Snit_methodInfo
        array unset Snit_methodInfo

        typevariable Snit_optionInfo
        array unset Snit_optionInfo
        set Snit_optionInfo(local)     {}
        set Snit_optionInfo(delegated) {}
        set Snit_optionInfo(starcomp)  {}
        set Snit_optionInfo(except)    {}
    }



    
    proc %TYPE%::Snit_instanceVars {selfns} {
        %INSTANCEVARS%
    }

    proc %TYPE%::Snit_typeconstructor {type} {
        %TVARDECS%
        namespace path [namespace parent $type]
        %TCONSTBODY%
    }



    proc %TYPE%::Snit_destructor {type selfns win self} { }


    %COMPILEDDEFS%


    %TYPE%::Snit_typeconstructor %TYPE%
}


set ::snit::nominalTypeProc {
    namespace eval %TYPE% {
        namespace ensemble create \
            -unknown [list ::snit::RT.UnknownTypemethod %TYPE% ""] \
            -prefixes 0
    }
}

set ::snit::simpleTypeProc {
    proc %TYPE% {args} {
        ::variable %TYPE%::Snit_info

        if {[llength $args] == 0} {
            if {$Snit_info(isWidget)} {
                error "wrong \# args: should be \"%TYPE% name args\""
            }
            
            lappend args %AUTO%
        }

        if {$Snit_info(isWidget)} {
            set command [list ::snit::RT.widget.typemethod.create %TYPE%]
        } else {
            set command [list ::snit::RT.type.typemethod.create %TYPE%]
        }

        set retval [catch {uplevel 1 $command $args} result]

        if {$retval} {
            if {$retval == 1} {
                global errorInfo
                global errorCode
                return -code error -errorinfo $errorInfo \
                    -errorcode $errorCode $result
            } else {
                return -code $retval $result
            }
        }

        return $result
    }
}




namespace eval ::snit:: {
    variable compiler ""

    variable compile

    variable methodInfo

    variable typemethodInfo

    variable reservedwords {}
}


proc ::snit::Comp.Init {} {
    variable compiler
    variable reservedwords

    if {$compiler eq ""} {
        set compiler [interp create]

	$compiler eval {
	    catch {close stdout}
	    catch {close stderr}
	    catch {close stdin}

            catch {package require ::snit::__does_not_exist__}

            rename proc _proc
            rename variable _variable
        }

        $compiler alias pragma          ::snit::Comp.statement.pragma
        $compiler alias widgetclass     ::snit::Comp.statement.widgetclass
        $compiler alias hulltype        ::snit::Comp.statement.hulltype
        $compiler alias constructor     ::snit::Comp.statement.constructor
        $compiler alias destructor      ::snit::Comp.statement.destructor
        $compiler alias option          ::snit::Comp.statement.option
        $compiler alias oncget          ::snit::Comp.statement.oncget
        $compiler alias onconfigure     ::snit::Comp.statement.onconfigure
        $compiler alias method          ::snit::Comp.statement.method
        $compiler alias typemethod      ::snit::Comp.statement.typemethod
        $compiler alias typeconstructor ::snit::Comp.statement.typeconstructor
        $compiler alias proc            ::snit::Comp.statement.proc
        $compiler alias typevariable    ::snit::Comp.statement.typevariable
        $compiler alias variable        ::snit::Comp.statement.variable
        $compiler alias typecomponent   ::snit::Comp.statement.typecomponent
        $compiler alias component       ::snit::Comp.statement.component
        $compiler alias delegate        ::snit::Comp.statement.delegate
        $compiler alias expose          ::snit::Comp.statement.expose

        set reservedwords [$compiler eval {info commands}]
    }
}

proc ::snit::Comp.Compile {which type body} {
    variable typeTemplate
    variable nominalTypeProc
    variable simpleTypeProc
    variable compile
    variable compiler
    variable methodInfo
    variable typemethodInfo

    if {![string match "::*" $type]} {
        set ns [uplevel 2 [list namespace current]]
        if {"::" != $ns} {
            append ns "::"
        }
        
        set type "$ns$type"
    }

    Comp.Init

    array unset methodInfo
    array unset typemethodInfo

    array unset compile
    set compile(type) $type
    set compile(defs) {}
    set compile(which) $which
    set compile(hasoptions) no
    set compile(localoptions) {}
    set compile(instancevars) {}
    set compile(typevars) {}
    set compile(delegatedoptions) {}
    set compile(ivprocdec) {}
    set compile(tvprocdec) {}
    set compile(typeconstructor) {}
    set compile(widgetclass) {}
    set compile(hulltype) {}
    set compile(localmethods) {}
    set compile(delegatesmethods) no
    set compile(hashierarchic) no
    set compile(components) {}
    set compile(typecomponents) {}
    set compile(varnames) {}
    set compile(typevarnames) {}
    set compile(hasconstructor) no
    set compile(-hastypedestroy) yes
    set compile(-hastypeinfo) yes
    set compile(-hastypemethods) yes
    set compile(-hasinfo) yes
    set compile(-hasinstances) yes
    set compile(-canreplace) no

    set isWidget [string match widget* $which]
    set isWidgetAdaptor [string match widgetadaptor $which]

    $compiler eval $body

    append compile(defs) \
        "\nset %TYPE%::Snit_info(isWidget) $isWidget\n"

    append compile(defs) \
        "\nset %TYPE%::Snit_info(isWidgetAdaptor) $isWidgetAdaptor\n"

    append compile(defs) "\nset %TYPE%::Snit_info(canreplace) $compile(-canreplace)\n"


    
    if {!$compile(-hastypemethods) && !$compile(-hasinstances)} {
        error "$which $type has neither typemethods nor instances"
    }

    if {$compile(-hastypemethods)} {
        if {$compile(-hastypeinfo)} {
            Comp.statement.delegate typemethod info \
                using {::snit::RT.typemethod.info %t}
        }

        if {$compile(-hastypedestroy)} {
            Comp.statement.delegate typemethod destroy \
                using {::snit::RT.typemethod.destroy %t}
        }

        append compile(defs) $nominalTypeProc
    } else {
        append compile(defs) $simpleTypeProc
    }

    if {$compile(-hasinstances)} {
        if {$compile(-hasinfo)} {
            Comp.statement.delegate method info \
                using {::snit::RT.method.info %t %n %w %s}
        }
        
        if {$compile(hasoptions)} {
            Comp.statement.variable options

            Comp.statement.delegate method cget \
                using {::snit::RT.method.cget %t %n %w %s}
            Comp.statement.delegate method configurelist \
                using {::snit::RT.method.configurelist %t %n %w %s}
            Comp.statement.delegate method configure \
                using {::snit::RT.method.configure %t %n %w %s}
        }

        if {!$compile(hasconstructor)} {
            if {$compile(hasoptions)} {
                Comp.statement.constructor {args} {
                    $self configurelist $args
                }
            } else {
                Comp.statement.constructor {} {}
            }
        }
        
        if {!$isWidget} {
            Comp.statement.delegate method destroy \
                using {::snit::RT.method.destroy %t %n %w %s}

            Comp.statement.delegate typemethod create \
                using {::snit::RT.type.typemethod.create %t}
        } else {
            Comp.statement.delegate typemethod create \
                using {::snit::RT.widget.typemethod.create %t}
        }

        append compile(defs) \
            "\narray set %TYPE%::Snit_methodInfo [list [array get methodInfo]]\n"
    } else {
        append compile(defs) "\nset %TYPE%::Snit_info(hasinstances) 0\n"
    }

    Comp.SaveOptionInfo

    append compile(defs) \
        "\narray set %TYPE%::Snit_typemethodInfo [list [array get typemethodInfo]]\n"

    if {$isWidget} {
        Comp.DefineComponent hull
    }

    set defscript [Expand $typeTemplate \
                       %COMPILEDDEFS% $compile(defs)]


    set defscript [Expand $defscript \
                       %TYPE%         $type \
                       %IVARDECS%     $compile(ivprocdec) \
                       %TVARDECS%     $compile(tvprocdec) \
                       %TCONSTBODY%   $compile(typeconstructor) \
                       %INSTANCEVARS% $compile(instancevars) \
                       %TYPEVARS%     $compile(typevars) \
		       ]

    array unset compile

    return [list $type $defscript]
}


proc ::snit::Comp.SaveOptionInfo {} {
    variable compile

    foreach option $compile(localoptions) {
        if {$compile(resource-$option) eq ""} {
            set compile(resource-$option) [string range $option 1 end]
        }

        if {$compile(class-$option) eq ""} {
            set compile(class-$option) [Capitalize $compile(resource-$option)]
        }

        
        Mappend compile(defs) {
            lappend %TYPE%::Snit_optionInfo(local) %OPTION%

            set %TYPE%::Snit_optionInfo(islocal-%OPTION%)   1
            set %TYPE%::Snit_optionInfo(resource-%OPTION%)  %RESOURCE%
            set %TYPE%::Snit_optionInfo(class-%OPTION%)     %CLASS%
            set %TYPE%::Snit_optionInfo(default-%OPTION%)   %DEFAULT%
            set %TYPE%::Snit_optionInfo(validate-%OPTION%)  %VALIDATE%
            set %TYPE%::Snit_optionInfo(configure-%OPTION%) %CONFIGURE%
            set %TYPE%::Snit_optionInfo(cget-%OPTION%)      %CGET%
            set %TYPE%::Snit_optionInfo(readonly-%OPTION%)  %READONLY%
            set %TYPE%::Snit_optionInfo(typespec-%OPTION%)  %TYPESPEC%
        }   %OPTION%    $option \
            %RESOURCE%  $compile(resource-$option) \
            %CLASS%     $compile(class-$option) \
            %DEFAULT%   [list $compile(-default-$option)] \
            %VALIDATE%  [list $compile(-validatemethod-$option)] \
            %CONFIGURE% [list $compile(-configuremethod-$option)] \
            %CGET%      [list $compile(-cgetmethod-$option)] \
            %READONLY%  $compile(-readonly-$option)               \
            %TYPESPEC%  [list $compile(-type-$option)]
    }
}


proc ::snit::Comp.Define {compResult} {
    set type [lindex $compResult 0]
    set defscript [lindex $compResult 1]

    if {[catch {eval $defscript} result]} {
        namespace delete $type
        catch {rename $type ""}
        error $result
    }

    return $type
}

proc ::snit::Comp.statement.pragma {args} {
    variable compile

    set errRoot "Error in \"pragma...\""

    foreach {opt val} $args {
        switch -exact -- $opt {
            -hastypeinfo    -
            -hastypedestroy -
            -hastypemethods -
            -hasinstances   -
            -simpledispatch -
            -hasinfo        -
            -canreplace     {
                if {![string is boolean -strict $val]} {
                    error "$errRoot, \"$opt\" requires a boolean value"
                }
                set compile($opt) $val
            }
            default {
                error "$errRoot, unknown pragma"
            }
        }
    }
}

proc ::snit::Comp.statement.widgetclass {name} {
    variable compile

    if {"widget" != $compile(which)} {
        error "widgetclass cannot be set for snit::$compile(which)s"
    }

    set initial [string index $name 0]
    if {![string is upper $initial]} {
        error "widgetclass \"$name\" does not begin with an uppercase letter"
    }

    if {"" != $compile(widgetclass)} {
        error "too many widgetclass statements"
    }

    Mappend compile(defs) {
        set  %TYPE%::Snit_info(widgetclass) %WIDGETCLASS%
    } %WIDGETCLASS% [list $name]

    set compile(widgetclass) $name
}

proc ::snit::Comp.statement.hulltype {name} {
    variable compile
    variable hulltypes

    if {"widget" != $compile(which)} {
        error "hulltype cannot be set for snit::$compile(which)s"
    }

    if {[lsearch -exact $hulltypes [string trimleft $name :]] == -1} {
        error "invalid hulltype \"$name\", should be one of\
		[join $hulltypes {, }]"
    }

    if {"" != $compile(hulltype)} {
        error "too many hulltype statements"
    }

    Mappend compile(defs) {
        set  %TYPE%::Snit_info(hulltype) %HULLTYPE%
    } %HULLTYPE% $name

    set compile(hulltype) $name
}

proc ::snit::Comp.statement.constructor {arglist body} {
    variable compile

    CheckArgs "constructor" $arglist

    set arglist [concat type selfns win self $arglist]

    set body "%TVARDECS%\n%IVARDECS%\n$body"

    set compile(hasconstructor) yes
    append compile(defs) "proc %TYPE%::Snit_constructor [list $arglist] [list $body]\n"
} 

proc ::snit::Comp.statement.destructor {body} {
    variable compile

    set body "%TVARDECS%\n%IVARDECS%\n$body"

    append compile(defs) "proc %TYPE%::Snit_destructor {type selfns win self} [list $body]\n\n"
} 

proc ::snit::Comp.statement.option {optionDef args} {
    variable compile

    set option [lindex $optionDef 0]
    set resourceName [lindex $optionDef 1]
    set className [lindex $optionDef 2]

    set errRoot "Error in \"option [list $optionDef]...\""

    if {![Comp.OptionNameIsValid $option]} {
        error "$errRoot, badly named option \"$option\""
    }

    if {$option in $compile(delegatedoptions)} {
        error "$errRoot, cannot define \"$option\" locally, it has been delegated"
    }

    if {!($option in $compile(localoptions))} {
        set compile(hasoptions) yes
        lappend compile(localoptions) $option
        
        set compile(resource-$option)         ""
        set compile(class-$option)            ""
        set compile(-default-$option)         ""
        set compile(-validatemethod-$option)  ""
        set compile(-configuremethod-$option) ""
        set compile(-cgetmethod-$option)      ""
        set compile(-readonly-$option)        0
        set compile(-type-$option)            ""
    }

    if {$resourceName ne ""} {
        if {$compile(resource-$option) eq ""} {
            set compile(resource-$option) $resourceName
        } elseif {$resourceName ne $compile(resource-$option)} {
            error "$errRoot, resource name redefined from \"$compile(resource-$option)\" to \"$resourceName\""
        }
    }

    if {$className ne ""} {
        if {$compile(class-$option) eq ""} {
            set compile(class-$option) $className
        } elseif {$className ne $compile(class-$option)} {
            error "$errRoot, class name redefined from \"$compile(class-$option)\" to \"$className\""
        }
    }

    if {[llength $args] == 1} {
        set compile(-default-$option) [lindex $args 0]
    } else {
        foreach {optopt val} $args {
            switch -exact -- $optopt {
                -default         -
                -validatemethod  -
                -configuremethod -
                -cgetmethod      {
                    set compile($optopt-$option) $val
                }
                -type {
                    set compile($optopt-$option) $val
                    
                    if {[llength $val] == 1} {
                        append compile(defs) \
                            "\nset %TYPE%::Snit_optionInfo(typeobj-$option) [list $val]\n"
                    } else {
                        set cmd [linsert $val 1 %TYPE%::Snit_TypeObj_%AUTO%]
                        append compile(defs) \
                            "\nset %TYPE%::Snit_optionInfo(typeobj-$option) \[$cmd\]\n"
                    }
                }
                -readonly        {
                    if {![string is boolean -strict $val]} {
                        error "$errRoot, -readonly requires a boolean, got \"$val\""
                    }
                    set compile($optopt-$option) $val
                }
                default {
                    error "$errRoot, unknown option definition option \"$optopt\""
                }
            }
        }
    }
}

proc ::snit::Comp.OptionNameIsValid {option} {
    if {![string match {-*} $option] || [string match {*[A-Z ]*} $option]} {
        return 0
    }

    return 1
}

proc ::snit::Comp.statement.oncget {option body} {
    variable compile

    set errRoot "Error in \"oncget $option...\""

    if {[lsearch -exact $compile(delegatedoptions) $option] != -1} {
        return -code error "$errRoot, option \"$option\" is delegated"
    }

    if {[lsearch -exact $compile(localoptions) $option] == -1} {
        return -code error "$errRoot, option \"$option\" unknown"
    }

    Comp.statement.method _cget$option {_option} $body
    Comp.statement.option $option -cgetmethod _cget$option
} 

proc ::snit::Comp.statement.onconfigure {option arglist body} {
    variable compile

    if {[lsearch -exact $compile(delegatedoptions) $option] != -1} {
        return -code error "onconfigure $option: option \"$option\" is delegated"
    }

    if {[lsearch -exact $compile(localoptions) $option] == -1} {
        return -code error "onconfigure $option: option \"$option\" unknown"
    }

    if {[llength $arglist] != 1} {
        error \
       "onconfigure $option handler should have one argument, got \"$arglist\""
    }

    CheckArgs "onconfigure $option" $arglist

    set arglist [concat _option $arglist]

    Comp.statement.method _configure$option $arglist $body
    Comp.statement.option $option -configuremethod _configure$option
} 

proc ::snit::Comp.statement.method {method arglist body} {
    variable compile
    variable methodInfo

    Comp.CheckMethodName $method 0 ::snit::methodInfo \
        "Error in \"method [list $method]...\""

    if {[llength $method] > 1} {
        set compile(hashierarchic) yes
    }

    lappend compile(localmethods) $method

    CheckArgs "method [list $method]" $arglist

    set arglist [concat type selfns win self $arglist]

    set body "%TVARDECS%\n%IVARDECS%\n# END snit method prolog\n$body"

    if {[llength $method] == 1} {
        set methodInfo($method) {0 "%t::Snit_method%m %t %n %w %s" ""}
        Mappend compile(defs) {
            proc %TYPE%::Snit_method%METHOD% %ARGLIST% %BODY% 
        } %METHOD% $method %ARGLIST% [list $arglist] %BODY% [list $body] 
    } else {
        set methodInfo($method) {0 "%t::Snit_hmethod%j %t %n %w %s" ""}

        Mappend compile(defs) {
            proc %TYPE%::Snit_hmethod%JMETHOD% %ARGLIST% %BODY% 
        } %JMETHOD% [join $method _] %ARGLIST% [list $arglist] \
            %BODY% [list $body] 
    }
} 


proc ::snit::Comp.CheckMethodName {method delFlag infoVar errRoot} {
    upvar $infoVar methodInfo

    if {[catch {lindex $method 0}]} {
        error "$errRoot, the name \"$method\" must have list syntax."
    }

    if {![catch {set methodInfo($method)} data]} {
        if {[lindex $data 0] == 1} {
            error "$errRoot, \"$method\" has submethods."
        }
       
        if {$delFlag && [lindex $data 2] eq ""} {
            error "$errRoot, \"$method\" has been defined locally."
        } elseif {!$delFlag && [lindex $data 2] ne ""} {
            error "$errRoot, \"$method\" has been delegated"
        }
    }

    if {[llength $method] > 1} {
        set prefix {}
        set tokens $method
        while {[llength $tokens] > 1} {
            lappend prefix [lindex $tokens 0]
            set tokens [lrange $tokens 1 end]

            if {![catch {set methodInfo($prefix)} result]} {
                if {[lindex $result 0] == 0} {
                    error "$errRoot, \"$prefix\" has no submethods."
                }
            }
            
            set methodInfo($prefix) [list 1]
        }
    }
}

proc ::snit::Comp.statement.typemethod {method arglist body} {
    variable compile
    variable typemethodInfo

    Comp.CheckMethodName $method 0 ::snit::typemethodInfo \
        "Error in \"typemethod [list $method]...\""

    CheckArgs "typemethod $method" $arglist

    set arglist [concat type $arglist]

    set body "%TVARDECS%\n# END snit method prolog\n$body"

    if {[llength $method] == 1} {
        set typemethodInfo($method) {0 "%t::Snit_typemethod%m %t" ""}

        Mappend compile(defs) {
            proc %TYPE%::Snit_typemethod%METHOD% %ARGLIST% %BODY%
        } %METHOD% $method %ARGLIST% [list $arglist] %BODY% [list $body]
    } else {
        set typemethodInfo($method) {0 "%t::Snit_htypemethod%j %t" ""}

        Mappend compile(defs) {
            proc %TYPE%::Snit_htypemethod%JMETHOD% %ARGLIST% %BODY%
        } %JMETHOD% [join $method _] \
            %ARGLIST% [list $arglist] %BODY% [list $body]
    }
} 


proc ::snit::Comp.statement.typeconstructor {body} {
    variable compile

    if {"" != $compile(typeconstructor)} {
        error "too many typeconstructors"
    }

    set compile(typeconstructor) $body
} 

proc ::snit::Comp.statement.proc {proc arglist body} {
    variable compile

    if {[lsearch -exact $arglist selfns] != -1} {
        set body "%IVARDECS%\n$body"
    }

    set body "%TVARDECS%\n$body"

    append compile(defs) "

        proc [list %TYPE%::$proc $arglist $body]
    "
} 

proc ::snit::Comp.statement.typevariable {name args} {
    variable compile

    set errRoot "Error in \"typevariable $name...\""

    set len [llength $args]
    
    if {$len > 2 ||
        ($len == 2 && [lindex $args 0] ne "-array")} {
        error "$errRoot, too many initializers"
    }

    if {[lsearch -exact $compile(varnames) $name] != -1} {
        error "$errRoot, \"$name\" is already an instance variable"
    }

    lappend compile(typevarnames) $name

    if {$len == 1} {
        append compile(typevars) \
		"\n\t    [list ::variable $name [lindex $args 0]]"
    } elseif {$len == 2} {
        append compile(typevars) \
            "\n\t    [list ::variable $name]"
        append compile(typevars) \
            "\n\t    [list array set $name [lindex $args 1]]"
    } else {
        append compile(typevars) \
		"\n\t    [list ::variable $name]"
    }

    if {$compile(tvprocdec) eq ""} {
        set compile(tvprocdec) "\n\t"
        append compile(tvprocdec) "namespace upvar [list $compile(type)]"
    }
    append compile(tvprocdec) " [list $name $name]"
} 

proc ::snit::Comp.statement.variable {name args} {
    variable compile

    set errRoot "Error in \"variable $name...\""

    set len [llength $args]
    
    if {$len > 2 ||
        ($len == 2 && [lindex $args 0] ne "-array")} {
        error "$errRoot, too many initializers"
    }

    if {[lsearch -exact $compile(typevarnames) $name] != -1} {
        error "$errRoot, \"$name\" is already a typevariable"
    }

    lappend compile(varnames) $name

    append  compile(instancevars) "\n"
    Mappend compile(instancevars) {::variable ${selfns}::%N} %N $name 

    if {$len == 1} {
        append compile(instancevars) \
            "\nset $name [list [lindex $args 0]]\n"
    } elseif {$len == 2} {
        append compile(instancevars) \
            "\narray set $name [list [lindex $args 1]]\n"
    } 

    if {$compile(ivprocdec) eq ""} {
        set compile(ivprocdec) "\n\t"
        append compile(ivprocdec) {namespace upvar $selfns}
    }
    append compile(ivprocdec) " [list $name $name]"
} 


proc ::snit::Comp.statement.typecomponent {component args} {
    variable compile

    set errRoot "Error in \"typecomponent $component...\""

    Comp.DefineTypecomponent $component $errRoot

    set publicMethod ""
    set inheritFlag 0

    foreach {opt val} $args {
        switch -exact -- $opt {
            -public {
                set publicMethod $val
            }
            -inherit {
                set inheritFlag $val
                if {![string is boolean $inheritFlag]} {
    error "typecomponent $component -inherit: expected boolean value, got \"$val\""
                }
            }
            default {
                error "typecomponent $component: Invalid option \"$opt\""
            }
        }
    }

    if {$publicMethod ne ""} {
        Comp.statement.delegate typemethod [list $publicMethod *] to $component
    }

    if {$inheritFlag} {
        Comp.statement.delegate typemethod "*" to $component
    }

}



proc ::snit::Comp.DefineTypecomponent {component {errRoot "Error"}} {
    variable compile

    if {[lsearch -exact $compile(varnames) $component] != -1} {
        error "$errRoot, \"$component\" is already an instance variable"
    }

    if {[lsearch -exact $compile(typecomponents) $component] == -1} {
        lappend compile(typecomponents) $component

        Comp.statement.typevariable $component ""

        Mappend compile(typevars) {
            trace add variable %COMP% write \
                [list ::snit::RT.TypecomponentTrace [list %TYPE%] %COMP%]
        } %TYPE% $compile(type) %COMP% $component
    }
} 


proc ::snit::Comp.statement.component {component args} {
    variable compile

    set errRoot "Error in \"component $component...\""

    Comp.DefineComponent $component $errRoot

    set publicMethod ""
    set inheritFlag 0

    foreach {opt val} $args {
        switch -exact -- $opt {
            -public {
                set publicMethod $val
            }
            -inherit {
                set inheritFlag $val
                if {![string is boolean $inheritFlag]} {
    error "component $component -inherit: expected boolean value, got \"$val\""
                }
            }
            default {
                error "component $component: Invalid option \"$opt\""
            }
        }
    }

    if {$publicMethod ne ""} {
        Comp.statement.delegate method [list $publicMethod *] to $component
    }

    if {$inheritFlag} {
        Comp.statement.delegate method "*" to $component
        Comp.statement.delegate option "*" to $component
    }
}



proc ::snit::Comp.DefineComponent {component {errRoot "Error"}} {
    variable compile

    if {[lsearch -exact $compile(typevarnames) $component] != -1} {
        error "$errRoot, \"$component\" is already a typevariable"
    }

    if {[lsearch -exact $compile(components) $component] == -1} {
        lappend compile(components) $component

        Comp.statement.variable $component ""

        Mappend compile(instancevars) {
            trace add variable ${selfns}::%COMP% write \
                [list ::snit::RT.ComponentTrace [list %TYPE%] $selfns %COMP%]
        } %TYPE% $compile(type) %COMP% $component
    }
} 

proc ::snit::Comp.statement.delegate {what name args} {
    switch $what {
        typemethod { Comp.DelegatedTypemethod $name $args }
        method     { Comp.DelegatedMethod     $name $args }
        option     { Comp.DelegatedOption     $name $args }
        default {
            error "Error in \"delegate $what $name...\", \"$what\"?"
        }
    }

    if {([llength $args] % 2) != 0} {
        error "Error in \"delegate $what $name...\", invalid syntax"
    }
}


proc ::snit::Comp.DelegatedTypemethod {method arglist} {
    variable compile
    variable typemethodInfo

    set errRoot "Error in \"delegate typemethod [list $method]...\""

    set component ""
    set target ""
    set exceptions {}
    set pattern ""
    set methodTail [lindex $method end]

    foreach {opt value} $arglist {
        switch -exact $opt {
            to     { set component $value  }
            as     { set target $value     }
            except { set exceptions $value }
            using  { set pattern $value    }
            default {
                error "$errRoot, unknown delegation option \"$opt\""
            }
        }
    }

    if {$component eq "" && $pattern eq ""} {
        error "$errRoot, missing \"to\""
    }

    if {$methodTail eq "*" && $target ne ""} {
        error "$errRoot, cannot specify \"as\" with \"*\""
    }

    if {$methodTail ne "*" && $exceptions ne ""} {
        error "$errRoot, can only specify \"except\" with \"*\"" 
    }

    if {$pattern ne "" && $target ne ""} {
        error "$errRoot, cannot specify both \"as\" and \"using\""
    }

    foreach token [lrange $method 1 end-1] {
        if {$token eq "*"} {
            error "$errRoot, \"*\" must be the last token."
        }
    }

    if {$component ne ""} {
        Comp.DefineTypecomponent $component $errRoot
    }

    if {$pattern eq ""} {
        if {$methodTail eq "*"} {
            set pattern "%c %m"
        } elseif {$target ne ""} {
            set pattern "%c $target"
        } else {
            set pattern "%c %m"
        }
    }

    if {[catch {lindex $pattern 0} result]} {
        error "$errRoot, the using pattern, \"$pattern\", is not a valid list"
    }

    Comp.CheckMethodName $method 1 ::snit::typemethodInfo $errRoot

    set typemethodInfo($method) [list 0 $pattern $component]

    if {[string equal $methodTail "*"]} {
        Mappend compile(defs) {
            set %TYPE%::Snit_info(excepttypemethods) %EXCEPT%
        } %EXCEPT% [list $exceptions]
    }
}



proc ::snit::Comp.DelegatedMethod {method arglist} {
    variable compile
    variable methodInfo

    set errRoot "Error in \"delegate method [list $method]...\""

    set component ""
    set target ""
    set exceptions {}
    set pattern ""
    set methodTail [lindex $method end]

    foreach {opt value} $arglist {
        switch -exact $opt {
            to     { set component $value  }
            as     { set target $value     }
            except { set exceptions $value }
            using  { set pattern $value    }
            default {
                error "$errRoot, unknown delegation option \"$opt\""
            }
        }
    }

    if {$component eq "" && $pattern eq ""} {
        error "$errRoot, missing \"to\""
    }

    if {$methodTail eq "*" && $target ne ""} {
        error "$errRoot, cannot specify \"as\" with \"*\""
    }

    if {$methodTail ne "*" && $exceptions ne ""} {
        error "$errRoot, can only specify \"except\" with \"*\"" 
    }

    if {$pattern ne "" && $target ne ""} {
        error "$errRoot, cannot specify both \"as\" and \"using\""
    }

    foreach token [lrange $method 1 end-1] {
        if {$token eq "*"} {
            error "$errRoot, \"*\" must be the last token."
        }
    }

    set compile(delegatesmethods) yes

    if {$component ne ""} {
        if {[lsearch -exact $compile(typecomponents) $component] == -1} {
            Comp.DefineComponent $component $errRoot
        }
    }

    if {$pattern eq ""} {
        if {$methodTail eq "*"} {
            set pattern "%c %m"
        } elseif {$target ne ""} {
            set pattern "%c $target"
        } else {
            set pattern "%c %m"
        }
    }

    if {[catch {lindex $pattern 0} result]} {
        error "$errRoot, the using pattern, \"$pattern\", is not a valid list"
    }

    Comp.CheckMethodName $method 1 ::snit::methodInfo $errRoot

    set methodInfo($method) [list 0 $pattern $component]

    if {[string equal $methodTail "*"]} {
        Mappend compile(defs) {
            set %TYPE%::Snit_info(exceptmethods) %EXCEPT%
        } %EXCEPT% [list $exceptions]
    }
} 


proc ::snit::Comp.DelegatedOption {optionDef arglist} {
    variable compile

    set option [lindex $optionDef 0]
    set resourceName [lindex $optionDef 1]
    set className [lindex $optionDef 2]

    set errRoot "Error in \"delegate option [list $optionDef]...\""

    set component ""
    set target ""
    set exceptions {}

    foreach {opt value} $arglist {
        switch -exact $opt {
            to     { set component $value  }
            as     { set target $value     }
            except { set exceptions $value }
            default {
                error "$errRoot, unknown delegation option \"$opt\""
            }
        }
    }

    if {$component eq ""} {
        error "$errRoot, missing \"to\""
    }

    if {$option eq "*" && $target ne ""} {
        error "$errRoot, cannot specify \"as\" with \"delegate option *\""
    }

    if {$option ne "*" && $exceptions ne ""} {
        error "$errRoot, can only specify \"except\" with \"delegate option *\"" 
    }


    if {"*" != $option} {
        if {![Comp.OptionNameIsValid $option]} {
            error "$errRoot, badly named option \"$option\""
        }
    }

    if {$option in $compile(localoptions)} {
        error "$errRoot, \"$option\" has been defined locally"
    }

    if {$option in $compile(delegatedoptions)} {
        error "$errRoot, \"$option\" is multiply delegated"
    }

    Comp.DefineComponent $component $errRoot

    if {![string equal $option "*"] &&
        [string equal $target ""]} {
        set target $option
    }

    set compile(hasoptions) yes

    if {![string equal $option "*"]} {
        lappend compile(delegatedoptions) $option


        if {"" == $resourceName} {
            set resourceName [string range $option 1 end]
        }

        if {"" == $className} {
            set className [Capitalize $resourceName]
        }

        Mappend  compile(defs) {
            set %TYPE%::Snit_optionInfo(islocal-%OPTION%) 0
            set %TYPE%::Snit_optionInfo(resource-%OPTION%) %RES%
            set %TYPE%::Snit_optionInfo(class-%OPTION%) %CLASS%
            lappend %TYPE%::Snit_optionInfo(delegated) %OPTION%
            set %TYPE%::Snit_optionInfo(target-%OPTION%) [list %COMP% %TARGET%]
            lappend %TYPE%::Snit_optionInfo(delegated-%COMP%) %OPTION%
        }   %OPTION% $option \
            %COMP% $component \
            %TARGET% $target \
            %RES% $resourceName \
            %CLASS% $className 
    } else {
        Mappend  compile(defs) {
            set %TYPE%::Snit_optionInfo(starcomp) %COMP%
            set %TYPE%::Snit_optionInfo(except) %EXCEPT%
        } %COMP% $component %EXCEPT% [list $exceptions]
    }
} 


proc ::snit::Comp.statement.expose {component {"as" ""} {methodname ""}} {
    variable compile


    Comp.DefineComponent $component

    if {[string equal $methodname ""]} {
        set methodname $component
    }

    Comp.statement.method $methodname args [Expand {
        if {[llength $args] == 0} {
            return $%COMPONENT%
        }

        if {[string equal $%COMPONENT% ""]} {
            error "undefined component \"%COMPONENT%\""
        }


        set cmd [linsert $args 0 $%COMPONENT%]
        return [uplevel 1 $cmd]
    } %COMPONENT% $component]
}




proc ::snit::compile {which type body} {
    return [Comp.Compile $which $type $body]
}

proc ::snit::type {type body} {
    return [Comp.Define [Comp.Compile type $type $body]]
}

proc ::snit::widget {type body} {
    return [Comp.Define [Comp.Compile widget $type $body]]
}

proc ::snit::widgetadaptor {type body} {
    return [Comp.Define [Comp.Compile widgetadaptor $type $body]]
}

proc ::snit::typemethod {type method arglist body} {
    if {![info exists ${type}::Snit_info]} {
        error "no such type: \"$type\""
    }

    upvar ${type}::Snit_info           Snit_info
    upvar ${type}::Snit_typemethodInfo Snit_typemethodInfo

    Comp.CheckMethodName $method 0 ${type}::Snit_typemethodInfo \
        "Cannot define \"$method\""

    CheckArgs "snit::typemethod $type $method" $arglist

    set arglist [concat type $arglist]

    set body "$Snit_info(tvardecs)\n$body"

    if {[llength $method] == 1} {
        set Snit_typemethodInfo($method) {0 "%t::Snit_typemethod%m %t" ""}
        uplevel 1 [list proc ${type}::Snit_typemethod$method $arglist $body]
    } else {
        set Snit_typemethodInfo($method) {0 "%t::Snit_htypemethod%j %t" ""}
        set suffix [join $method _]
        uplevel 1 [list proc ${type}::Snit_htypemethod$suffix $arglist $body]
    }
}

proc ::snit::method {type method arglist body} {
    if {![info exists ${type}::Snit_info]} {
        error "no such type: \"$type\""
    }

    upvar ${type}::Snit_methodInfo  Snit_methodInfo
    upvar ${type}::Snit_info        Snit_info

    Comp.CheckMethodName $method 0 ${type}::Snit_methodInfo \
        "Cannot define \"$method\""

    CheckArgs "snit::method $type $method" $arglist

    set arglist [concat type selfns win self $arglist]

    set body "$Snit_info(tvardecs)\n$Snit_info(ivardecs)\n$body"

    if {[llength $method] == 1} {
        set Snit_methodInfo($method) {0 "%t::Snit_method%m %t %n %w %s" ""}
        uplevel 1 [list proc ${type}::Snit_method$method $arglist $body]
    } else {
        set Snit_methodInfo($method) {0 "%t::Snit_hmethod%j %t %n %w %s" ""}

        set suffix [join $method _]
        uplevel 1 [list proc ${type}::Snit_hmethod$suffix $arglist $body]
    }
}

proc ::snit::macro {name arglist body} {
    variable compiler
    variable reservedwords

    Comp.Init

    if {[lsearch -exact $reservedwords $name] != -1} {
        error "invalid macro name \"$name\""
    }

    set ns [namespace qualifiers $name]

    if {$ns ne ""} {
        $compiler eval "namespace eval $ns {}"
    }

    $compiler eval [list _proc $name $arglist $body]
}


proc ::snit::Expand {template args} {
    return [string map $args $template]
}

proc ::snit::Mappend {varname template args} {
    upvar $varname myvar

    append myvar [string map $args $template]
}

proc ::snit::CheckArgs {which arglist} {
    variable reservedArgs
    
    foreach name $reservedArgs {
        if {$name in $arglist} {
            error "$which's arglist may not contain \"$name\" explicitly"
        }
    }
}

proc ::snit::Capitalize {text} {
    return [string toupper $text 0]
}





proc ::snit::RT.type.typemethod.create {type name args} {
    variable ${type}::Snit_info
    variable ${type}::Snit_optionInfo

    if {![string match "::*" $name]} {
        set ns [uplevel 1 [list namespace current]]
        if {"::" != $ns} {
            append ns "::"
        }
        
        set name "$ns$name"
    }

    if {[string match "*%AUTO%*" $name]} {
        set name [::snit::RT.UniqueName Snit_info(counter) $type $name]
    } elseif {!$Snit_info(canreplace) && [llength [info commands $name]]} {
        error "command \"$name\" already exists"
    }

    set selfns \
        [::snit::RT.UniqueInstanceNamespace Snit_info(counter) $type]
    namespace eval $selfns {}

    RT.MakeInstanceCommand $type $selfns $name

    namespace upvar ${selfns} options options

    foreach opt $Snit_optionInfo(local) {
        set options($opt) $Snit_optionInfo(default-$opt)
    }
        
    ${type}::Snit_instanceVars $selfns

    set errcode [catch {
        RT.ConstructInstance $type $selfns $name $args
    } result]

    if {$errcode} {
        global errorInfo
        global errorCode
        
        set theInfo $errorInfo
        set theCode $errorCode

        ::snit::RT.DestroyObject $type $selfns $name
        error "Error in constructor: $result" $theInfo $theCode
    }

    return $name
}


proc ::snit::RT.widget.typemethod.create {type name args} {
    variable ${type}::Snit_info
    variable ${type}::Snit_optionInfo

    if {[string match "*%AUTO%*" $name]} {
        set name [::snit::RT.UniqueName Snit_info(counter) $type $name]
    }
            
    set selfns \
        [::snit::RT.UniqueInstanceNamespace Snit_info(counter) $type]
    namespace eval $selfns { }
            
    namespace upvar $selfns options options

    foreach opt $Snit_optionInfo(local) {
        set options($opt) $Snit_optionInfo(default-$opt)
    }

    ${type}::Snit_instanceVars $selfns

    if {!$Snit_info(isWidgetAdaptor)} {
	set wclass $Snit_info(widgetclass)
        if {$Snit_info(widgetclass) eq ""} {
	    set idx [lsearch -exact $args -class]
	    if {$idx >= 0 && ($idx%2 == 0)} {
		set wclass [lindex $args [expr {$idx+1}]]
		set args [lreplace $args $idx [expr {$idx+1}]]
	    } else {
		set wclass [::snit::Capitalize [namespace tail $type]]
	    }
	}

        set self $name
        package require Tk
        ${type}::installhull using $Snit_info(hulltype) -class $wclass

        foreach opt $Snit_optionInfo(local) {
            set dbval [RT.OptionDbGet $type $name $opt]

            if {"" != $dbval} {
                set options($opt) $dbval
            }
        }
    }

    set errcode [catch {
        RT.ConstructInstance $type $selfns $name $args

        ::snit::RT.Component $type $selfns hull


        bind Snit$type$name <Destroy> [::snit::Expand {
            ::snit::RT.DestroyObject %TYPE% %NS% %W
        } %TYPE% $type %NS% $selfns]

        set taglist [bindtags $name]
        set ndx [lsearch -exact $taglist $name]
        incr ndx
        bindtags $name [linsert $taglist $ndx Snit$type$name]
    } result]

    if {$errcode} {
        global errorInfo
        global errorCode

        set theInfo $errorInfo
        set theCode $errorCode
        ::snit::RT.DestroyObject $type $selfns $name
        error "Error in constructor: $result" $theInfo $theCode
    }

    return $name
}



proc ::snit::RT.MakeInstanceCommand {type selfns instance} {
    variable ${type}::Snit_info
        

    namespace upvar $selfns Snit_instance Snit_instance

    set Snit_instance $instance

    if {$Snit_info(isWidget)} {
        set procname ::$instance
    } else {
        set procname $instance
    }


    set unknownCmd [list ::snit::RT.UnknownMethod $type $selfns $instance ""]
    set createCmd [list namespace ensemble create \
                       -command $procname \
                       -unknown $unknownCmd \
                       -prefixes 0]

    namespace eval $selfns $createCmd

    trace add command $procname {rename delete} \
        [list ::snit::RT.InstanceTrace $type $selfns $instance]
}


proc ::snit::RT.InstanceTrace {type selfns win old new op} {
    variable ${type}::Snit_info


    if {[catch {
        if {"" == $new} {
            if {$Snit_info(isWidget)} {
                destroy $win
            } else {
                ::snit::RT.DestroyObject $type $selfns $win
            }
        } else {
            variable ${selfns}::Snit_instance
            set Snit_instance [uplevel 1 [list namespace which -command $new]]
            
            RT.ClearInstanceCaches $selfns
        }
    } result]} {
        global errorInfo
        set ei $errorInfo
        catch {console show}
        puts "Error in ::snit::RT.InstanceTrace $type $selfns $win $old $new $op:"
        puts $ei
    }
}

proc ::snit::RT.ConstructInstance {type selfns instance arglist} {
    variable ${type}::Snit_optionInfo
    variable ${selfns}::Snit_iinfo

    set Snit_iinfo(constructed) 0

    eval [linsert $arglist 0 \
              ${type}::Snit_constructor $type $selfns $instance $instance]

    set Snit_iinfo(constructed) 1

    foreach option $Snit_optionInfo(local) {
        set value [set ${selfns}::options($option)]

        if {$Snit_optionInfo(typespec-$option) ne ""} {
            if {[catch {
                $Snit_optionInfo(typeobj-$option) validate $value
            } result]} {
                return -code error "invalid $option default: $result"
            }
        }
    }

    foreach opt $Snit_optionInfo(local) {
        if {$Snit_optionInfo(readonly-$opt)} {
            unset -nocomplain ${selfns}::Snit_configureCache($opt)
        }
    }

    return
}

proc ::snit::RT.UniqueName {countervar type name} {
    upvar $countervar counter 
    while 1 {
        incr counter
        if {$counter > 2147483646} {
            set counter 0
        }
        set auto "[namespace tail $type]$counter"
        set candidate [Expand $name %AUTO% $auto]
        if {![llength [info commands $candidate]]} {
            return $candidate
        }
    }
}


proc ::snit::RT.UniqueInstanceNamespace {countervar type} {
    upvar $countervar counter 
    while 1 {
        incr counter
        if {$counter > 2147483646} {
            set counter 0
        }
        set ins "${type}::Snit_inst${counter}"
        if {![namespace exists $ins]} {
            return $ins
        }
    }
}

proc ::snit::RT.OptionDbGet {type self opt} {
    variable ${type}::Snit_optionInfo

    return [option get $self \
                $Snit_optionInfo(resource-$opt) \
                $Snit_optionInfo(class-$opt)]
}



proc ::snit::RT.method.destroy {type selfns win self} {
    variable ${selfns}::Snit_iinfo

    if {!$Snit_iinfo(constructed)} {
        return -code error "Called 'destroy' method in constructor"
    }

    ::snit::RT.DestroyObject $type $selfns $win
}


proc ::snit::RT.DestroyObject {type selfns win} {
    variable ${type}::Snit_info

    if {[info exists ${selfns}::Snit_instance]} {
        namespace upvar $selfns Snit_instance instance
            
        RT.RemoveInstanceTrace $type $selfns $win $instance
            
        ${type}::Snit_destructor $type $selfns $win $instance

                
        if {$Snit_info(isWidget)} {
            set hullcmd [::snit::RT.Component $type $selfns hull]
            
            catch {rename $instance ""}

            bind Snit$type$win <Destroy> ""

            if {[llength [info commands $hullcmd]]} {
                rename $hullcmd ::$instance

                destroy $instance
            }
        } else {
            catch {rename $instance ""}
        }
    }

    namespace delete $selfns

    return
}


proc ::snit::RT.RemoveInstanceTrace {type selfns win instance} {
    variable ${type}::Snit_info

    if {$Snit_info(isWidget)} {
        set procname ::$instance
    } else {
        set procname $instance
    }
        
    catch {
        trace remove command $procname {rename delete} \
            [list ::snit::RT.InstanceTrace $type $selfns $win]
    }
}



proc ::snit::RT.TypecomponentTrace {type component n1 n2 op} {
    namespace upvar $type \
        Snit_info           Snit_info \
        $component          cvar      \
        Snit_typecomponents Snit_typecomponents

        
    set Snit_typecomponents($component) $cvar


    namespace ensemble configure $type -map {}
}


proc snit::RT.UnknownTypemethod {type eId eCmd method args} {
    namespace upvar $type \
        Snit_typemethodInfo  Snit_typemethodInfo \
        Snit_typecomponents  Snit_typecomponents \
        Snit_info            Snit_info
    
    set implicitCreate 0
    set instanceName ""

    set fullMethod $eId
    lappend fullMethod $method
    set starredMethod [concat $eId *]
    set methodTail $method

    if {[info exists Snit_typemethodInfo($fullMethod)]} {
        set key $fullMethod
    } elseif {[info exists Snit_typemethodInfo($starredMethod)]} {
        if {[lsearch -exact $Snit_info(excepttypemethods) $methodTail] == -1} {
            set key $starredMethod
        } else {
            return [list ]
        }
    } elseif {[llength $fullMethod] > 1} {
	return [list ]
    } elseif {$Snit_info(hasinstances)} {

        if {[set ${type}::Snit_info(isWidget)] && 
            ![string match ".*" $method]} {
            return [list ]
        }

        if {$method eq "info" || $method eq "destroy"} {
            return [list ]
        }

        set implicitCreate 1
        set instanceName $method
        set key create
        set method create
    } else {
        return [list ]
    }
    
    foreach {flag pattern compName} $Snit_typemethodInfo($key) {}

    if {$flag == 1} {
        lappend eId $method

        set newCmd ${type}::Snit_ten[llength $eId]_[join $eId _]

        set unknownCmd [list ::snit::RT.UnknownTypemethod \
                            $type $eId]

        set createCmd [list namespace ensemble create \
                           -command $newCmd \
                           -unknown $unknownCmd \
                           -prefixes 0]

        namespace eval $type $createCmd
        
        set map [namespace ensemble configure $eCmd -map]

        dict append map $method $newCmd

        namespace ensemble configure $eCmd -map $map

        return [list ]
    }

    set subList [list \
                     %% % \
                     %t $type \
                     %M $fullMethod \
                     %m [lindex $fullMethod end] \
                     %j [join $fullMethod _]]
    
    if {$compName ne ""} {
        if {![info exists Snit_typecomponents($compName)]} {
            error "$type delegates typemethod \"$method\" to undefined typecomponent \"$compName\""
        }
        
        lappend subList %c [list $Snit_typecomponents($compName)]
    }

    set command {}

    foreach subpattern $pattern {
        lappend command [string map $subList $subpattern]
    }

    if {$implicitCreate} {
        lappend command $instanceName
        return $command
    }


    set cmd [lindex $command 0]

    if {[string index $cmd 0] ne ":"} {
        set command [lreplace $command 0 0 "::$cmd"]
    }

    set map [namespace ensemble configure $eCmd -map]

    dict append map $method $command

    namespace ensemble configure $eCmd -map $map

    return [list ]
}


proc ::snit::RT.Component {type selfns name} {
    variable ${selfns}::Snit_components

    if {[catch {set Snit_components($name)} result]} {
        variable ${selfns}::Snit_instance

        error "component \"$name\" is undefined in $type $Snit_instance"
    }
    
    return $result
}


proc ::snit::RT.ComponentTrace {type selfns component n1 n2 op} {
    namespace upvar $type Snit_info Snit_info
    namespace upvar $selfns \
        $component      cvar            \
        Snit_components Snit_components
        
    if {"hull" == $component && 
        $Snit_info(isWidget) &&
        [info exists Snit_components($component)]} {
        set cvar $Snit_components($component)
        error "The hull component cannot be redefined"
    }

    set Snit_components($component) $cvar

    RT.ClearInstanceCaches $selfns
}


proc ::snit::RT.UnknownMethod {type selfns win eId eCmd method args} {
    variable ${type}::Snit_info
    variable ${type}::Snit_methodInfo
    variable ${type}::Snit_typecomponents
    variable ${selfns}::Snit_components

    set self [set ${selfns}::Snit_instance]

    set fullMethod $eId
    lappend fullMethod $method
    set starredMethod [concat $eId *]
    set methodTail $method

    if {[info exists Snit_methodInfo($fullMethod)]} {
        set key $fullMethod
    } elseif {[info exists Snit_methodInfo($starredMethod)] &&
              [lsearch -exact $Snit_info(exceptmethods) $methodTail] == -1} {
        set key $starredMethod
    } else {
        return [list ]
    }

    foreach {flag pattern compName} $Snit_methodInfo($key) {}

    if {$flag == 1} {
        lappend eId $method

        set newCmd ${selfns}::Snit_en[llength $eId]_[join $eId _]

        set unknownCmd [list ::snit::RT.UnknownMethod \
                            $type $selfns $win $eId]

        set createCmd [list namespace ensemble create \
                           -command $newCmd \
                           -unknown $unknownCmd \
                           -prefixes 0]

        namespace eval $selfns $createCmd
        
        set map [namespace ensemble configure $eCmd -map]

        dict append map $method $newCmd

        namespace ensemble configure $eCmd -map $map

        return [list ]
    }

    set subList [list \
                     %% % \
                     %t $type \
                     %M $fullMethod \
                     %m [lindex $fullMethod end] \
                     %j [join $fullMethod _] \
                     %n [list $selfns] \
                     %w [list $win] \
                     %s [list $self]]

    if {$compName ne ""} {
        if {[info exists Snit_components($compName)]} {
            set compCmd $Snit_components($compName)
        } elseif {[info exists Snit_typecomponents($compName)]} {
            set compCmd $Snit_typecomponents($compName)
        } else {
            error "$type $self delegates method \"$fullMethod\" to undefined component \"$compName\""
        }

        lappend subList %c [list $compCmd]
    }

    set command {}

    foreach subpattern $pattern {
        lappend command [string map $subList $subpattern]
    }


    set cmd [lindex $command 0]

    if {[string index $cmd 0] ne ":"} {
        set command [lreplace $command 0 0 "::$cmd"]
    }

    set map [namespace ensemble configure $eCmd -map]

    dict append map $method $command

    namespace ensemble configure $eCmd -map $map

    return [list ]
}

proc ::snit::RT.ClearInstanceCaches {selfns} {
    if {![info exists ${selfns}::Snit_instance]} {
        return
    }
    set self [set ${selfns}::Snit_instance]
    namespace ensemble configure $self -map {}

    unset -nocomplain -- ${selfns}::Snit_cgetCache
    unset -nocomplain -- ${selfns}::Snit_configureCache
    unset -nocomplain -- ${selfns}::Snit_validateCache
}




proc ::snit::RT.installhull {type {using "using"} {widgetType ""} args} {
    variable ${type}::Snit_info
    variable ${type}::Snit_optionInfo
    upvar 1 self self
    upvar 1 selfns selfns
    namespace upvar $selfns \
        hull    hull        \
        options options

    if {!$Snit_info(isWidget)} { 
        error "installhull is valid only for snit::widgetadaptors"
    }
            
    if {[info exists ${selfns}::Snit_instance]} {
        error "hull already installed for $type $self"
    }

    if {"using" == $using} {
        set cmd [linsert $args 0 $widgetType $self]
        set obj [uplevel 1 $cmd]
            
        if {[info exists Snit_optionInfo(delegated-hull)]} {
                
            set usedOpts {}
            set ndx [lsearch -glob $args "-*"]
            foreach {opt val} [lrange $args $ndx end] {
                lappend usedOpts $opt
            }
                
            foreach opt $Snit_optionInfo(delegated-hull) {
                set target [lindex $Snit_optionInfo(target-$opt) 1]
                
                if {"$target" == $opt} {
                    continue
                }
                    
                set result [lsearch -exact $usedOpts $target]
                    
                if {$result != -1} {
                    continue
                }

                set dbval [RT.OptionDbGet $type $self $opt]
                $obj configure $target $dbval
            }
        }
    } else {
        set obj $using
        
        if {$obj ne $self} {
            error \
                "hull name mismatch: \"$obj\" != \"$self\""
        }
    }

    foreach opt $Snit_optionInfo(local) {
        set dbval [RT.OptionDbGet $type $self $opt]
            
        if {"" != $dbval} {
            set options($opt) $dbval
        }
    }


    set i 0
    while 1 {
        incr i
        set newName "::hull${i}$self"
        if {![llength [info commands $newName]]} {
            break
        }
    }
        
    rename ::$self $newName
    RT.MakeInstanceCommand $type $selfns $self
        
    set hull $newName
        
    return
}


proc ::snit::RT.install {type compName "using" widgetType winPath args} {
    variable ${type}::Snit_optionInfo
    variable ${type}::Snit_info
    upvar 1 self   self
    upvar 1 selfns selfns

    namespace upvar ${selfns} \
        $compName comp        \
        hull      hull

    if {$Snit_info(isWidget)} {
        if {"" == $hull} {
            error "tried to install \"$compName\" before the hull exists"
        }
            

        if {[info exists Snit_optionInfo(delegated-$compName)]} {
            set ndx [lsearch -glob $args "-*"]
                
            foreach opt $Snit_optionInfo(delegated-$compName) {
                set dbval [RT.OptionDbGet $type $self $opt]
                    
                if {"" != $dbval} {
                    set target [lindex $Snit_optionInfo(target-$opt) 1]
                    set args [linsert $args $ndx $target $dbval]
                }
            }
        }
    }
             
    set cmd [concat [list $widgetType $winPath] $args]
    set comp [uplevel 1 $cmd]

    if {$Snit_info(isWidget) && $Snit_optionInfo(starcomp) eq $compName} {
        if {[catch {$comp configure} specs]} {
            return
        }

        set usedOpts {}
        set ndx [lsearch -glob $args "-*"]
        foreach {opt val} [lrange $args $ndx end] {
            lappend usedOpts $opt
        }

        set skiplist [concat \
                          $usedOpts \
                          $Snit_optionInfo(except) \
                          $Snit_optionInfo(local) \
                          $Snit_optionInfo(delegated)]
        
        foreach spec $specs {
            if {[llength $spec] != 5} {
                continue
            }

            set opt [lindex $spec 0]

            if {[lsearch -exact $skiplist $opt] != -1} {
                continue
            }

            set res [lindex $spec 1]
            set cls [lindex $spec 2]

            set dbvalue [option get $self $res $cls]

            if {"" != $dbvalue} {
                $comp configure $opt $dbvalue
            }
        }
    }

    return
}



proc ::snit::RT.variable {varname} {
    upvar 1 selfns selfns

    if {![string match "::*" $varname]} {
        uplevel 1 [list upvar 1 ${selfns}::$varname $varname]
    } else {
        uplevel 1 [list ::variable $varname]
    }
}


proc ::snit::RT.mytypevar {type name} {
    return ${type}::$name
}

proc ::snit::RT.myvar {name} {
    upvar 1 selfns selfns
    return ${selfns}::$name
}


proc ::snit::RT.myproc {type procname args} {
    set procname "${type}::$procname"
    return [linsert $args 0 $procname]
}

proc ::snit::RT.codename {type name} {
    return "${type}::$name"
}


proc ::snit::RT.mytypemethod {type args} {
    return [linsert $args 0 $type]
}


proc ::snit::RT.mymethod {args} {
    upvar 1 selfns selfns
    return [linsert $args 0 ::snit::RT.CallInstance ${selfns}]
}


proc ::snit::RT.CallInstance {selfns args} {
    namespace upvar $selfns Snit_instance self

    set retval [catch {uplevel 1 [linsert $args 0 $self]} result]

    if {$retval} {
        if {$retval == 1} {
            global errorInfo
            global errorCode
            return -code error -errorinfo $errorInfo \
                -errorcode $errorCode $result
        } else {
            return -code $retval $result
        }
    }

    return $result
}


proc ::snit::RT.from {type argvName option {defvalue ""}} {
    namespace upvar $type Snit_optionInfo Snit_optionInfo
    upvar $argvName argv

    set ioption [lsearch -exact $argv $option]

    if {$ioption == -1} {
        if {"" == $defvalue &&
            [info exists Snit_optionInfo(default-$option)]} {
            return $Snit_optionInfo(default-$option)
        } else {
            return $defvalue
        }
    }

    set ivalue [expr {$ioption + 1}]
    set value [lindex $argv $ivalue]
    
    set argv [lreplace $argv $ioption $ivalue] 

    return $value
}



proc ::snit::RT.typemethod.destroy {type} {
    variable ${type}::Snit_info
        
    foreach selfns [namespace children $type "${type}::Snit_inst*"] {
        if {![namespace exists $selfns]} {
            continue
        }

        namespace upvar $selfns Snit_instance obj
            
        if {$Snit_info(isWidget)} {
            destroy $obj
        } else {
            if {[llength [info commands $obj]]} {
                $obj destroy
            }
        }
    }

    rename $type ""

    namespace delete $type
}





proc ::snit::RT.method.cget {type selfns win self option} {
    if {[catch {set ${selfns}::Snit_cgetCache($option)} command]} {
        set command [snit::RT.CacheCgetCommand $type $selfns $win $self $option]
        
        if {[llength $command] == 0} {
            return -code error "unknown option \"$option\""
        }
    }
            
    uplevel 1 $command
}


proc ::snit::RT.CacheCgetCommand {type selfns win self option} {
    variable ${type}::Snit_optionInfo
    variable ${selfns}::Snit_cgetCache
                
    if {[info exists Snit_optionInfo(islocal-$option)]} {
        if {$Snit_optionInfo(islocal-$option)} {

            if {$Snit_optionInfo(cget-$option) eq ""} {
                set command [list set ${selfns}::options($option)]
            } else {
                set command [list \
                                 $self \
                                 {*}$Snit_optionInfo(cget-$option) \
                                 $option]
            }

            set Snit_cgetCache($option) $command
            return $command
        }
         
        set comp [lindex $Snit_optionInfo(target-$option) 0]
        set target [lindex $Snit_optionInfo(target-$option) 1]
    } elseif {$Snit_optionInfo(starcomp) ne "" &&
              [lsearch -exact $Snit_optionInfo(except) $option] == -1} {
        set comp $Snit_optionInfo(starcomp)
        set target $option
    } else {
        return ""
    }
    
    set obj [RT.Component $type $selfns $comp]

    set command [list $obj cget $target]
    set Snit_cgetCache($option) $command

    return $command
}


proc ::snit::RT.method.configurelist {type selfns win self optionlist} {
    variable ${type}::Snit_optionInfo

    foreach {option value} $optionlist {
        if {[catch {set ${selfns}::Snit_configureCache($option)} command]} {
            set command [snit::RT.CacheConfigureCommand \
                             $type $selfns $win $self $option]

            if {[llength $command] == 0} {
                return -code error "unknown option \"$option\""
            }
        }

        if {[info exists Snit_optionInfo(typeobj-$option)]
            && $Snit_optionInfo(typeobj-$option) ne ""} {
            if {[catch {
                $Snit_optionInfo(typeobj-$option) validate $value
            } result]} {
                return -code error "invalid $option value: $result"
            }
        }

        set valcommand [set ${selfns}::Snit_validateCache($option)]

        if {[llength $valcommand]} {
            lappend valcommand $value
            uplevel 1 $valcommand
        }

        lappend command $value
        uplevel 1 $command
    }
    
    return
}


proc ::snit::RT.CacheConfigureCommand {type selfns win self option} {
    variable ${type}::Snit_optionInfo
    variable ${selfns}::Snit_configureCache
    variable ${selfns}::Snit_validateCache

    if {[info exist Snit_optionInfo(islocal-$option)]} {
        
        if {$Snit_optionInfo(islocal-$option)} {

            if {$Snit_optionInfo(readonly-$option)} {
                if {[set ${selfns}::Snit_iinfo(constructed)]} {
                    error "option $option can only be set at instance creation"
                }
            }

            if {$Snit_optionInfo(validate-$option) ne ""} {
                set command [list \
                                 $self \
                                 {*}$Snit_optionInfo(validate-$option) \
                                 $option]

                set Snit_validateCache($option) $command
            } else {
                set Snit_validateCache($option) ""
            }
            
            if {$Snit_optionInfo(configure-$option) eq ""} {
                set command [list set ${selfns}::options($option)]
            } else {
                set command [list \
                                 $self \
                                 {*}$Snit_optionInfo(configure-$option) \
                                 $option]
            }

            set Snit_configureCache($option) $command
            return $command
        }

        set comp [lindex $Snit_optionInfo(target-$option) 0]
        set target [lindex $Snit_optionInfo(target-$option) 1]
    } elseif {$Snit_optionInfo(starcomp) != "" &&
              [lsearch -exact $Snit_optionInfo(except) $option] == -1} {
        set comp $Snit_optionInfo(starcomp)
        set target $option
    } else {
        return ""
    }

    set Snit_validateCache($option) ""
        
    set obj [RT.Component $type $selfns $comp]
    
    set command [list $obj configure $target]
    set Snit_configureCache($option) $command

    return $command
}


proc ::snit::RT.method.configure {type selfns win self args} {
    if {[llength $args] >= 2} {
        ::snit::RT.method.configurelist $type $selfns $win $self $args
        return
    }

    if {[llength $args] == 0} {
        set result {}
        foreach opt [RT.method.info.options $type $selfns $win $self] {
            lappend result [RT.GetOptionDbSpec \
                                $type $selfns $win $self $opt]
        }
        
        return $result
    }

    set opt [lindex $args 0]

    return [RT.GetOptionDbSpec $type $selfns $win $self $opt]
}



proc ::snit::RT.GetOptionDbSpec {type selfns win self opt} {
    variable ${type}::Snit_optionInfo

    namespace upvar $selfns \
        Snit_components Snit_components \
        options         options
    
    if {[info exists options($opt)]} {
        set res $Snit_optionInfo(resource-$opt)
        set cls $Snit_optionInfo(class-$opt)
        set def $Snit_optionInfo(default-$opt)

        return [list $opt $res $cls $def \
                    [RT.method.cget $type $selfns $win $self $opt]]
    } elseif {[info exists Snit_optionInfo(target-$opt)]} {
        set res $Snit_optionInfo(resource-$opt)
        set cls $Snit_optionInfo(class-$opt)
        
        set logicalName [lindex $Snit_optionInfo(target-$opt) 0]
        set comp $Snit_components($logicalName)
        set target [lindex $Snit_optionInfo(target-$opt) 1]

        if {[catch {$comp configure $target} result]} {
            set defValue {}
        } else {
            set defValue [lindex $result 3]
        }

        return [list $opt $res $cls $defValue [$self cget $opt]]
    } elseif {$Snit_optionInfo(starcomp) ne "" &&
              [lsearch -exact $Snit_optionInfo(except) $opt] == -1} {
        set logicalName $Snit_optionInfo(starcomp)
        set target $opt
        set comp $Snit_components($logicalName)

        if {[catch {set value [$comp cget $target]} result]} {
            error "unknown option \"$opt\""
        }

        if {![catch {$comp configure $target} result]} {
            return [::snit::Expand $result $target $opt]
        }

        return [list $opt "" "" "" $value]
    } else {
        error "unknown option \"$opt\""
    }
}



proc ::snit::RT.typemethod.info {type command args} {
    global errorInfo
    global errorCode

    switch -exact $command {
	args        -
	body        -
	default     -
        typevars    -
        typemethods -
        instances {
            set errflag [catch {
                uplevel 1 [linsert $args 0 \
			       ::snit::RT.typemethod.info.$command $type]
            } result]

            if {$errflag} {
                return -code error -errorinfo $errorInfo \
                    -errorcode $errorCode $result
            } else {
                return $result
            }
        }
        default {
            error "\"$type info $command\" is not defined"
        }
    }
}



proc ::snit::RT.typemethod.info.typevars {type {pattern *}} {
    set result {}
    foreach name [info vars "${type}::$pattern"] {
        set tail [namespace tail $name]
        if {![string match "Snit_*" $tail]} {
            lappend result $name
        }
    }
    
    return $result
}


proc ::snit::RT.typemethod.info.typemethods {type {pattern *}} {
    variable ${type}::Snit_typemethodInfo

    set result {}

    foreach name [array names Snit_typemethodInfo -glob $pattern] {
        if {[lindex $Snit_typemethodInfo($name) 0] != 1} {
            lappend result $name
        }
    }

    if {[info exists Snit_typemethodInfo(*)]} {
        set ndx [lsearch -exact $result "*"]
        if {$ndx != -1} {
            set result [lreplace $result $ndx $ndx]
        }

        array set typemethodCache [namespace ensemble configure $type -map]

        foreach name [array names typemethodCache -glob $pattern] {
            if {[lsearch -exact $result $name] == -1} {
                lappend result $name
            }
        }
    }

    return $result
}


proc ::snit::RT.typemethod.info.args {type method} {
    upvar ${type}::Snit_typemethodInfo  Snit_typemethodInfo




    if {![info exists Snit_typemethodInfo($method)]} {
	return -code error "Unknown typemethod \"$method\""
    }
    foreach {flag cmd component} $Snit_typemethodInfo($method) break
    if {$flag} {
	return -code error "Unknown typemethod \"$method\""
    }
    if {$component != ""} {
	return -code error "Delegated typemethod \"$method\""
    }

    set map     [list %m $method %j [join $method _] %t $type]
    set theproc [lindex [string map $map $cmd] 0]
    return [lrange [::info args $theproc] 1 end]
}


proc ::snit::RT.typemethod.info.body {type method} {
    upvar ${type}::Snit_typemethodInfo  Snit_typemethodInfo




    if {![info exists Snit_typemethodInfo($method)]} {
	return -code error "Unknown typemethod \"$method\""
    }
    foreach {flag cmd component} $Snit_typemethodInfo($method) break
    if {$flag} {
	return -code error "Unknown typemethod \"$method\""
    }
    if {$component != ""} {
	return -code error "Delegated typemethod \"$method\""
    }

    set map     [list %m $method %j [join $method _] %t $type]
    set theproc [lindex [string map $map $cmd] 0]
    return [RT.body [::info body $theproc]]
}


proc ::snit::RT.typemethod.info.default {type method aname dvar} {
    upvar 1 $dvar def
    upvar ${type}::Snit_typemethodInfo  Snit_typemethodInfo




    if {![info exists Snit_typemethodInfo($method)]} {
	return -code error "Unknown typemethod \"$method\""
    }
    foreach {flag cmd component} $Snit_typemethodInfo($method) break
    if {$flag} {
	return -code error "Unknown typemethod \"$method\""
    }
    if {$component != ""} {
	return -code error "Delegated typemethod \"$method\""
    }

    set map     [list %m $method %j [join $method _] %t $type]
    set theproc [lindex [string map $map $cmd] 0]
    return [::info default $theproc $aname def]
}


proc ::snit::RT.typemethod.info.instances {type {pattern *}} {
    set result {}

    foreach selfns [namespace children $type "${type}::Snit_inst*"] {
        namespace upvar $selfns Snit_instance instance

        if {[string match $pattern $instance]} {
            lappend result $instance
        }
    }

    return $result
}



proc ::snit::RT.method.info {type selfns win self command args} {
    switch -exact $command {
	args        -
	body        -
	default     -
        type        -
        vars        -
        options     -
        methods     -
        typevars    -
        typemethods {
            set errflag [catch {
                uplevel 1 [linsert $args 0 ::snit::RT.method.info.$command \
			       $type $selfns $win $self]
            } result]

            if {$errflag} {
                global errorInfo
                return -code error -errorinfo $errorInfo $result
            } else {
                return $result
            }
        }
        default {
            return -code error "\"$self info $command\" is not defined"
        }
    }
}

proc ::snit::RT.method.info.type {type selfns win self} {
    return $type
}

proc ::snit::RT.method.info.typevars {type selfns win self {pattern *}} {
    return [RT.typemethod.info.typevars $type $pattern]
}

proc ::snit::RT.method.info.typemethods {type selfns win self {pattern *}} {
    return [RT.typemethod.info.typemethods $type $pattern]
}


proc ::snit::RT.method.info.methods {type selfns win self {pattern *}} {
    variable ${type}::Snit_methodInfo

    set result {}

    foreach name [array names Snit_methodInfo -glob $pattern] {
        if {[lindex $Snit_methodInfo($name) 0] != 1} {
            lappend result $name
        }
    }

    if {[info exists Snit_methodInfo(*)]} {
        set ndx [lsearch -exact $result "*"]
        if {$ndx != -1} {
            set result [lreplace $result $ndx $ndx]
        }

        set self [set ${selfns}::Snit_instance]

        array set methodCache [namespace ensemble configure $self -map]

        foreach name [array names methodCache -glob $pattern] {
            if {[lsearch -exact $result $name] == -1} {
                lappend result $name
            }
        }
    }

    return $result
}


proc ::snit::RT.method.info.args {type selfns win self method} {

    upvar ${type}::Snit_methodInfo  Snit_methodInfo




    if {![info exists Snit_methodInfo($method)]} {
	return -code error "Unknown method \"$method\""
    }
    foreach {flag cmd component} $Snit_methodInfo($method) break
    if {$flag} {
	return -code error "Unknown method \"$method\""
    }
    if {$component != ""} {
	return -code error "Delegated method \"$method\""
    }

    set map     [list %m $method %j [join $method _] %t $type %n $selfns %w $win %s $self]
    set theproc [lindex [string map $map $cmd] 0]
    return [lrange [::info args $theproc] 4 end]
}


proc ::snit::RT.method.info.body {type selfns win self method} {

    upvar ${type}::Snit_methodInfo  Snit_methodInfo




    if {![info exists Snit_methodInfo($method)]} {
	return -code error "Unknown method \"$method\""
    }
    foreach {flag cmd component} $Snit_methodInfo($method) break
    if {$flag} {
	return -code error "Unknown method \"$method\""
    }
    if {$component != ""} {
	return -code error "Delegated method \"$method\""
    }

    set map     [list %m $method %j [join $method _] %t $type %n $selfns %w $win %s $self]
    set theproc [lindex [string map $map $cmd] 0]
    return [RT.body [::info body $theproc]]
}


proc ::snit::RT.method.info.default {type selfns win self method aname dvar} {
    upvar 1 $dvar def
    upvar ${type}::Snit_methodInfo  Snit_methodInfo



    if {![info exists Snit_methodInfo($method)]} {
	return -code error "Unknown method \"$method\""
    }
    foreach {flag cmd component} $Snit_methodInfo($method) break
    if {$flag} {
	return -code error "Unknown method \"$method\""
    }
    if {$component != ""} {
	return -code error "Delegated method \"$method\""
    }

    set map     [list %m $method %j [join $method _] %t $type %n $selfns %w $win %s $self]
    set theproc [lindex [string map $map $cmd] 0]
    return [::info default $theproc $aname def]
}

proc ::snit::RT.method.info.vars {type selfns win self {pattern *}} {
    set result {}
    foreach name [info vars "${selfns}::$pattern"] {
        set tail [namespace tail $name]
        if {![string match "Snit_*" $tail]} {
            lappend result $name
        }
    }

    return $result
}

proc ::snit::RT.method.info.options {type selfns win self {pattern *}} {
    variable ${type}::Snit_optionInfo

    set result [concat $Snit_optionInfo(local) $Snit_optionInfo(delegated)]

    if {$Snit_optionInfo(starcomp) ne ""} {
        namespace upvar $selfns Snit_components Snit_components

        set logicalName $Snit_optionInfo(starcomp)
        set comp $Snit_components($logicalName)

        if {![catch {$comp configure} records]} {
            foreach record $records {
                set opt [lindex $record 0]
                if {[lsearch -exact $result $opt] == -1 &&
                    [lsearch -exact $Snit_optionInfo(except) $opt] == -1} {
                    lappend result $opt
                }
            }
        }
    }

    set names {}

    foreach name $result {
        if {[string match $pattern $name]} {
            lappend names $name
        }
    }

    return $names
}

proc ::snit::RT.body {body} {
    regsub -all ".*# END snit method prolog\n" $body {} body
    return $body
}
