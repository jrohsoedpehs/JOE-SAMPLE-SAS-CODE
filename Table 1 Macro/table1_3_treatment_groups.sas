libname raw "dir\Raw";
libname derived "Q:\Jesse Chittams\admin\Joseph Rhodes\Notes\SAS\Experience\data\Derived";

footnote "SAS Program Stored in: dir\Table_1_Summary_Stats.sas";

/*FORMATS*/
/*options fmtsearch=();*/
options nofmterr;

proc format;
value type_ 
1 = "Hybrid"
2 = "SUV"
3 = "Sedan"
4 = "Sports"
5 = "Truck"
6 = "Wagon"
;

value DriveTrain_
1 = "Front"
2 = "Rear"
3 = "All"
;
run;

/***************************************
Description of task
create report on type and horsepower
***************************************/
proc contents data=sashelp.cars varnum;run;
proc print data=sashelp.cars (obs=5);run;


proc freq data = sashelp.cars;
	tables DriveTrain;
run;


data demo;
set sashelp.cars ;

/*Create TRT*/
n = _n_;
/*remainder division by 2*/
/*add 1 to shift range from 0-2 to 1-3*/
trt = mod(n,3)+1;

/*Don't apply a format to TRT*/
/*each record should have a trt*/

/*Clean category variables*/
/*skip is REDCap is used with category field type (dropdown, radio buttons)*/
if type = "Hybrid" then type_2 =  1 ;
if type = "SUV" then type_2 =  2 ;
if type = "Sedan" then type_2 =  3 ;
if type = "Sports" then type_2 =  4 ;
if type = "Truck" then type_2 =  5 ;
if type = "Wagon" then type_2 =  6 ;

if DriveTrain = "Front" then DriveTrain_2 =  1 ;
if DriveTrain = "Rear" then DriveTrain_2 =  2 ;
if DriveTrain = "All" then DriveTrain_2 =  3 ;

run;

data derived.demo;
set demo;
run;

data demo1;
	set derived.demo;
run;

data demo;
	set demo1;
run;


proc sort data=demo1 ;
   by trt  ;
run;
proc sort data=demo;
	by trt;
run;


*data new; *run;

%include 'dir\macro_table1_3_treatment_groups.sas';

/*2 macro calls*/

/*1 for category vars*/
/*%catg(invar,label,fmt,method,order,where,datain );

/*invar = categorical variable*/
/*label = label of variable*/
/*fmt = format of categorical variable*/
/*method = FISHER or CHISQ*/
/*order =  order of appearance of stats*/
/*where = where invar ne .*/
/*datain = demo1*/

/*sample*/
%catg(type_2,Type,type_. ,fisher,1,%str(where type_2 ne .), demo1);

/*1 for num vars*/
/*%cont(invar,label,order,datain);

/*invar = numeric variable*/
/*label = label of variable*/
/*order = order of appearance of stats*/
/*datain = demo1 */

/*sample*/
%cont(horsepower,%str(Horsepower), 2,demo1);

%cont(Cylinders,%str(Cylinders), 3,demo1);

%catg(DriveTrain_2,DriveTrain,DriveTrain_. ,fisher,4,%str(where DriveTrain_2 ne .), demo1);


*checking macros above QA;
/*Macro calls are appended onto the RTF*/
/*Rerunning calls results in duplicate stats*/
/*Exit SAS to clear memory and avoid duplicate stats*/
proc print data=work.new; run;


*checking macros above QA;
proc print data=work.new; run;

 
proc freq data=demo1 noprint; 
tables trt/out=trt;  
run;
**********************************************************start here 12pm 11/6;

data trt;
set trt  ;
file print ls=130;
by trt;
retain totall;
if _n_=1 then totall=COUNT;
else  totall+COUNT; 
run;

proc print data=trt; run;

data _null_;
set trt;
select (trt);
when (1) call symput(strip("tot1"), strip(put(count,$4.)));
*when (2) call symput(strip("tot2"), strip(put(count,$4.)));
when (2) 
	do;
		call symput(strip("tot2"), strip(put(count,$4.)));
  		call symput(strip("totall"), strip(put(totall,$4.))); 
	end;
otherwise;
end; 
run; 
   option ls=130;



ods rtf file=  "dir\title  &sysdate..doc" style=journal;

/*closed report*/
/*Displays stats by trt*/
proc report data=new nowd headskip;
column order varlab cat totstats _1 _2 _3 pvalue;
break after order/skip;
define order/order noprint;
define varlab/order width=50 flow left 'Variable';
define cat/display spacing=1 width=33 left' ';
define totstats/display spacing=3 width=30 left "Total/(n=&totall)";
define _1/display spacing=1 width=30 left "PHHS/(n=&tot1)";
define _2/display spacing=1 width=30 left "VNA/(n=&tot2)";
define _3/display spacing=1 width=30 left "Group C/(n=&tot3)";
define pvalue/display spacing=1 width=30 left 'Pvalue[a]';
title1 'title';			
title3 'Closed Report';
/*compute after; */
/*line @1 "Numbers indicate the median (continuous variables) or percentage (categorical variables).Numbers in parentheses indicate the interquartile range. FG=Fasting Glucose;";*/
/*line @2 "type-2 diabetes= type 2 diabetes mellitus. Pairwise comparisons: * IFG vs. normal FG.† type-2 diabetes vs. normal FG. ‡ type-2 diabetes vs. IFG."; */
/*line @3 "§ Statistical comparisons of cardiac output, stroke volume and SVR are adjusted for BSA."; */
/*endcomp;*/
run;
ods rtf close;





*ods rtf file= "Q:\George Demiris\PISCES\documents\output\Basic Demographic Information for Study Participants &sysdate..doc" style=journal;

*   option ls=130;
*proc report data=new nowd headskip;
*column order varlab cat totstats ;
*break after order/skip;
*define order/order noprint;
*define varlab/order width=50 flow left 'Variable';
*define cat/display spacing=1 width=33 left' ';
*define totstats/display spacing=3 width=30 left "Total/(n=&totall)";
/*define _1/display spacing=1 width=30 left "Group A/(n=&tot1)";*/
/*define _2/display spacing=1 width=30 left "Group B/(n=&tot2)";*/
/*define _3/display spacing=1 width=30 left "Group C/(n=&tot3)";*/
*define pvalue/display spacing=1 width=30 left 'Pvalue[a]';
/*title 'Open Report';*/
/*title2 'Table 1';			*/
*title3 'Basic Demographic Information for Study Participants';
/*compute after; */
/*line @1 "Numbers indicate the median (continuous variables) or percentage (categorical variables).Numbers in parentheses indicate the interquartile range. FG=Fasting Glucose;";*/
/*line @2 "type-2 diabetes= type 2 diabetes mellitus. Pairwise comparisons: * IFG vs. normal FG.† type-2 diabetes vs. normal FG. ‡ type-2 diabetes vs. IFG."; */
/*line @3 "§ Statistical comparisons of cardiac output, stroke volume and SVR are adjusted for BSA."; */
/*endcomp;*/
*run;
*ods rtf close;




/*QA Final Measures*/
proc freq data=demo;
tables caregiver_id*final_measures/list missing;
run;

proc print data=demo;
where final_measures=2;
run;

