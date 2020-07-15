/*F. Calculating Area under the Curve*/

/*  
USING SAS TO CALCULATE AREA UNDER THE CURVE FOR OUTCOMES MEASURED OVER TIME (VAS ratings)
	You can copy this program directly into SAS and change the variable names and number of time points.

This process has three steps:
1: Convert the format of the VAS data to one time point and VAS rating per SAS observation.
	This gives multiple VAS observations for each experimental condition.
2: Use PROC EXPAND to calculate the area under each segment of the graph.
3: Convert the area values back to a single SAS observation per condition.

Note that SAS interpolates missing data which is between endpoints of the curve (by connecting 
the adjacent points), but a missing endpoint produces a missing value for the entire observation. 

Step 1: Convert the data from multivariate to univariate format using temporary arrays; be sure 
not to give an array the same name as an existing variable. First sort the data by the 
identifying variables (id, cond). In the following example, there are 8 time points and 5 existing VAS 
ratings named Hung1 to Hung8, Thir1 to Thir8, and similarly for Much, Naus, and Full.
*/
 /*http://support.sas.com/documentation/cdl/en/etsug/63348/HTML/default/viewer.htm#etsug_expand_sect017.htm*/
******************************************************************************************************************************************************************

																			LIBRARY REFERENCES
******************************************************************************************************************************************************************;

libname raw "U:\Tanja Kral\energy_intake_study_spring_2014\data\raw";
libname scored "U:\Tanja Kral\energy_intake_study_spring_2014\data\Derived";
libname alias "U:\Tanja Kral\energy_intake_study_spring_2014\data\raw";

*******************************************************************************************************************************************************************
														OPTIONS/MACRO VARIABLES: RUN THIS CODE FOR UNIFOMITY PURPOSE
*******************************************************************************************************************************************************************;

options nofmterr nodate orientation=landscape;
%let today = %sysfunc (today(),mmddyyn);

*******************************************************************************************************************************************************************
														STANDARD FOOTNOTES: RUN THIS CODE FOR UNIFORMITY PUROSE
*******************************************************************************************************************************************************************;

footnote1 j=left height=6pt 'SAS Program Stored: U:\Jesse Chittams\Tanja Kral\energy_intake_study_spring_2014\programs\Draft\auc.sas';


PROC SORT data= raw.vas out= alias.VASfile;		/* This is your original data file of VAS ratings  */
BY id cond;
RUN; 

proc print data=alias.vasfile (obs = 20); run;
proc print data=alias.vastime (obs = 20); run;


DATA alias.VAStime;		/* Create a new datafile to use in PROC EXPAND */
SET  alias.VASfile;		/* Create arrays, listing the existing VAS variables in chronological order */ 

     /* Specify the gap between the time points in hours or decimal parts of an hour. */
     if      Time = 1  then Hour = 0.00;
     else if Time = 2  then Hour = 0.30; 
     else if Time = 3  then Hour = 2.00;
     else if Time = 4  then Hour = 2.50;
     else if Time = 5  then Hour = 3.67;
     else if Time = 6  then Hour = 3.87;
     else if Time = 7  then Hour = 4.00;
     else if Time = 8  then Hour = 4.50;
	Hung = HUNGRY; thir =   THIRSTY;  Naus = NAUSEA;
KEEP Id Cond /*Week*/ Time Hour Hung Thir Much Naus Full;
LABEL Time = "VAS time point"  Hour = "Time after breakfast (hours)";
RUN;







proc print data = alias.VAStime;
where ID in (911,916);
run;

/* Step 2: Instruct SAS to calculate the area under each part of the curve created by joining the 
data points with line segments. (The data must be arranged in chronological order by the time 
variable, but this will be the case if you used the arrays above.)  The output is a data file 
with a set of new variables, each of which contain the area for the single interval FOLLOWING the 
given time point. SAS includes a superfluous area following the final interval for each 
observation, which MUST BE EXCLUDED FROM THE DATA. */
 
PROC SORT data=alias.VAStime;		/* This is your original data file of VAS ratings  */
BY id cond hour;
RUN; 


