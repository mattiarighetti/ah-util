ad_library {

    General edit procs 

    @author claudio.pasolini@comune.mantova.it
    @cvs-id $Id:

}
 
namespace eval ah {}

ad_proc -public ah::check_num {numero {max_decimali "0"}} {
    Accetta in ingresso un campo alfanumerico contenente un numero editato.
    Controlla che abbia al massimo il numero di decimali indicato, 
    che la virgola sia una sola e nel posto corretto, i punti 
    delle migliaia siano nel posto corretto, dopo di che elimina tutti i punti
    e sostitusice la virgola con il punto.
}  {
    if {![string is integer -strict $max_decimali]} {
        return "Error"
    }

    set len [string length $numero]
    
  # controllo la presenza del segno 
    set segno ""
    if {[string index $numero [expr $len - 1]] == "-"} {
        set numero [string trimright $numero "-"]
        set segno "-"
    }

    if {[string range $numero 0 0] == "-"} {
        if {$segno == "-"} {
            return "Error"
        }
        set numero [string trimleft $numero "-"]
        set segno "-"
    }
    
  # elimino eventuali spazi dopo o prima il numero
    set numero [string trim $numero]

  # controllo esistenza di spazi all'interno del numero.
    set ctr_spazi   [regsub -all " " $numero "" numero]
    if {$ctr_spazi > 0} {
        return "Error"
    }

  # controllo la presenza di piu' virgole
    set ctr_virgole [regsub -all "," $numero "," campo_di_comodo1]
    if {$ctr_virgole > 1} {   
        return "Error"
    } 
    
  # controllo se i decimali sono 2 e se la virgola e' al posto corretto
    if {$ctr_virgole == 1} {
        set pos_virg [string first "," $numero]
        set decimali [string range $numero [expr $pos_virg + 1] end]
        set len_decimali [string length $decimali]
        if {$len_decimali > $max_decimali} {
            return "Error"
        }
    }

  # imposto la parte intera del numero
    if {$ctr_virgole == 1} {
        set intero [string range $numero 0 [expr $pos_virg - 1]]
    } else {
        set intero $numero
    }
    set len [string length $intero]
  # ovviamente se il numero e' vuoto non va bene.
    if {$len <= 0} {
        return "Error"
    }

  # controllo la presenza di punti separatori di migliaia
    set ctr_punti [regsub -all {\.} $intero {\.} campo_di_comodo2]
  
  # controllo che i punti separatori delle migliaia siano al posto corretto
    if {$ctr_punti > 0} {
        set puntatore [expr $len - 1]
        set pos       1
        while {$puntatore >= 0} {
            set carattere [string range $intero $puntatore $puntatore]
            
            if {$pos < 4} {
                if {$carattere == "."} {
                    return "Error"
                }
            } else {
                if {$carattere == "."} {
                    set pos 0     
                } else {
                    set pos 1
                } 
            }
            incr pos
            set puntatore [expr $puntatore - 1]
        }
    }

  # elimino tutti i punti
    regsub -all  {\.} $intero {} intero
    if {![string is digit $intero]} {
        return "Error"
    }

  # ricostruisco il numero
    if {$segno == "-"} {
	set numero "-$intero"
    } else {
        set numero $intero
    }

    if {$ctr_virgole == 1} {
	if {[string is digit $decimali]} {
            set numero "$numero.$decimali"
        } else {
            return "Error"
        }
    }
    
    return $numero
}


ad_proc -public ah::edit_num {num {max_dec "2"}} {
    Accetta in ingresso un campo numerico e lo edita inserendo i punti
    separatori delle migliaia e converte il separatore dei decimali da punto
    a virgola.
} {
    with_catch errmsg {
        set pretty_num [db_string query "select ah_edit_num(:num, :max_dec)"]
    } {
        return "Error"
    }

    return $pretty_num
}

ad_proc -public ah::check_date {
    -input_date:required
} {
    Controlla la data e la ritorna, se corretta, in formato YYYYMMDD altrimenti ritorna 0.
    La data argomento viene accettata nei formati ddmmyy dd/mm/yy ddmmyyyy e dd/mm/yyyy.
} {
    
    if {[string length $input_date] < 6 || [string length $input_date] > 10} {
	return 0
    }

    if {![regexp {(.*)/(.*)/(.*)} $input_date  match dd mm yy]} {
	set yy [string range $input_date 4 end]
	set mm [string range $input_date 2 3]
	set dd [string range $input_date 0 1]
    }

    # verifico che tutti i campi siano numerici
    if {![string is integer [string trimleft $yy$mm$dd 0]]} {
	return 0
    }

    if {[string length $yy] == 2} {
	if {$yy <= 38} {
	    set yy 20$yy
	} else {
	    set yy 19$yy
	}
    }

    if [catch {clock scan "$mm/$dd/$yy"} errmsg] {
	return 0
    } else {
	return "$yy$mm$dd"
    }
}

