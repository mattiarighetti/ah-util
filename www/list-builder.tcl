ad_page_contract {
    Creates dynamically a list, provided a 'query_spec' and a search field.
    Returns the results (key, code and descriptions) of the selected element to 
    the calling 'form_name'.

    @author Claudio Pasolini
    @date   Agosto 2004
    @cvs-id list-builder.tcl

    @param query_spec        Name of an xml file containing the query specs
    @param form_name         Name of calling form
    @param form_key_field    Target key field for the element selected 
    @param form_code_field   Target code field for the element selected 
    @param form_name_field   Target name field for the element selected 
    @param search_word       Search string
    @param package_id        Optional package_id (company code)
    @param price_list_id     Optional price list to narrow product search

} {
    query_spec
    form_name
    form_key_field
    form_code_field
    form_name_field
    search_word
    {package_id ""}
    {price_list_id ""}
}

# define JS function for adp page
set javascript "
<script language=JavaScript>
  function sel(key,code,name) {
    window.opener.document.$form_name.$form_key_field.value = key;
    window.opener.document.$form_name.$form_code_field.value = code;
    window.opener.document.$form_name.$form_name_field.value = name;
    window.close();
  }
</script>
"

# se package_id significativo valorizzo anche holding_id
if {[exists_and_not_null package_id]} {
    set holding_id [parameter::get -package_id $package_id -parameter holding_id]
}

# leggo file di configurazione
set fd [open [ah::service_root]/www/resources/$query_spec.xml r]

# creo struttura dom leggendo il file di configurazione
set doc [dom parse [read $fd]]
close $fd

# e acquisisco l'elemento radice
set root [$doc documentElement]

# recupero titolo della lista
set page_title [$root getAttribute title]
set context [list $page_title]

# recupero nome delle colonne corrispondenti a form_key_field, form_code_field e form_name_field
set key_col  [$root getAttribute key_col]
set code_col [$root getAttribute code_col]
set name_col [$root getAttribute name_col]

# recupero query
set query_node [$root firstChild]
set query_text [$query_node firstChild]
set query_sql  [$query_text nodeValue]


if {![string equal $price_list_id ""]} {
    # se list_price_id significativo creo where clause appropriata
    set where_clause " , mis_product_prices pp 
        where u.um_id = p.um_id and
            p.package_id in(:package_id, :holding_id)
                       and pp.product_id = p.item_id 
                       and pp.price_list_id = :price_list_id "
} else {
    if {[regexp -nocase products "$query_sql"]} {
	# sto cercando dei prodotti
	set where_clause "        where u.um_id = p.um_id and
            p.package_id in(:package_id, :holding_id)"
    } else { 
	# estendo query con search_clause, generando se necessario una where clause
	if {![regexp -nocase where "$query_sql"]} {
	    set where_clause " where 1=1 "
	} else {
	    set where_clause ""
        }
    }
}

append query_sql $where_clause

append query_sql [ah::search_clause -search_word [DoubleApos $search_word] -search_field $name_col] 
# se la search clause e' troppo lasca rischio di restituire un set enorme,
# per cui lo limito a 100
append query_sql " limit 100"

# inizio compilazione lista
set list_template "
    template::list::create -name table_list  -multirow table_list -elements \{
    sel \{
    display_template \{@table_list.sel;noquote@\} 
    sub_class narrow
    \}
    "

# Itero tutti gli elementi della lista
set element_list [$root selectNodes //col]
foreach element $element_list {
    set name       [$element getAttribute name] 
    set label      [$element getAttribute label "$name"] ; # default name

    # continuo definizione dinamica di list_template
    append list_template "
        $name {
            label \"$label\"
        }
        "
}

append list_template "\}"

# inizio definizione della struttura multirow per popolare list_template
set list_multirow "
db_multirow \\
    -extend {sel} table_list query {
      $query_sql
    } {
	set sel \"<a href=\\\"javascript:sel('\$$key_col', '\$$code_col', '\[ah::js_quote_escape \$$name_col]')\\\">Sel</a>\"
    }
"

# ora creo un'unica struttura che rappresenta il programma di lista 
append list_template $list_multirow    

#ns_log notice "\nDEBUG\n$list_template"

# ed eseguo il frammento di codice generato
eval $list_template

