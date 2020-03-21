ad_library {

    Call back procs 

    @author claudio.pasolini@comune.mantova.it

}

namespace eval ah::apm {}

ad_proc -public ah::apm::after_mount  {
    -package_id
    -node_id
} { 
    Creates all the scripts of the 'mis' package
} {

#
# initialize mis_scripts
#

# set user_id from db
set user_id [db_string query "select min(user_id) from users where user_id <> 0;"]


db_transaction {

    # defines the scripts root 
    set parent_id [mis::script::add                    \
		       -title mis               \
		       -description "Management Information System"  \
		       -parent_id -100             \
		       -original_author $user_id         \
		       -maintainer $user_id              \
		       -is_active_p t                    \
		       -is_executable_p f]

    mis::script::add                    \
	-title ah-util               \
	-description "Utilities ed API generali"                \
	-parent_id -100             \
	-original_author $user_id         \
	-maintainer $user_id              \
	-is_active_p t                    \
	-is_executable_p f

    # defines the directories under the root
    mis::script::add                    \
	-title mis/bom                    \
	-description "Bill Of Materials"  \
	-parent_id $parent_id             \
	-original_author $user_id         \
	-maintainer $user_id              \
	-is_active_p t                    \
	-is_executable_p f

    mis::script::add                    \
	-title mis/deliveries                    \
	-description "Bolle di consegna"  \
	-parent_id $parent_id             \
	-original_author $user_id         \
	-maintainer $user_id              \
	-is_active_p t                    \
	-is_executable_p f

    mis::script::add                    \
	-title mis/invoices                    \
	-description "Fatture di vendita"  \
	-parent_id $parent_id             \
	-original_author $user_id         \
	-maintainer $user_id              \
	-is_active_p t                    \
	-is_executable_p f

    mis::script::add                    \
	-title mis/invpurc                    \
	-description "Fatture di acquisto"  \
	-parent_id $parent_id             \
	-original_author $user_id         \
	-maintainer $user_id              \
	-is_active_p t                    \
	-is_executable_p f

    mis::script::add                    \
	-title mis/orders                    \
	-description "Ordini cliente"  \
	-parent_id $parent_id             \
	-original_author $user_id         \
	-maintainer $user_id              \
	-is_active_p t                    \
	-is_executable_p f

    mis::script::add                    \
	-title mis/parties                    \
	-description "Soggetti"  \
	-parent_id $parent_id             \
	-original_author $user_id         \
	-maintainer $user_id              \
	-is_active_p t                    \
	-is_executable_p f

    mis::script::add                    \
	-title mis/prod                    \
	-description "Prodotti"  \
	-parent_id $parent_id             \
	-original_author $user_id         \
	-maintainer $user_id              \
	-is_active_p t                    \
	-is_executable_p f

    mis::script::add                    \
	-title mis/po                    \
	-description "Acquisti"  \
	-parent_id $parent_id             \
	-original_author $user_id         \
	-maintainer $user_id              \
	-is_active_p t                    \
	-is_executable_p f

    mis::script::add                    \
	-title mis/projects                    \
	-description "Commesse"  \
	-parent_id $parent_id             \
	-original_author $user_id         \
	-maintainer $user_id              \
	-is_active_p t                    \
	-is_executable_p f

    mis::script::add                    \
	-title mis/receipts                    \
	-description "Ricevimenti"  \
	-parent_id $parent_id             \
	-original_author $user_id         \
	-maintainer $user_id              \
	-is_active_p t                    \
	-is_executable_p f

    mis::script::add                    \
	-title mis/tab                    \
	-description "Tabelle"  \
	-parent_id $parent_id             \
	-original_author $user_id         \
	-maintainer $user_id              \
	-is_active_p t                    \
	-is_executable_p f

    mis::script::add                    \
	-title mis/wh                    \
	-description "Magazzini"  \
	-parent_id $parent_id             \
	-original_author $user_id         \
	-maintainer $user_id              \
	-is_active_p t                    \
	-is_executable_p f

    #
    # creates all the scripts under the directories
    #
    set mis_root [ah::package_root -package_key mis]

    set parent_id [db_string query "select ci.item_id
                            from mis_scriptsx x, cr_items ci
                            where title='mis' and
                            x.revision_id = ci.live_revision"]

    set dirlist [db_list query "select title
                            from mis_scriptsx x, cr_items ci
                            where ci.parent_id = :parent_id and
                            x.revision_id   = ci.live_revision"]

    set itemlist [db_list query "select ci.item_id
                            from mis_scriptsx x, cr_items ci
                            where ci.parent_id = :parent_id and
                            x.revision_id   = ci.live_revision"]

    set pwd [pwd]


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

    # add scripts in www
    mis::script::add                    \
	-title mis/index                    \
	-description ""  \
	-parent_id $parent_id             \
	-original_author $user_id         \
	-maintainer $user_id              \
	-is_active_p t                    \
	-is_executable_p f


} on_error {
    cd $pwd
    ns_log error $errmsg
}

cd $pwd
if {![exists_and_not_null errmsg]} {
    ns_log notice "\nAPM_CALLBACK: Script creati"
}



}
