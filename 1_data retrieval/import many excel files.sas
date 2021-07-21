footnote "SAS program stored in: Q:\Jesse Chittams\Renee Moore\PA_Study_2018\programs\Draft\semester2_Week_1_accelerometer_report.sas";


/*EXAMPLE*/
proc import datafile="&dir\8 50 Start_3 11 19_W4.xlsx" 
proc import datafile="&dir\%qsysfunc(dread(&did,&i))" 
DBMS = xlsx
out=dsn&cnt /*DSN&CNT IS WHERE THE NAME OF THE DATA SET IS CREATED*/
replace;
SHEET="Daily" ;
run; 

/*EXAMPLE*/
data dummy;
cnt = 0; 
/*filrf = mydir; */
rc = filename("mydir", "Q:\Jesse Chittams\Renee Moore\PA_Study_2018\data\Raw\daily accelerometer\semester2\week4"); /*explain filename( */
did = dopen(mydir); /*explain dopen( */
folder_number = dread(did, 1);
rc = dclose(did);
run;

proc print data=dummy;
run;



/*MACRO*/
*%macro drive(dir,ext); 
%local cnt filrf rc did memcnt name;
 
%let cnt=0; 
%let filrf=mydir; 
%let rc=%sysfunc(filename(filrf,&dir)); /*explain filename( */
%let did=%sysfunc(dopen(&filrf)); /*explain dopen( */

/*START LOOP 1*/
%if &did ne 0 %then %do;
%let memcnt=%sysfunc(dnum(&did)); 

/*	START LOOP 2*/
    %do i=1 %to &memcnt;  
        %let name=%qscan(%qsysfunc(dread(&did,&i)),-1,.);  /*dread( */

/*	    START LOOP 3*/
        %if %qupcase(%qsysfunc(dread(&did,&i))) ne %qupcase(&name) %then %do;

/*          START LOOP 4*/
            %if %superq(ext) = %superq(name) %then %do; 
                %let cnt=%eval(&cnt+1); 
                %put %qsysfunc(dread(&did,&i)); /*dread( */
 
                proc import datafile="&dir\%qsysfunc(dread(&did,&i))" 
                DBMS = xlsx
                out=dsn&cnt /*DSN&CNT IS WHERE THE NAME OF THE DATA SET IS CREATED*/
                replace;
                SHEET="Daily" ;
                run; 

/*		    END LOOP 4*/
            %end; 

/*		END LOOP 3*/
        %end;  

/*    END LOOP 2*/
    %end;

/*END LOOP 1*/
%end;
%else %put &dir cannot be open.; 
%let rc=%sysfunc(dclose(&did)); /*explain dopen( */

%mend drive;
 
/*List directory path (Not the file itself but the folder)*/
/*and the file type (xlsx)*/
/*sample*/
/*%drive(Q:\Jesse Chittams\Renee Moore\PA_Study_2018\data\Raw\xmls,xlsx); */
/*PROC PRINT DATA = DSN1;*/
/*RUN;*/

/*Semester 2 week 4 All Classes*/
%drive(Q:\Jesse Chittams\Renee Moore\PA_Study_2018\data\Raw\daily accelerometer\semester2\week4,xlsx); 

PROC PRINT DATA = DSN1 (obs=10);
RUN;

/*proc contents data=DSN1 varnum;run;*/


/*SET THE DATA TABLES ON TOP OF EACH OTHER TO CREATE THE PERMANENT SAS DATA SET*/
data accelerometers_s2_wk4;
set  dsn1 - dsn2;
run;


















/*REFERENCE*/
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
          proc import datafile="&dir\%qsysfunc(dread(&did,&i))" 
          DBMS = xlsx
		  out=dsn&cnt /*DSN&CNT IS WHERE THE NAME OF THE DATA SET IS CREATED*/
          replace;
/*		  Hourly*/
/*          SHEET="Hourly" ;*/
/*		  Daily*/
		  SHEET="Daily" ;
          run; 
/*          dbms=csv replace; */
/*These options may allow us to choose a specific sheet*/
/*		   SHEET="Hourly"; */
/*           GETNAMES=YES;*/
/*           MIXED=YES;*/
/*           SCANTEXT=YES;*/
/*           USEDATE=NO;*/
/*           SCANTIME=NO;*/
/*           run;          */
       %end; 
      %end;  

    %end;
      %end;
  %else %put &dir cannot be open.;
  %let rc=%sysfunc(dclose(&did));      
