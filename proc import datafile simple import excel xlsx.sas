/*Import excel xlsx into sas*/
proc import datafile="directory_path\file_name.xlsx" 
DBMS = xlsx
/*DSN&CNT IS WHERE THE NAME OF THE DATA SET IS CREATED*/
out=dsn&cnt 
replace;
/*replace "Daily" with the name of the sheet in double quotes*/
SHEET="Daily";
run; 
