libname raw "Q:\Jesse Chittams\Renee Moore\PA_Study_2018\data\Raw";
libname derived "Q:\Jesse Chittams\Renee Moore\PA_Study_2018\data\Derived";
footnote "Q:\Jesse Chittams\Renee Moore\PA_Study_2018\programs\Draft\importing from excel xlsx.sas";




/*EXAMPLE*/
/*proc import datafile = "Q:\Jesse Chittams\Renee Moore\PA_Study_2018\data\Raw\xmls\12267_9 24 18.xlsx"*/
/*DBMS = xlsx OUT = nr151_0020 replace;*/
/*SHEET="Hourly" ;*/
/*run;*/

/*MACRO*/
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
             
 %mend drive;
 
/*List directory path (Not the file itself but the folder)*/
/*and the file type (xlsx)*/
/*sample*/
/*%drive(Q:\Jesse Chittams\Renee Moore\PA_Study_2018\data\Raw\xmls,xlsx); */
/*PROC PRINT DATA = DSN1;*/
/*RUN;*/

/*Week 2 All Classes*/
%drive(Q:\Jesse Chittams\Renee Moore\PA_Study_2018\data\Raw\daily accelerometer\wk2,xlsx); 
PROC PRINT DATA = DSN1;
RUN;

/*SET THE DATA TABLES ON TOP OF EACH OTHER TO CREATE THE PERMANENT SAS DATA SET*/
data raw.accelerometer_daily_wk2;
set dsn1 - dsn761;
classroom=SUBSTR(Subject, 1, 3);
week=2;
time_n = time*1;
school_day_wear_percent=time_n*100/390 ;
if school_day_wear_percent >= 80 then Valid_school_day_wear = 1;
if school_day_wear_percent <  80 then Valid_school_day_wear = 0;
if school_day_wear_percent =  .   then Valid_school_day_wear = .;
run;


proc contents data=raw.accelerometer_daily_wk2 varnum;run;


/*QA school_day_wear_percent Valid_school_day_wear*/
proc freq data= raw.accelerometer_daily_wk2;
tables time_n*school_day_wear_percent*Valid_school_day_wear  /list missing;
run;

/*QA time_n*/
proc freq data= raw.accelerometer_daily_wk2;
tables time*time_n /list missing;
run;


/*QA classroom*/
proc freq data= raw.accelerometer_daily_wk2;
tables subject*classroom /list missing;
run;


/*Action Items 12/23/2018*/

/*Import all accelerometer data on box*/
/*put sedentary in the var statement*/
/*put class in the by*/
/*consolidated output*/
/*ask for proc mean std iqr n min max*/

/*create rtf email to Jesse and place in meetings folder on drive*/

/*Listen to "Q:\Jesse Chittams\Renee Moore\PA_Study_2018\recordings\2018-11-12 11.08 PASS DATA TEAM Meeting.mp4"*/
/*to confirm that the correct variable was selected*/

/*Email Blessing that the REDCap forms are available and ask for feedback*/
/*copy Jesse and Julie*/

ods pdf file="Q:\Jesse Chittams\Renee Moore\PA_Study_2018\documents\output\Daily Accelerometer Week 2 &sysdate..pdf" style=journal;
/*Rough Summary Stats*/
options ls=120 orientation=landscape;
proc means data=raw.accelerometer_daily_wk2 maxdec=2 n nmiss min max mean std median qrange;
class classroom;
var Number_of_Sedentary_Bouts_occurr;
run;
ods pdf close;

ods pdf file="Q:\Jesse Chittams\Renee Moore\PA_Study_2018\documents\output\Daily Accelerometer Week 2 Summary Stats on time worn &sysdate..pdf" style=journal;
/*Rough Summary Stats*/
options ls=120 orientation=landscape;
proc means data=raw.accelerometer_daily_wk2 maxdec=2 n nmiss min max mean std median qrange;
class classroom;
var time_n school_day_wear_percent;
run;

proc freq data= raw.accelerometer_daily_wk2 ;
table classroom*Valid_school_day_wear / nopercent nocol;
run;
ods pdf close;

proc print data=raw.accelerometer_daily_wk2 (obs=20);
var time;
run;

/*clean time (make it numeric)*/
/*Use time * 100/390 to create % time worn in Minutes (assuming all schools have a */
/*total time of 6.5 hours*/

/*Do a proc means on the time and % time worn variables*/
/*review the recording to confirm that Number_of_Sedentary_Bouts_occurr is correct*/

/*Create a freq on Valid_school_day_wear */
/*proc freq data= ;*/
/*table classroom*Valid_school_day_wear / nopercent nocol;*/
/*run;*/

/*Add to data step above*/
/*if % >= 80% then Valid_school_day_wear = 1*/
/*if % <  80% then Valid_school_day_wear = 0*/
/*if % =  .   then Valid_school_day_wear = .*/


proc contents data=raw.accelerometer_daily_wk2;run;
