create or replace directory txt_dir as 'D:\Files';
/

grant read, write on directory txt_dir to public;
/

declare
  l_xml_type xmltype;
  l_ctx dbms_xmlgen.ctxhandle;
  l_xml_file utl_file.file_type;
begin
  l_xml_file := utl_file.fopen('TXT_DIR','dbms_gen-hr-departments-'|| current_date ||'.xml','W');
  l_ctx := dbms_xmlgen.newcontext('select employee_id as "id", first_name as "first_name", last_name as "last_name", 
                      salary as "salary", hire_date as "hire_date", d.department_name as "department_name"
                       from hr.employees e 
                      join hr.departments d on e.department_id = d.department_id');
 
  dbms_xmlgen.setrowsettag(l_ctx, 'employees'); 
  dbms_xmlgen.setrowtag(l_ctx, 'employee');

  l_xml_type := dbms_xmlgen.getxmltype(l_ctx) ;
  dbms_xmlgen.closecontext(l_ctx);

  utl_file.put_line(l_xml_file, l_xml_type.getclobval);
  utl_file.fclose(l_xml_file);
end;
/
