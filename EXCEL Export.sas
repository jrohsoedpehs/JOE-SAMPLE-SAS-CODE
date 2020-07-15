/*Export dataset to EXCEL .XLSX*/

proc export data=m2limited
     outfile="path\file.xlsx"
     replace
     dbms=xlsx;
run;

