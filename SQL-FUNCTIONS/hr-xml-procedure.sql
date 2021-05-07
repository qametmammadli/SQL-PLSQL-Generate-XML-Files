create or replace directory txt_dir as 'D:\Files';
/

grant read, write on directory txt_dir to public;
/

create table hr.emp_xml (
  id number not null,
  create_date date,
  xml_data  xmltype,
  constraint emp_xml_pk primary key (id)
);
/

create sequence hr.emp_xml_seq increment by 1 start with 1 minvalue 1;
/

create or replace procedure generate_dept_emp_xml as
  l_xmltype xmltype;
  xml_file utl_file.file_type;
  txt_line clob;
  l_date date;
begin
    select sys_xmlagg(xmlelement("department",
                  xmlattributes(department_id as "id"),
                    xmlelement("department_name", department_name),
                      xmlelement("employees",
                                  (select xmlagg(xmlelement("employee", 
                                            xmlattributes(employee_id as "id"),
                                                    xmlforest(
                                                            first_name as "first_name",
                                                            last_name as "last_name",
                                                            salary as "salary",
                                                            hire_date as "hire_date"
                                                        )
                                                    )
                                                ) 
                                  from hr.employees emp where emp.department_id = dept.department_id)
                                )
                      )
                ) into l_xmltype 
              from hr.departments dept;
  
  insert into hr.emp_xml values (hr.emp_xml_seq.nextval, current_date, l_xmltype);
  commit;
  
  select x.create_date, x.xml_data.getclobval() into l_date, txt_line 
      from hr.emp_xml x where rownum = 1 order by 1 desc;
  
  xml_file := utl_file.fopen('TXT_DIR','hr-dept-emp-'|| l_date ||'.xml','W');
  utl_file.put_line(xml_file, txt_line);
  utl_file.fclose(xml_file);
end;
/

exec generate_dept_emp_xml;
/