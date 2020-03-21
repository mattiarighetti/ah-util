ad_library {

    Procs to add, edit, and remove mis_script

    @author claudio.pasolini@comune.mantova.it
    @cvs-id $Id:

}

namespace eval mis {}
namespace eval mis::script {}

ad_proc -public mis::script::get {
    -item_id:required
    -array:required
} { 
    This proc retrieves a script
} {
    upvar 1 $array row
    db_1row script_select {
	select ci.item_id,
	       sc.*
	from   cr_items ci,
               mis_scriptsx sc
       where   ci.item_id = :item_id
       and     sc.revision_id = ci.live_revision
    } -column_array row
}

ad_proc -public mis::script::add {
    -title:required
    -description
    -parent_id
    -user_id
    -creation_ip
    -original_author
    -maintainer
    -is_active_p
    -is_executable_p
} { 
    This proc adds a script
} {

    if {![info exists description]} {
	set description [db_null]
    }
    if {![info exists original_author]} {
	set original_author [db_null]
    }
    if {![info exists maintainer]} {
	set maintainer [db_null]
    }
    if {![info exists is_active_p]} {
	set is_active_p t
    }
    if {![info exists is_executable_p]} {
	set is_executable_p t
    }
    if {![info exists user_id]} {
	set user_id [ad_conn user_id]
    }
    if {![info exists creation_ip]} {
	set creation_ip [ad_conn peeraddr]
    }

    db_transaction {
	set item_id [db_exec_plsql script_insert {
	    select content_item__new(
                :title,               -- name
                :parent_id,           -- parent_id
                null,                 -- item_id
                null,                 -- locale
                now(),                -- creation_date
                :user_id,             -- creation_user
                null,                 -- context_id
                :creation_ip,         -- creation_ip
                'content_item',       -- item_subtype
                'mis_script',         -- content_type
                :title,               -- title
                :description,         -- description
                'text/plain',         -- mime_type 
                null,                 -- nls_language
                null                  -- data
                )
	}]

	set revision_id [db_nextval acs_object_id_seq]

	
	db_dml revision_add {
 	    insert into mis_scriptsi (
	        item_id, 
                revision_id, 
                creation_user,
                creation_date,
                creation_ip,
                title,
                description,
                original_author,
                maintainer,
                is_active_p,
                is_executable_p)
	    values (
                :item_id, 
                :revision_id, 
                :user_id,
                now(),
                :creation_ip,
                :title,
                :description,
                :original_author,
                :maintainer,
                :is_active_p,
                :is_executable_p)
	}

	db_exec_plsql make_live {
	    select content_item__set_live_revision(:revision_id)
	}
    }
    return $item_id
}

ad_proc -public mis::script::edit {
    -item_id:required
    -title
    -description
    -user_id
    -creation_ip
    -maintainer
    -is_active_p
    -is_executable_p
} { 
    This proc edits a script. Note that to edit a cr_item, you insert a new revision instead of changing the current revision.
} {
   
    if {![info exists user_id]} {
	set user_id [ad_conn user_id]
    }
    if {![info exists creation_ip]} {
	set creation_ip [ad_conn peeraddr]
    }

    mis::script::get -item_id $item_id -array script

    if {![info exists mantainer]} {
	set maintainer $script(maintainer)
    }
    if {![info exists is_active_p]} {
	set is_active_p $script(is_active_p)
    }
    if {![info exists is_executable_p]} {
	set is_executable_p $script(is_executable_p)
    }
    if {![info exists title]} {
	set title $script(title)
    }
    if {![info exists description]} {
	set description $script(description)
    }

    set original_author $script(original_author)

    db_transaction {
	set revision_id [db_nextval acs_object_id_seq]

	db_dml revision_add {
 	    insert into mis_scriptsi (
	        item_id, 
                revision_id, 
                creation_user,
                creation_date,
                creation_ip,
                title,
                description,
                original_author,
                maintainer,
                is_active_p,
                is_executable_p)
	    values (
                :item_id, 
                :revision_id, 
                :user_id,
                now(),
                :creation_ip,
                :title,
                :description,
                :original_author,
                :maintainer,
                :is_active_p,
                :is_executable_p)
	}
	
	db_exec_plsql make_live {
	    select content_item__set_live_revision(:revision_id)
	}
    }
}

ad_proc -public mis::script::delete {
    -item_id:required
} { 
    This proc deletes a script.
} {
    db_exec_plsql process_delete {
	select content_item__delete(:item_id)
    }
}

ad_proc -public mis::script::new {
    path
} { 
    Wrapper procedure to create a script
} {

    set user_id [ad_conn user_id]

    # get script name (last part of the path)
    regexp {(/[^/]*$)} $path match name
    # strip name getting parent part
    regsub $name $path {} parent
    # get parent_id
    db_0or1row query "select ci.item_id as parent_id 
                      from mis_scriptsx x, cr_items ci
                      where title=:parent and
                      x.revision_id = ci.live_revision"

        mis::script::add                    \
	  -title $path               \
          -description ""                \
          -parent_id $parent_id             \
          -original_author $user_id         \
          -maintainer $user_id              \
          -is_active_p t                    \
          -is_executable_p t
}
