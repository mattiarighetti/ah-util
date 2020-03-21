ad_page_contract {
  
    Data una stringa di ricerca 'search_word' questo programma propone una lista
    di prodotti che soddisfano la ricerca e restituisce al chiamante il codice, il colore,
    la descrizione, il prezzo, lo sconto ed il prezzo netto del prodotto selezionato.

    La presenza fra gli argomenti del codice cliente 'customer_id' indica che si 
    desidera ottenere lo sconto di vendita, nel qual caso il programma applica
    eventuali condizioni particolari (rilevate dalla tabella mis_cust_price_map) o 
    in alternativa lo sconto standard di vendita tipico del listino.
    
    Se il codice cliente non e' presente viene proposto lo sconto di acquisto.

    L'eventuale indicazione del listino ha l'effetto di limitare la ricerca
    ai soli prodotti del listino selezionato.

    @author Claudio Pasolini
    @cvs-id $Id: pricelist.tcl
} {
    {search_word ""}
    {customer_id "0"}
    {price_list_id ""}
}

# define JS function for adp page
set javascript "
<script language=JavaScript>
  function sel(a,b,c,d,e,f,g) {
    window.opener.document.lineaddedit.product_id.value = a;
    window.opener.document.lineaddedit.title.value = b;
    window.opener.document.lineaddedit.product_price_pretty.value = c;
    window.opener.document.lineaddedit.discount_pretty.value = d;
    window.opener.document.lineaddedit.product_net_price_pretty.value = e;
    window.opener.document.lineaddedit.product_code.value = f;
    window.opener.document.lineaddedit.color_code.value = g;
    window.close();
  }
</script>
"

set page_title "Lista Prodotti"
set context [list "Lista Prodotti"]

template::list::create \
    -name products \
    -multirow products \
    -elements {
	sel {
	    display_template {@products.sel;noquote@}
	    sub_class narrow
	}
	product_code {
	    label "Codice"
	}
	color_code {
	    label "Colore"
	}
	title {
	    label "Descrizione"
	}
	product_price_pretty {
	    label "Prezzo"
	    html {align right}
	}
	discount_pretty {
	    label "Sconto"
	    html {align right}
	}
	product_net_price_pretty {
	    label "Prezzo netto"
	    html {align right}
	}
    }

# preparo frammenti della query
if {$customer_id == 0} {
    set sql1 "
            case 
             when pp.product_discount = 0 then 
                  ah_edit_num(pl.purchasing_discount, 2)
             else ah_edit_num(pp.product_discount, 2)
           end as discount_pretty,
           case 
             when pp.product_discount = 0 then 
                  ah_edit_num(product_price - (product_price * purchasing_discount / 100),2)
             else ah_edit_num(product_price - (product_price * product_discount / 100),2)
           end as product_net_price_pretty
"
    set sql2 ""
} else {
    set sql1 "
           case 
             when pm.sale_discount is null then 
                  ah_edit_num(pl.default_sale_discount, 2)
             else ah_edit_num(pm.sale_discount, 2)
           end as discount_pretty,
           case 
             when pm.sale_discount is null then 
                  ah_edit_num(product_price - (product_price * default_sale_discount / 100),2)
             else ah_edit_num(product_price - (product_price * sale_discount / 100),2)
           end as product_net_price_pretty
"
    set sql2 "
           left outer join mis_cust_price_map pm
               on pm.customer_id   = :customer_id and
                  pm.price_list_id = pl.price_list_id
"
}  

if {[string equal $price_list_id ""]} {
    set from_clause "
      from mis_products_and_colors p
           left outer join mis_product_prices pp
               on (p.product_code = pp.product_code and
                   p.color_type   = pp.color_type) or
                  (p.product_code = pp.product_code and
                   p.color_type is null) 
           left outer join mis_price_lists pl 
               on pp.price_list_id = pl.price_list_id"
    set where_clause "1 = 1"
} else {
    set from_clause "
       from mis_products_and_colors p, mis_product_prices pp, mis_price_lists pl"
    set where_clause " ((p.product_code   = pp.product_code and
                        p.color_type     = pp.color_type) or
                       (p.product_code   = pp.product_code and
                        p.color_type is null)) and
                       pp.price_list_id = pl.price_list_id and
                       pl.price_list_id = :price_list_id"
}

db_multirow \
    -extend {
	sel
    } products query "
      select item_id, 
             p.product_code, 
             title,
             ah_edit_num(pp.product_price, 2) as product_price_pretty,
             color_code,
             p.color_type, 
      $sql1
      $from_clause
      $sql2
      where $where_clause
        [ah::search_clause -search_word [DoubleApos $search_word] -search_field upper_title]
      order by product_code
      limit 100
    " {
	set sel "<a href=\"javascript:sel('$item_id', '[ah::js_quote_escape $title]', '$product_price_pretty', '$discount_pretty', '$product_net_price_pretty', '$product_code', '$color_code')\">Sel</a>"
    }

