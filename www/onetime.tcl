# set user_id from db
set user_id [db_string query "select min(user_id) from users where user_id <> 0;"]

set parent_id [db_string query "select ci.item_id
                            from mis_scriptsx x, cr_items ci
                            where title='mis' and
                            x.revision_id = ci.live_revision"]

db_transaction {

    set item_id [mis::script::add                    \
	-title mis/acct                    \
	-description "Accounting"  \
	-parent_id $parent_id             \
	-original_author $user_id         \
	-maintainer $user_id              \
	-is_active_p t                    \
        -is_executable_p f]

    lappend dirlist mis/acct
    lappend itemlist $item_id 

    #
    # creates all the scripts under the directories
    #
    set mis_root [ah::package_root -package_key mis]

    foreach dir $dirlist item $itemlist {

        regsub mis/ $dir {} sub
        cd $mis_root/$sub
	foreach file [glob -nocomplain *tcl] { 

	    regsub {\.tcl} $file {} file

	    mis::script::add                    \
		-title ${dir}/$file               \
		-description ""                \
		-parent_id $item             \
		-original_author $user_id         \
		-maintainer $user_id              \
		-is_active_p t                    \
		-is_executable_p t

	}

    }

}

ns_return 200 text/html "scripts creati"




