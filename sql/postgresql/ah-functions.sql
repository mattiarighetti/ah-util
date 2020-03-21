create or replace function ah_edit_num(float, integer) returns varchar as '
declare
   nume       alias for $1;
   deci       alias for $2;
   ws_max_val float := 999999999999999.9999999999;
   ws_min_val float := -99999999999999.9999999999;
   risultato  varchar;
   edit_deci  varchar;
begin
   if deci > 10
   then
      return ''Error: max 10 decimali'';
   end if;

   if nume > ws_max_val
   or nume < ws_min_val
   then
      return ''Error: max 14 cifre intere'';
   end if;

   if deci < 1
   or deci is null
   then
      edit_deci := '''';
   else
      edit_deci := ''.''||rpad(0,deci,0);
   end if;

   risultato := to_char(nume, ''999,999,999,999,990''||edit_deci);
   risultato := translate (risultato,'','',''!'');
   risultato := translate (risultato,''.'','','');
   risultato := translate (risultato,''!'',''.'');
   risultato := trim (risultato);

   return risultato;

end;' language 'plpgsql';


create or replace function ah_replace (varchar, varchar, varchar) returns varchar as '
declare
    string      alias for $1;
    sub         alias for $2;
    replacement alias for $3;
    -- xxxxxxxxxxx[MATCH]xxxxxxxxxxxx
    --           | end_before
    --                   | start_after
    match integer;
    end_before integer;
    start_after integer;
    string_replaced varchar;
    string_remainder varchar;
begin
    string_remainder := string;
    string_replaced := '''';
    match := position(sub in string_remainder);

    while match > 0 loop
        end_before := match - 1;
        start_after := match + length(sub);
        string_replaced := string_replaced || substr(string_remainder, 1, end_before) || replacement;
        string_remainder := substr(string_remainder, start_after);
        match := position(sub in string_remainder);
    end loop;
    string_replaced := string_replaced || string_remainder;

    return string_replaced;
end;
' LANGUAGE 'plpgsql';

-- calculates net price rounded to two decimal pos
create or replace function ah_net_price(float, float, float, float) returns float as '
declare
   v_price      alias for $1;
   v_dsc1       alias for $2;
   v_dsc2       alias for $3;
   v_dsc3       alias for $4;

   price      float;
   dsc1       float;
   dsc2       float;
   dsc3       float;

   net_price  float;

begin

   price := v_price;

   if v_dsc1 is null 
   then
      dsc1 := 0.00;
   else
      dsc1 := v_dsc1;
   end if;
   if v_dsc2 is null 
   then
      dsc2 := 0.00;
   else
      dsc2 := v_dsc2;
   end if;
   if v_dsc3 is null 
   then
      dsc3 := 0.00;
   else
      dsc3 := v_dsc3;
   end if;

   net_price := ((price - price * dsc1 / 100) - (price - price * dsc1 / 100) * dsc2 / 100) - ((price - price * dsc1 / 100) - (price - price * dsc1 / 100) * dsc2 / 100) * dsc3 /100; 

   return round(net_price::numeric, 2);

end;' language 'plpgsql';

