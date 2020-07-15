/*CONVERT CHAR DATETIME TO NUM DATE WITH FORMAT*/
data dsn2;
set dsn1
date_clean = Input(Scan(date,1,' '),YYMMDD10.);
run;



/*CONVERT NUM DATETIME TO DATE*/
/*CONVERT DATE TO YEAR*/

libname raw "Q:\Jesse Chittams\Renee Moore\PA_Study_2018\data\Raw";
libname derived "Q:\Jesse Chittams\Renee Moore\PA_Study_2018\data\Derived";
footnote "SAS Program Stored in Q:\Jesse Chittams\Renee Moore\PA_Study_2018\programs\Draft\Table Shell Health.sas";

data derived.health_4th_grade;
    set raw.health_4th_grade;
/*CONVERT DATETIME TO DATE*/
	FGTestDate_datepart = DATEPART(FGTestDate); 
/*CONVERT DATE TO YEAR*/
    FGTestDate_year = Year(FGTestDate_datepart);
    format BMIHFZ BMIHFZ_. AerobicCapacityHFZ AerobicCapacityHFZ_.;
run;

proc contents data= derived.health_4th_grade ;
run;

proc print data = derived.health_4th_grade (obs=50);
var FGTestDate ;
run;

proc freq data=derived.health_4th_grade (obs=50);
    tables FGTestDate_datepart * FGTestDate / list missing;
run;

proc freq data=derived.health_4th_grade (obs=50);
    tables FGTestDate_year * FGTestDate_datepart / list missing;
run;
