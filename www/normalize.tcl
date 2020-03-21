set dir /var/lib/aolserver/oacs51/packages/mis/www/projects

set pwd [pwd]
cd $dir

foreach file [glob -nocomplain *tcl] { 

    set file_name $dir/$file
    set fd [open $file_name r]
    set data [read $fd]
    close $fd
    regsub {\.tcl} $file_name {} script_name
    regsub {/web/tornieri/packages/mis/www} $script_name {mis} script_name

    regsub -- {-script_id [0-9]*} $data "-script_name $script_name" data
    puts "... updating $file_name ..."
    set fd [open $file_name w]
    puts $fd $data
    close $fd

}

cd $pwd



