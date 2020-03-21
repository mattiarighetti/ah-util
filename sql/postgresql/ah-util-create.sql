-- Creation script
\i scripts.sql

-- define custom privileges
select acs_privilege__create_privilege('exec',null,null);
select acs_privilege__add_child('admin','exec');

\i ah-functions.sql
