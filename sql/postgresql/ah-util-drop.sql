-- Deletion script

-- delete content items
create function inline_0 ()
returns integer as '
declare
    v_item RECORD;
begin
        for v_item in select item_id from cr_items 
                      where content_type = ''mis_script''
                      order by parent_id desc
        LOOP
                PERFORM content_item__delete(v_item.item_id);
        end loop;
    return 0;
end;
' language 'plpgsql';

select inline_0();
drop function inline_0();

delete from cr_folder_type_map where content_type='mis_script';

-- remove content_type
select content_type__drop_type(
	   'mis_script',
	   't',
	   't'
    );

-- unregister content_type
select content_folder__unregister_content_type(-100,'mis_script','t');


-- remove children
select acs_privilege__remove_child('admin','exec');

-- drop privilege
select acs_privilege__drop_privilege('exec');

-- drop function ah_edit_num(float, integer);
