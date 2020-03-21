# prepare links to forward & backward pages
set page_fwd [expr $offset + $rows_per_page]
set page_bwd [expr $offset - $rows_per_page]

# grabs all vars but offset
set url_vars [export_ns_set_vars "url" {offset}]

set base_url [ad_conn url]

set init_page     "Pag. iniziale"
set next_page     "Pag. successiva"
set previous_page "Pag. precedente"

if {$offset > 0} {
    lappend actions "$init_page" $base_url?$url_vars "$init_page"
}
lappend actions "$next_page" $base_url?offset=$page_fwd&$url_vars "$next_page"
if {$page_bwd >= 0} {
    lappend actions "$previous_page" $base_url?offset=$page_bwd&$url_vars "$previous_page"
}
