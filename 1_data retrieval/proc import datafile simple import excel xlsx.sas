/*Import excel xlsx into sas*/
proc import datafile="directory_path\file_name.xlsx" 
DBMS = xlsx
out=dsn&cnt /*DSN&CNT IS WHERE THE NAME OF THE DATA SET IS CREATED*/
replace;
SHEET="Daily";/*replace "Daily" with the name of the sheet in double quotes*/
run; 
