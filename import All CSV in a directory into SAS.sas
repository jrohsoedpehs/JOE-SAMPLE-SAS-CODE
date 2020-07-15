/*********************************************************************

 						THIS ONE WORKS

**********************************************************************/



/*OTHER ATTEMPT*/
/*RUN THIS TO IMPORT ALL OF THE EXCEL FILES FROM A FOLDER AND CREATE TEMPORARY SAS DATA SETS*/
/*WILL NEED TO CREATE A PERMANENT SAS DATA SET BY SETING THE TEMPORARY TOGETHER - DONE IN THE NEXT STEP AFTER MACRO*/

%macro drive(dir,ext); 
   %local cnt filrf rc did memcnt name; 
   %let cnt=0;          

   %let filrf=mydir;    
   %let rc=%sysfunc(filename(filrf,&dir)); 
   %let did=%sysfunc(dopen(&filrf));
    %if &did ne 0 %then %do;   
   %let memcnt=%sysfunc(dnum(&did));    

    %do i=1 %to &memcnt;              
                       
      %let name=%qscan(%qsysfunc(dread(&did,&i)),-1,.);                    
                    
      %if %qupcase(%qsysfunc(dread(&did,&i))) ne %qupcase(&name) %then %do;
       %if %superq(ext) = %superq(name) %then %do;                         
          %let cnt=%eval(&cnt+1);       
          %put %qsysfunc(dread(&did,&i));  
          proc import datafile="&dir\%qsysfunc(dread(&did,&i))" out=dsn&cnt /*DSN&CNT IS WHERE THE NAME OF THE DATA SET IS CREATED*/
           dbms=csv replace;            
          run;          
       %end; 
      %end;  

    %end;
      %end;
  %else %put &dir cannot be open.;
  %let rc=%sysfunc(dclose(&did));      
             
 %mend drive;
 
%drive(Q:\Kathy Richards\NARLS_2017\data\Raw\LABCORP Excel Files,csv) /*change the path name and filetype here, tested for csv*/

PROC PRINT DATA = DSN1;
RUN;

/*SET THE DATA TABLES ON TOP OF EACH OTHER TO CREATE THE PERMANENT SAS DATA SET*/
data raw.labcorp_exportfiles&sysdate;
	set DSN:;               **sets all datasets with the prefix DSN this saves us from manually updating the set statement each iteration;
	by Patient_Name;
	resident_id = substr(Patient_Name, 6,3)||"_"||substr(Patient_Name,10,4);
run;


proc print data = raw.labcorp_exportfiles&sysdate;
var patient_name resident_id;
run;

