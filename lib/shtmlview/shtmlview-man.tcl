package require shtmlview::shtmlview
package provide shtmlview::man2html 0.1
catch {
    package require dtplite
}
if {[info commands ::dtplite::do] eq ""} {
    return
}

lappend ::shtmlview::filetypes {{Tcl man files} {.man}}

proc ::shtmlview::man2html {url {clean true}} {
    #package require dtplite
    set tempfile [file tempfile].html
    # why not dtplite -o .... (command does not exists)
    ::dtplite::do [list -o $tempfile html $url]
    if {[catch {open $tempfile r} infh]} {
        error "Cannot open $url: $infh"
    } else {
        # perform some cleanups for better display
        if {$clean} {
            set html [shtmlview::cleanHTML [read $infh]]
        } else {
            # for source view real HTML should be shown
            set html [read $infh]
        }
        close $infh
        file delete $tempfile
        return $html
    }
}
