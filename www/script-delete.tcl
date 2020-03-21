ad_page_contract {
    Deletes a script content item

    @author Claudio Pasolini
    @cvs-id script-delete.tcl
 
    @param item_id The id to delete
} {
    item_id:integer
}



with_catch errmsg {
    mis::script::delete -item_id $item_id
} {
    ad_return_complaint 1 "
    Non &egrave; possibile cancellare la riga, 
    probabilmente in quanto referenziata da altre tabelle.
    <p>L'errore restituito da PostgreSQL &egrave;:
    <code>$errmsg </code>"
    ad_script_abort
}

# retrieve eventual url vars setting
set url_vars [ad_get_client_property -default "" mis script-list]
ad_returnredirect "script-list?$url_vars"


ad_script_abort
