ad_page_contract {

    @author Claudio Pasolini
    @cvs-id $Id: list.tcl
} {
    price_list_id:integer
    {search_word ""}
}

# define JS function for adp page
set javascript "
<script language=JavaScript>
  function sel(a,b,c,d,e,f,g) {
    window.opener.document.lineaddedit.product_id.value = a;
    window.opener.document.lineaddedit.title.value = b;
    window.opener.document.lineaddedit.sell_um_id.value = c;
    window.opener.document.lineaddedit.product_price_pretty.value = d;
    window.opener.document.lineaddedit.discount_pretty.value = e;
    window.opener.document.lineaddedit.product_net_price_pretty.value = f;
    window.opener.document.lineaddedit.product_code.value = g;
    window.close();
  }
</script>
"

db_1row query "
    select flat_discount, ah_edit_num(flat_discount, 2) as discount_pretty
    from mis_price_lists 
    where price_list_id=:price_list_id " 
   
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
	title {
	    label "Descrizione"
	}
	drawing_id {
	    label "Disegno"
	}
    }


db_multirow \
    -extend {
	sel
    } products query "
      select item_id, product_code, title, um_id, sell_um_id, drawing_id, 
             product_price,
             ah_edit_num(product_price, 2) as product_price_pretty, 
             ah_edit_num(product_price - (product_price * $flat_discount / 100),2) as product_net_price_pretty
      from mis_active_products p left outer join mis_product_prices pp
          on p.item_id     = pp.product_id and 
             price_list_id = :price_list_id
      where 1 = 1
        [ah::search_clause -search_word [DoubleApos $search_word] -search_field upper_title]
        limit 100
    " {
	set sel "<a href=\"javascript:sel('$item_id', '[ah::js_quote_escape $title]', '$sell_um_id', '$product_price_pretty', '$discount_pretty', '$product_net_price_pretty', '$product_code')\">Sel</a>"
    }



