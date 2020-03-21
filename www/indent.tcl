ad_page_contract {  
    Menu principale del PEG

    @author Claudio Pasolini
    @creation-date  12/04/2003

    @cvs-id index.tcl 
} {
    {root_id "486"} 
} -properties {
    scripts:multirow
}

set page_title "Lista scripts"
set context [list "Lista scripts"]

# ottengo tree_sortkey della radice
set root_sortkey [db_string root "select tree_sortkey from acs_objects where object_id = $root_id"]

db_multirow scripts query "
    select ci.item_id, 
           repeat('&nbsp;', tree_level(sc.tree_sortkey) * 4) as indent,
           sc.title as name
    from   mis_scriptsx sc, cr_items ci
    where  sc.tree_sortkey between :root_sortkey and tree_right(:root_sortkey) and 
           sc.revision_id = ci.live_revision
   order by sc.tree_sortkey
"

ad_return_template
