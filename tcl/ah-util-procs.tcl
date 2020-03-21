ad_library {

    General procs 

    @author claudio.pasolini@comune.mantova.it
    @cvs-id $Id:

}

namespace eval ah {}

ad_proc -public ah::service_root  {
} { 
    Returns the root path of the service, i.e. /var/lib/aolserver/service 
} {
    set root [ns_info pageroot]
    regsub {/www} $root {} root
    return $root
}

ad_proc -public ah::package_root  {
    -package_key
} { 
    Returns the root path, down to www, of the requested package, 
    i.e. /var/lib/aolserver/packages/mis/www
    If omitted, returns the root path of the current package.
} {
    if {![info exists package_key]} {
	set package_key [ad_conn package_key]
    }
    set path [service_root]/packages/$package_key/www
    return $path
}

ad_proc -public ah::key_selected_p  {
    -key:required
} { 
    If the parameter is null send an error message and stops the script.
    To be used by the scripts invoked via bulk_actions.
} {
    if {[string equal $key ""]} {
	ad_return_complaint 1 "Non hai selezionato alcun oggetto su cui operare: usa il tasto indietro e riprova."
	ad_script_abort
    }
}

ad_proc -public ah::search_tab  {
    -query_spec:required
    -form_name:required
    -form_key_field:required
    -form_code_field:required
    -form_name_field:required
} { 
    Crea un link al programma standard di lista. Quest'ultimo utilizza le specifiche
    contenute in 'query_spec' per costruire dinamicamente una lista e restituire al
    form 'form_name' il codice 'form_key_field' e la descrizione 'form-name_field'
    dell'elemento selezionato.  
    Per convenzione la stringa di ricerca deve essere fornita nel campo 'form_name_field'
} {

    set package_id [ad_conn package_id]

    return "<a href=\"#\" onClick=\"javascript:window.open('/ah-util/list-builder?package_id=$package_id&query_spec=$query_spec&form_name=$form_name&form_key_field=$form_key_field&form_code_field=$form_code_field&form_name_field=$form_name_field&search_word=' + document.$form_name.$form_name_field.value, 'listbuilder2', 'scrollbars=yes,resizable=yes,width=800,height=600')\"> Cerca</a>" 

}

ad_proc -public ah::search_prod  {
    -form_name:required
    -form_key_field:required
    -form_code_field:required
    -form_name_field:required
} { 
    Simile a search_tab ma passa in piu' price_list_id in modo da limitare la 
    lista dei prodotti allo specifico listino.
} {

    set package_id [ad_conn package_id]

    return "<a href=\"#\" onClick=\"javascript:window.open('/ah-util/list-builder?package_id=$package_id&query_spec=product-prices&form_name=$form_name&form_key_field=$form_key_field&form_code_field=$form_code_field&form_name_field=$form_name_field&search_word=' + document.$form_name.$form_name_field.value + '&price_list_id=' + document.$form_name.price_list_id.value, 'listbuilder2', 'scrollbars=yes,resizable=yes,width=800,height=600')\"> Cerca</a>" 
}

ad_proc -public ah::search_clause {
    -search_field:required
    -search_word:required
} { 
    This proc sets an sql where clause to search search_word into search_field
} {
    # prepare clause if search string provided by user
    if {[string equal $search_word ""]} {
	return ""
    }

    # if search_field name starts with upper_ we don't want to apply the
    # upper function to it, so as to be able to exploit eventual indexes
    if {[string range $search_field 0 5] != "upper_"} {
	set search_field "upper($search_field)"
    }

    foreach token $search_word {
	append where_clause " and $search_field like upper('%$token%') "
    }

    return $where_clause
}

ad_proc -public ah::date_clause {
    -date_field:required
    -from_date:required
    -to_date:required
} {
    This proc sets an sql where clause to match a date_field between two dates
} {
    # prepare clause if search string provided by user
    if {[string equal $from_date ""] && [string equal $to_date ""]} {
        set where_clause ""
    } else {
        if {[string equal $from_date ""]} {
            set from_date "01/01/1900"
        }
        if {[string equal $to_date ""]} {
            set to_date "31/12/2100"
        }
        set from_date [ah::check_date -input_date $from_date]
        set to_date [ah::check_date -input_date $to_date]
        if {[string equal $from_date "0"] || [string equal $to_date "0"]} {
            set where_clause ""
        } else {
            set where_clause "and $date_field between '$from_date' and '$to_date'"
        }
    }

    return $where_clause
}

ad_proc -public ah::debug {
 -package_key 
} { 
    This proc enables debugging if necessary
} {
    if {![info exists package_key]} {
	set package_key [ad_conn package_key]
    }
    # if requested debug is enabled
    set debug_p [parameter::get_from_package_key \
		     -package_key $package_key \
		     -parameter debug_p \
		     -default 0]
    if {$debug_p} {
	# useful for debugging ad_form
	ns_log notice "it's my page!"
	set mypage [ns_getform]
	if {[string equal "" $mypage]} {
	    ns_log notice "no form was submitted on my page"
	} else {
	    ns_log notice "the following form was submitted on my page"
	    ns_set print $mypage
	}
    }
}

ad_proc -public ah::script_init {
    {-script_id ""}
    {-script_name ""}
} { 
    This proc initializes scripts
} {
    if {![string equal $script_name ""]} {
	if {[db_0or1row query "select ci.item_id from cr_items ci, mis_scriptsx sc where sc.name = :script_name and sc.revision_id = ci.live_revision"]} {
	    set script_id $item_id
	} else {
	    set script_id ""
	}
    }
    ad_maybe_redirect_for_registration
    permission::require_permission -object_id $script_id -privilege exec
    ah::debug
}

ad_proc -public ah::js_quote_escape {
    literal
} { 
    Escapes single and double quotes in literals fo JavaScript
} {
    regsub -all ' "$literal" \\' result
    regsub -all \" "$result" \\' result
    return $result
}

ad_proc -public ah::set_list_filters {
    module
    listname
} {
    Sets the filters reading them from the client property where they was stored.
    To be called when adding search fields to the regular list filters.
    Example:  ah::set_list_filters mis products-list
} {
    # get the saved filters, if any
    set url_vars [ad_get_client_property -default "" $module $listname]
    set url_vars [ns_urldecode $url_vars]

    # split the urls getting a list of name value couples
    set args [split $url_vars =&]
    set i 0
    while {$i < [llength $args]} {
        set name  [lindex $args $i]
	set value [lindex $args [expr $i + 1]]
	upvar $name filter
        if {![info exists filter] || [string equal $name "rows_per_page"]} {
	    # set the filters in the caller scope
	    uplevel  set $name $value
	}
	incr i 2
    }
}

ad_proc -public ah::coalesce {
    var def
} { 
    Analgous to postgresql function
} {
    if {[string equal $var ""]} {
	return $def
    } else {
	return $var
    }
}

ad_proc -public ah::sanitize_bad_winword_chars {
    str
} {
    Transforms bad chars generated from WinMord into normal chars
} {
    regsub -all {\u2018} $str {'} str
    regsub -all {\u2019} $str {'} str
    regsub -all {\u2013} $str {-} str
    regsub -all {\u2014} $str {-} str
    regsub -all {\u2022} $str {*} str
    regsub -all {\u201C} $str "\"" str
    regsub -all {\u201D} $str "\"" str
    regsub -all {\u2026} $str {...} str
        return $str
}