PROC EXPAND DATA=alias.VAStime OUT=AUC METHOD=JOIN;	  /* Create a new temporary datafile AUC */
BY id cond hour ;
ID Hour;						  /*  Be sure to use Hour not Time here  */
CONVERT Hung = HungAUC / OBSERVED = (BEGINNING, TOTAL) ;
CONVERT Thir = ThirAUC / OBSERVED = (BEGINNING, TOTAL) ;
CONVERT Much = MuchAUC / OBSERVED = (BEGINNING, TOTAL) ;
CONVERT Naus = NausAUC / OBSERVED = (BEGINNING, TOTAL) ;
CONVERT Full = FullAUC / OBSERVED = (BEGINNING, TOTAL) ;
RUN;

proc print data=auc (obs=20); where id = 911; run;

* Step 3: Use arrays to convert the AUC data from univariate back to multivariate format ;

proc contents data=alias.vastime;
run;

proc contents data=auc;
run;

proc freq data=auc;
	tables cond /list missing;
run;

PROC SORT DATA = AUC;
BY id cond time; RUN;

proc print data=auc (obs=20);
run;

proc means data=auc SUM;
	class id cond;
	var hungauc;
run;


DATA AUC2;		      			/* Create a new multivariate dataset containing the adjacent areas */
SET AUC;
BY id cond time;
ARRAY huAUC[8] HungAUC1-HungAUC8;   /* Create new multivariate AUC variables */
ARRAY thAUC[8] ThirAUC1-ThirAUC8;   /* Note the use of the single dash shortcut to create them */
ARRAY muAUC[8] MuchAUC1-MuchAUC8;
ARRAY naAUC[8] NausAUC1-NausAUC8;
ARRAY fuAUC[8] FullAUC1-FullAUC8;

/*  RETAIN the values until the output statement is reached  */
RETAIN HungAUC1-HungAUC8 ThirAUC1-ThirAUC8 MuchAUC1-MuchAUC8 NausAUC1-NausAUC8 FullAUC1-FullAUC8;
 
/*  Set the new variables to missing at the start of each observation. This protects against 
retaining variables from the previous observation when a missing value is encountered.*/
IF FIRST.cond THEN DO I=1 to 8; HuAUC[I]=.; ThAUC[I]=.; muAUC[I]=.; NaAUC[I]=.; FuAUC[I]=.;
END;

HuAUC[time] = HungAUC;
ThAUC[time] = ThirAUC;
MuAUC[time] = MuchAUC;
NaAUC[time] = NausAUC;
FuAUC[time] = FullAUC;                  
IF LAST.cond THEN OUTPUT;

/*  Be sure to discard last area; you should have one less area than the number of time points */
KEEP id cond HungAUC1-HungAUC7 ThirAUC1-ThirAUC7 MuchAUC1-MuchAUC7 NausAUC1-NausAUC7 
	FullAUC1-FullAUC7;
FORMAT Hungauc1--Fullauc7  8.1;
LABEL  HungAUC1  = 'Hunger from before to after breakfast';
RUN; 

proc print data=auc2 (obs=10);
run;

Data alias.AUC; 			/* Create a permanent dataset containing the areas of interest */
set  AUC2;				
if Hungauc7 lt 0 then Hungauc7 = .;	*Negative final areas may result from missing curve endpoints;
* repeat above command for all final areas: Thirauc7, Muchauc7, Nausauc7, Fullauc7;
/*  Add up the areas of interest; for N time points you should have N-1 areas */
HungTot  = Hungauc1 + Hungauc2 + Hungauc3 + Hungauc4 + Hungauc5 + Hungauc6 + Hungauc7 ;
ThirTot  = Thirauc1 + Thirauc2 + Thirauc3 + Thirauc4 + Thirauc5 + Thirauc6 + Thirauc7 ;
MuchTot  = Muchauc1 + Muchauc2 + Muchauc3 + Muchauc4 + Muchauc5 + Muchauc6 + Muchauc7 ;
NausTot  = Nausauc1 + Nausauc2 + Nausauc3 + Nausauc4 + Nausauc5 + Nausauc6 + Nausauc7 ;
FullTot  = Fullauc1 + Fullauc2 + Fullauc3 + Fullauc4 + Fullauc5 + Fullauc6 + Fullauc7 ;
Hung3to6 = Hungauc3 + Hungauc4 + Hungauc5 + Hungauc6  ;
Full3to6 = Fullauc3 + Fullauc4 + Fullauc5 + Fullauc6  ;
FORMAT Hungauc1--Fullauc7  HungTot--FullTot Hung3to6--Full3to6 8.1;
run;
* Use this file to analyze the AUC values as a summary outcome for the entire time period.;

/*QA*/
proc print data=alias.AUC (OBS=20); 
	var id cond hungtot;
run;
