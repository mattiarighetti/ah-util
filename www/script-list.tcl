ad_page_contract {

    @author Claudio Pasolini
    @cvs-id $Id: script-list.tcl
} {
    {rows_per_page 9999}
    {offset 0}
    {search_word ""}
    orderby:optional
    package_key:optional
    is_active_p:optional
    is_executable_p:optional
}

set page_title "Lista scripts"
set context [list "Lista scripts"]

# prepare actions buttons
set actions { "Nuovo script" script-add-edit "Aggiunge un nuovo script" }
source [ah::package_root -package_key ah-util]/paging-buttons.tcl

template::list::create \
    -name scripts \
    -multirow scripts \
    -actions $actions \
    -elements {
	edit {
	    link_url_col edit_url
	    display_template {<img src="/resources/acs-subsite/Edit16.gif" width="16" height="16" border="0">}
	    link_html {title "Modifica script"}
	    sub_class narrow
	}
	item_id {
	    label "Id"
	    link_url_col view_url
	    link_html {title "Visualizza script"}
	}
	title {
	    label "Nome"
	}
	description {
	    label "Descrizione"
	}
	parent_script {
	    label "Parent script"
	}
	is_active_p {
	    label "Attivo?"
	}
	is_executable_p {
	    label "Exec?"
	}
	delete {
	    link_url_col delete_url 
            link_html {title "Cancella questo script" onClick "return(confirm('Confermi la cancellazione?'));"}
	    display_template {<img src="/resources/acs-subsite/Delete16.gif" width="16" height="16" border="0">}
	    sub_class narrow
	}
	permission {
	    link_url_col permission_url 
            link_html {title "Gestisci i permessi di questo script"}
	    display_template {Permessi}
	    sub_class narrow
	}
    } \
    -orderby {
        default_value title,asc
        title {
	    label "Nome"
	    orderby title
	}
        item_id {
	    label "Id"
	    orderby item_id
	}

    } \
    -filters {
        package_key {
	    label "Package"
  	    values {[db_list_of_lists query {
               select title, ci.item_id
               from   mis_scriptsx sc, cr_items ci
               where  sc.revision_id = ci.live_revision and
                      ci.parent_id   = -100}]}
	    where_clause {sc.tree_sortkey between 
                acs_objects_get_tree_sortkey(:package_key) and 
                tree_right(acs_objects_get_tree_sortkey(:package_key))}
        }
        is_active_p {
	    label "Attivo?"
  	    values {{Attivo t} {Inattivo f}}
	    where_clause {is_active_p = :is_active_p}
        }
        is_executable_p {
	    label "Eseguibile?"
  	    values {{Eseguibile t} {"Non eseguibile" f}}
	    where_clause {is_executable_p = :is_executable_p}
        }
        rows_per_page {
	    label "Righe per pagina"
  	    values {{10 10} {30 30} {100 100} {Tutte 9999}}
	    where_clause {1 = 1}
            default_value 30
        }
    } 

# save current url vars for future reuse
set url_vars [export_ns_set_vars]

db_multirow \
    -extend {
	edit_url
        view_url
	delete_url
        permission_url
    } scripts scripts_select "
	select ci.item_id, description, ci2.name as parent_script, title, is_active_p, is_executable_p, original_author, maintainer
        from   mis_scriptsx sc, cr_items ci, cr_items ci2
        where  sc.revision_id = ci.live_revision and
               sc.parent_id   = ci2.item_id
        [template::list::filter_where_clauses -name scripts -and]
        [ah::search_clause -search_word $search_word -search_field title]
        [template::list::orderby_clause -name scripts -orderby]
        limit $rows_per_page
        offset $offset
    " {
	set edit_url [export_vars -base "script-add-edit" {item_id}]
	set view_url [export_vars -base "script-add-edit?mode=display" {item_id}]
	set delete_url [export_vars -base "script-delete" {item_id}]
	set object_id $item_id
	set permission_url [export_vars -base "/permissions/one" {object_id}]
    }

# save current url vars for future reuse
ad_set_client_property mis script-list [export_ns_set_vars]



