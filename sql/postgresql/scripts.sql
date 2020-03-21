-- ---------------------------------------------------------
--
-- mis-script content type
--
-- ---------------------------------------------------------

select content_type__create_type(
    'mis_script',                  -- content_type
    'content_revision',            -- supertype
    'Script',                      -- pretty_name,
    'Scripts',                     -- pretty_plural
    'mis_scripts',                 -- table_name
    'script_id',                   -- id_column
    null                           -- name_method
);

select content_type__create_attribute (
    'mis_script',         -- content_type
    'original_author',    -- attribute_name
    'integer',            -- datatype (string, number, boolean, date, keyword, integer)
    'Autore originale',   -- pretty_name
    'Autore originali',              -- pretty_plural
    null,                 -- sort_order
    null,                 -- default value
    'integer constraint mis_scripts_fk1 references users(user_id)'  -- column_spec 
);

select content_type__create_attribute (
    'mis_script',         -- content_type
    'maintainer',         -- attribute_name
    'integer',            -- datatype (string, number, boolean, date, keyword, integer)
    'Gestore attuale',    -- pretty_name
    'Gestore attuali',    -- pretty_plural
    null,                 -- sort_order
    null,                 -- default value
    'integer constraint mis_scripts_fk2 references users(user_id)'  -- column_spec 
);

select content_type__create_attribute (
    'mis_script',         -- content_type
    'is_active_p',        -- attribute_name
    'boolean',            -- datatype (string, number, boolean, date, keyword, integer)
    'Attivo?',            -- pretty_name
    'Attivi?',            -- pretty_plural
    null,                 -- sort_order
    null,                 -- default value
    'boolean'             -- column_spec 
);

select content_type__create_attribute (
    'mis_script',         -- content_type
    'is_executable_p',    -- attribute_name
    'boolean',            -- datatype (string, number, boolean, date, keyword, integer)
    'Eseguibile?',        -- pretty_name
    'Eseguibili?',            -- pretty_plural
    null,                 -- sort_order
    null,                 -- default value
    'boolean'             -- column_spec 
);

-- necessary to work around limitation of content repository:
select content_folder__register_content_type(-100,'mis_script','t');

