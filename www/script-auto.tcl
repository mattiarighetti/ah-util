ad_page_contract {

    Creates automatically the scripts for a given directory, wich must already exist.

    @author Claudio Pasolini
    @cvs-id $Id: script-auto.tcl
} {
    dirpath
    dir
}

set pwd [pwd]

cd $dirpath
set user_id [ad_conn user_id]

db_0or1row query "select ci.item_id as parent_id 
                            from mis_scriptsx x, cr_items ci
                            where title=:dir and
                            x.revision_id = ci.live_revision"

db_transaction {
    foreach file [glob -nocomplain *tcl] { 

        regsub {\.tcl} $file {} file

        mis::script::add                    \
	  -title ${dir}/$file               \
          -description ""                \
          -parent_id $parent_id             \
          -original_author $user_id         \
          -maintainer $user_id              \
          -is_active_p t                    \
          -is_executable_p t

    }
} on_error {
    cd $pwd
    ns_return 200 text/html $errmsg
}

cd $pwd
if {![exists_and_not_null errmsg]} {
    ns_return 200 text/html "Script creati"
}
