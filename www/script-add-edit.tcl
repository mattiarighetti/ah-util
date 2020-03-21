ad_page_contract {

  @author Claudio Pasolini
  @creation-date 2004-08-24
  @cvs-id script-add-edit.tcl

} {
    item_id:integer,optional
    {mode "edit"}
}

if {[ad_form_new_p -key item_id]} {
    set page_title "Crea nuovo script"
    set buttons [list [list "Crea script" new]]
    set field_mode edit
} else {
    if {[string equal $mode "edit"]} {
        set page_title "Modifica script"
        set buttons [list [list "Modifica script" edit]]
        set field_mode display
    } else {
        set page_title "Visualizza script"
        set buttons [list [list "OK" view]]
        set field_mode display
    }
}

set context [list [list script-list {Lista Script}] $page_title]

# NOTE form name must not contains '-' or JavaScript gets confused  
ad_form -name scriptaddedit \
        -mode $mode \
        -edit_buttons $buttons \
        -has_edit 1 \
        -form {

    item_id:key  

    {title:text 
        {label {Nome script}}
        {html {size 30}}
	{mode $field_mode}
    }

    {description:text(textarea),optional 
        {label Descrizione}
        {html {rows 5 cols 50 wrap soft}}
    }

    {parent_id:integer(hidden),optional
    }
    {parent_code:text,optional
        {label {Codice del parent script}}
        {mode $field_mode}
    }
    {parent_name:text,optional
        {label {Descrizione del parent script}}
        {mode $field_mode}
        {after_html "[ah::search_tab -query_spec scripts -form_name scriptaddedit -form_key_field parent_id -form_code_field parent_code -form_name_field parent_name]"}
    }

    {original_author:text(select),optional
        {options { [db_list_of_lists get_aut {
            select email, party_id from parties where email is not null
            }] }}
        {label {Autore originale}}
    }

    {maintainer:text(select),optional
        {options { [db_list_of_lists get_maint {
            select email, party_id from parties where email is not null
            }] }}
        {label {Gestore attuale}}
    }

    {is_active_p:boolean(radio)
        {options {{SI t} {NO f}}}
        {label {Script attivo?}}
	{help_text {Se lo script non &egrave; attivo non sar&agrave; utilizzato nella generazione dei menu dinamici.}}
    }

    {is_executable_p:boolean(radio)
        {options {{SI t} {NO f}}}
        {label {Script eseguibile?}}
    }

} -select_query {

    select ci.item_id, sc.description, sc.parent_id, par.title as parent_code, sc.title, sc.original_author,sc. maintainer, sc.is_active_p, sc.is_executable_p
    from   mis_scriptsx sc, cr_items ci, mis_scriptsx par, cr_items cipar
    where  ci.item_id     = :item_id and
           sc.revision_id = ci.live_revision and
           cipar.item_id  = sc.parent_id and
           par.revision_id = cipar.live_revision

} -validate {

    {parent_code
	{[db_0or1row query "select ci.item_id as parent_id 
                            from mis_scriptsx x, cr_items ci
                            where title=:parent_code and
                            x.revision_id = ci.live_revision"]}
	"Codice script errato."
    }

} -new_data {

    with_catch errmsg {

        mis::script::add                    \
          -title $title                     \
          -description $description         \
          -parent_id $parent_id             \
          -original_author $original_author \
          -maintainer $maintainer           \
          -is_active_p $is_active_p         \
          -is_executable_p $is_executable_p

    } {
        template::form::set_error scriptaddedit title "
        Non &egrave; possibile inserire la riga, 
        probabilmente in quanto il nome dello script non &egrave; univoco.
        <p>L'errore restituito da PostgreSQL &egrave;:
        <code>$errmsg </code>"
        break
    }

} -edit_data {

        mis::script::edit                   \
          -item_id $item_id                 \
          -title $title                     \
          -description $description         \
          -maintainer $maintainer           \
          -is_active_p $is_active_p         \
          -is_executable_p $is_executable_p

} -after_submit {

    # retrieve eventual url vars setting
    set url_vars [ad_get_client_property -default "" mis script-list]
    ad_returnredirect "script-list?$url_vars"
    ad_script_abort
}