ad_proc -public lc_parse_date {input_date {locale "it_IT"}
} {
    Controlla la validita' della data in rapporto al 'locale' specificato.
    Se la data e' corretta la restituisce  in formato ANSI (YYYY-MM-DD) altrimenti 
    genera un errore.
    La input_date, nella quale l'ordine dei giorni e dei mesi dipende dal 'locale',
    viene accettata con e senza barre separatrici e con l'anno di 2 o 4 cifre.
} {
    
    if {[string length $input_date] < 6 || [string length $input_date] > 10} {
	error "[_ ah-int.Data_errata]"
    }

    # estraggo il formato della data nel locale 
    set d_fmt [lc_get -locale $locale "d_fmt"]

    # il formato e' una stringa %m/%d/%y oppure %d/%m/%y
    if {[string index $d_fmt 1] == "d"} {
	if {![regexp {(.*)/(.*)/(.*)} $input_date  match dd mm yy]} {
	    set yy [string range $input_date 4 end]
	    set mm [string range $input_date 2 3]
	    set dd [string range $input_date 0 1]
	}
    } else {
	if {![regexp {(.*)/(.*)/(.*)} $input_date  match mm dd yy]} {
	    set yy [string range $input_date 4 end]
	    set mm [string range $input_date 0 1]
	    set dd [string range $input_date 2 3]
	}
    }

    # verifico che tutti i campi siano numerici
    if {![string is integer [string trimleft $yy$mm$dd 0]]} {
	error "[_ ah-int.Data_errata]"
    }

    if {[string length $yy] == 2} {
	if {$yy <= 38} {
	    set yy 20$yy
	} else {
	    set yy 19$yy
	}
    }

    if [catch {clock scan "$mm/$dd/$yy"} errmsg] {
	error "[_ ah-int.Data_errata]"
    } else {
	return "$yy-$mm-$dd"
    }
}

ad_proc -public ah::string_to_list {
    -string:required
    {-length "70"}
    {-keep_nl "f"}
} {
    Accetta in ingresso la stringa 'string'. 
    Sostituisce i new_line con spazi, a meno che keep_nl sia impostato a 't'.
    Trasforma la stringa in una lista in cui ogni elemento e' lungo al massimo
    il valore 'length'. La stringa viene spezzata solo al confine fra due parole.
} {

    # rimuovo carattere new line se necessario
    if {[string equal $keep_nl "f"]} {
	regsub -all {\n} $string { } string
    }

    set list [list]
    set end [expr $length - 1]

    # itero la stringa 
    while {[string length $string] > $length} {
	# cerco l'ultimo spazio per rompere la stringa
	set i [string last " " $string $end]
	if {$i == -1} {
	    # non ho trovato alcuno spazio e devo troncare una parola
	    set i $end
	}
	# estraggo primo pezzo e lo appendo alla lista
	lappend list [string range $string 0 $i]
	# rimuovo il pezzo estratto dalla stringa
	set string [string range $string [incr i] end]
    }

    # appendo l'ultimo moncone
    lappend list [string range $string 0 end]

    return $list
	
}

ad_proc -public ah::month_end {date} {
    Accetta in ingresso una data nel formato YYYY-MM-DD e restituisce una
    una data nello stesso formato con i giorni impostati a fine mese.
} {
    # imposto array con dash, in modo da evitare il noto problema degli ottali
    set mont_end(-01-) 31
    set mont_end(-02-) 28
    set mont_end(-03-) 31
    set mont_end(-04-) 30
    set mont_end(-05-) 31
    set mont_end(-06-) 30
    set mont_end(-07-) 31
    set mont_end(-08-) 31
    set mont_end(-09-) 30
    set mont_end(-10-) 31
    set mont_end(-11-) 30
    set mont_end(-12-) 31

    set year [string range $date 0 3]
    if {[expr $year % 4] == 0} {
	set mont_end(-02-) 29
    }

    set index [string range $date 4 7]

    return [string range $date 0 7]$mont_end($index)
}

ad_proc -public ah::month_char {date} {
    Accetta in ingresso una data nel formato YYYY-MM-DD e restituisce il mese
    per esteso.
} {
    set mont_pretty(-01-) "Gennaio"
    set mont_pretty(-02-) "Febbraio"
    set mont_pretty(-03-) "Marzo"
    set mont_pretty(-04-) "Aprile"
    set mont_pretty(-05-) "Maggio"
    set mont_pretty(-06-) "Giugno"
    set mont_pretty(-07-) "Luglio"
    set mont_pretty(-08-) "Agosto"
    set mont_pretty(-09-) "Settembre"
    set mont_pretty(-10-) "Ottobre"
    set mont_pretty(-11-) "Novembre"
    set mont_pretty(-12-) "Dicembre"

    set index [string range $date 4 7]

    return $mont_pretty($index)
}

ad_proc -public ah::round {
    num {pos 2}
} {
    Arrotonda il numero 'num' alla cifra decimale 'pos'. 
    Default alla seconda cifra decimale. 
} {
    set zeros [string repeat 0 $pos]
    return [expr round($num * 1$zeros) / 1$zeros.00]
}


ad_proc -public ah::lpad {
    str len padchar
} {
    String left padding
} {
    set pad [string repeat $padchar [expr $len - [string length $str]]]
    return $pad$str
}


