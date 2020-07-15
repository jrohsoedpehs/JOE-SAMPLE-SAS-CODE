* Aim: To generate AUC for glucose variable;

libname raw 'Q:\Kimberly Trout\iPRO_2017\data\raw'; 
libname derived 'Q:\Kimberly Trout\iPRO_2017\data\derived'; 
footnote "Q:\Kimberly Trout\iPRO_2017\programs\Draft\Plots of data and correlations for abstract March 2018.sas"; 
/*proc import file="Q:\Kimberly Trout\iPRO_2017\data\Raw\Master Assay File iPRO complete 02_21_18.xlsx"*/
/*dbms=xlsx out=derived.assay_complete3; */
/*run;*/

proc freq data=derived.assay_complete2;
table GLU_YSI_;
run;

proc contents data=raw.ipro_ysi;
run;

proc means data=derived.assay_complete2;
	var COR__g_dl FFA__mM_ GLU_YSI_ INS_uIU_ml;
run;

proc print data=derived.assay_complete2 (obs=50);
run;


*2/28/2018
Browsing through the code
Checking variable types ;


data assay2;
	set raw.Assay_03_05_18;
	where subj_sample ne " ";
	subj_sample_2 = translate(subj_sample,'-',' ');
	subj_id = scan(subj_sample_2, 1, "-");
	visit1 = scan(subj_sample_2, 3, "-");
	visit = 1*visit1;
	subj_id1 = subj_id*1; 
	time = scan(subj_sample_2, 4, "-");
	time_int = time*1;
	if (1 < time_int < 6) or (14 < time_int < 19) then meal = "breakfast";
	else if (5 < time_int < 10) or (18 < time_int < 23) then meal = "lunch";
	else if (9 < time_int < 14) or (22 < time_int < 25) then meal = "dinner";
	else meal = "baseline";

	if time_int in (2, 6, 10, 15, 19, 23) then time_val = 30;
	else if time_int in (3, 7, 11, 16, 20, 24) then time_val = 60;
	else if time_int in (4, 8, 12, 17, 21) then time_val = 120;
	else if time_int in (5, 9, 13, 18, 22) then time_val = 180;
	else time_val = 0;
	INS_uIU_ml_n =  INS_uIU_ml*1; 
run;

proc contents data=assay2; run;


*******************************************************************************************************;
* Assess the general association and and plots among the various outcomes 
*******************************************************************************************************;

Proc corr  data = assay2 pearson spearman;
var FFA__mM_ COR_ug_dl INS_uIU_ml_n GLU_YSI_ GLU_ACU GLU_CGM ;
title 'Correlation among observations at the individual item level';
run;

proc sort data = assay2;  
	by subj_id ;
run;

proc means data = assay2 noprint;
	by subj_id ; 
	var FFA__mM_ COR_ug_dl INS_uIU_ml_n GLU_YSI_ GLU_ACU GLU_CGM ;
	output out=derived.mean_assay2 mean=FFA__mM_ COR_ug_dl INS_uIU_ml_n GLU_YSI_ GLU_ACU GLU_CGM ;
run;
 
ods rtf file="Q:\Kimberly Trout\iPRO_2017\documents\output\correlations among outcome variables &sysdate..doc" style=minimal;
Proc corr  data = derived.mean_assay2 pearson spearman;
var FFA__mM_ COR_ug_dl INS_uIU_ml_n GLU_YSI_ GLU_ACU GLU_CGM ;
title 'Correlation among observations at the individual patient level';
run;
ods rtf close;


footnote;

%macro grapovl(x,y,titl,lab1,lab2);
proc gplot data=derived.mean_assay2;
		symbol1 i=rl value=dot l=1 w=5 c=black;  
		axis1 label = (c=Black a = 90 f=swissl h=2 " &lab1 ");
		axis2 label = (c=Black  f=swissl h=2 " &lab2 ");  
		plot  &y*&x/  vaxis=axis1 haxis=axis2; 
		Title1 h=2.5 "&lab1 vs &lab2"; 
		
	run;
quit; title1; title2;title3 ; 
%mend;

ods rtf file="Q:\Kimberly Trout\iPRO_2017\documents\output\Patient  level correlation plots of outcomes &sysdate..doc" style=minimal;
%grapovl(GLU_YSI_,GLU_ACU, , Glucose YSI (mg/dL), Glucose ACU (mg/dL));
%grapovl(GLU_YSI_,GLU_CGM, , Glucose YSI (mg/dL), Glucose CGM (mg/dL)); 
ods rtf close;

%grapovl(GLU_YSI_,FFA__mM_, , Glucose YSI, FFA (mM));
%grapovl(GLU_YSI_,INS_uIU_ml_n , , Glucose YSI, Insulin);
%grapovl(GLU_YSI_,GLU_ACU, , Glucose YSI, GLU ACU);
%grapovl(GLU_YSI_,COR_ug_dl, , Glucose YSI, COR ug dl);
ods rtf close;





proc sort data=assay2;
where subj_id ne " ";
by subj_id1 visit time_int;
run;
 
*Add treatment schedule to AUC data;
data tx;
	set derived.treatments;
	visit = cycle;
	subj_id1 = subject_id*1; 
	drop cycle subject_id;
run;
 
proc sort data=tx;
	by subj_id1 visit;
run;

data derived.plotsdata;
	merge assay2(in=in1) tx(in=in2);
	by subj_id1 visit;
	if in1; 
run;

proc print ;
run;

proc sort data=derived.plotsdata;
by   time_int meal time_val; 
run;


proc means data=derived.plotsdata noprint;
by   time_int meal time_val; 
var FFA__mM_ COR_ug_dl INS_uIU_ml_n GLU_YSI_ GLU_ACU GLU_CGM ;
output out=mean_assay2 mean=FFA__mM_ COR_ug_dl INS_uIU_ml_n GLU_YSI_ GLU_ACU GLU_CGM ;
run;
 
proc print data=mean_assay2 noobs;
var time_int meal time_val; 
run;

/*proc format;*/
/*value  timeint */
/*1	 =	 'baseline 0'*/
/*2	 =	 'breakfast	30'*/
/*3	 =	 'breakfast	60'*/
/*4	 =	 'breakfast	120'*/
/*5	 =	 'breakfast	180'*/
/*6	 =	 'lunch	30'*/
/*7	 =	 'lunch	60'*/
/*8	 =	 'lunch 120'*/
/*9	 =	 'lunch	180'*/
/*10	 =	 'dinner 30'*/
/*11	 =	 'dinner 60'*/
/*12	 =	 'dinner 120'*/
/*13	 =	 'dinner 180'*/
/*14	 =	 'Day2 baseline	0'*/
/*15	 =	 'breakfast	30'*/
/*16	 =	 'breakfast	60'*/
/*17	 =	 'breakfast	120'*/
/*18	 =	 'breakfast	180'*/
/*19	 =	 'lunch	30'*/
/*20	 =	 'lunch	60'*/
/*21	 =	 'lunch 120'*/
/*22	 =	 'lunch	180'*/
/*23	 =	 'dinner 30'*/
/*24	 =	 'dinner 60'*/
/*;*/
/*run;*/


%macro grapov2(x,y,titl,lab1,lab2);
proc gplot data=mean_assay2;
		symbol1 i=spline value=circle l=1 w=4 c=black h=2;
		*symbol2 i=none value=circle l=3 c=black;
		symbol2 i=spline value=square l=1 w=4 c=gray h=2;
		*symbol4 i=none value=square l=2 c=gray;
		axis1 label = (c=Black a = 90 f=swissl h=1.5 " &lab1 ");
		axis2 label = (c=Black  f=swissl h=2 'Time(Min)')order = 1 to 28 by 4;
		*where hours < 100;
		axis3 label = (c=gray a = 90 f=swissl h=1.5 " &lab2 ");
		plot  &y*time_int/ overlay vaxis=axis1 haxis=axis2;
		plot2  &x*time_int / overlay vaxis=axis3;
		Title1;
		title2;
		title3;
		format time_int timeint.;
	run;
quit; title1; title2; title3;
%mend;


/*ods rtf file="Q:\Kimberly Trout\iPRO_2017\documents\output\Glucose YSI vs FFA &sysdate..doc" style=minimal;*/
ods rtf file="Q:\Kimberly Trout\iPRO_2017\documents\output\Overlay plots of outcomes across time &sysdate..doc" style=minimal;
%grapov2(GLU_YSI_,FFA__mM_, , Glucose YSI, FFA (mM));
%grapov2(GLU_YSI_,INS_uIU_ml_n, , Glucose YSI, INS_uIU_ml_n);
%grapov2(GLU_YSI_,COR_ug_dl, , Glucose YSI, COR ug dl);
ods rtf close;

****************************************************************************************************;
*****************|             Plot Treatment A vs. B     ********;
****************************************************************************************************;
proc contents data=derived.plotsdata; run;

proc sort data=derived.plotsdata;
	by treatment time_int meal time_val ; 
run;

proc means data=derived.plotsdata noprint;
by   treatment time_int meal time_val ; 
var FFA__mM_ COR_ug_dl INS_uIU_ml_n GLU_YSI_ GLU_ACU GLU_CGM ;
output out=derived.mean_assay3(drop=_type_ _freq_) mean=mean_FFA__mM_ mean_COR_ug_dl mean_INS_uIU_ml_n	mean_GLU_YSI_ mean_GLU_ACU	mean_GLU_CGM	
stderr = stderr_FFA__mM_	stderr_COR_ug_dl	stderr_INS_uIU_ml_n	stderr_GLU_YSI_	stderr_GLU_ACU	stderr_GLU_CGM;
run;
 
/*proc sort data = derived.table2_final4; by physposta visit_no; run;*/
/*proc means data = derived.table2_final4 noprint;*/
/*	by physposta visit_no;*/
/*	var _zac _zts _zss _zbmi _zlen o_zhc;*/
/*	output out = derived.who_means (drop=_type_ _freq_) mean=mean_zac mean_zts mean_zss mean_zbmi mean_zlen mean_zhead stderr=stderr_zac stderr_zts stderr_zss stderr_zbmi stderr_zlen stderr_zhead std = std;*/
/*run; */

data derived.reshape;
	set derived.mean_assay3;
	by   treatment time_int meal time_val ;

   if treatment="A" then time_int=time_int - 0.08;                                                                                               
   if treatment="B" then time_int=time_int + 0.08;
/*   if physposta=3 then visit_no=visit_no;  */

	yvar_FFA__mM_ = mean_FFA__mM_;
output;

yvar_COR_ug_dl = mean_COR_ug_dl;
output;

yvar_INS_uIU_ml_n = mean_INS_uIU_ml_n;
output;

yvar_GLU_YSI_ = mean_GLU_YSI_;
output;
yvar_GLU_ACU = mean_GLU_ACU;
output;
yvar_GLU_CGM = mean_GLU_CGM;
	output;

	yvar_FFA__mM_ = mean_FFA__mM_ - stderr_FFA__mM_;
output;
yvar_COR_ug_dl = mean_COR_ug_dl - stderr_COR_ug_dl;
output;
yvar_INS_uIU_ml_n = mean_INS_uIU_ml_n - stderr_INS_uIU_ml_n;
output;
yvar_GLU_YSI_ = mean_GLU_YSI_ - stderr_GLU_YSI_;
output;
yvar_GLU_ACU = mean_GLU_ACU - stderr_GLU_ACU;
output;
yvar_GLU_CGM = mean_GLU_CGM - stderr_GLU_CGM;
	output;

	yvar_FFA__mM_  = mean_FFA__mM_ + stderr_FFA__mM_;
output;
yvar_COR_ug_dl  = mean_COR_ug_dl + stderr_COR_ug_dl;
output;
yvar_INS_uIU_ml_n  = mean_INS_uIU_ml_n + stderr_INS_uIU_ml_n;
output;
yvar_GLU_YSI_ = mean_GLU_YSI_ + stderr_GLU_YSI_;
output;
yvar_GLU_ACU = mean_GLU_ACU + stderr_GLU_ACU;
output;
yvar_GLU_CGM = mean_GLU_CGM + stderr_GLU_CGM;
	output;

label yvar_FFA__mM_ = "FFA mM";
label yvar_COR_ug_dl = "Triceps Skinfold-for-age z score";
label yvar_INS_uIU_ml_n = "Subscapular skinfold-for-age z score";
label yvar_GLU_YSI_ = "BMI-for-age z-score";
label yvar_GLU_ACU = "Length/height-for-age z-score";
label yvar_GLU_CGM = "Head circumference-for-age z-score";
label time_int = "Visit age in months";
run;


proc format;
value  timeint 
0    =   '     '
1	 =	 'Fasting'
2	 =	 'B	30'
3	 =	 'B	60'
4	 =	 'B	120'
5	 =	 'B	180'
6	 =	 'L	30'
7	 =	 'L	60'
8	 =	 'L 120'
9	 =	 'L	180'
10	 =	 'D 30'
11	 =	 'D 60'
12	 =	 'D 120'
13	 =	 'D 180'
14	 =	 ' '
15	 =	 'B	30'
16	 =	 'B	60'
17	 =	 'B	120'
18	 =	 'B	180'
19	 =	 'L 30'
20	 =	 'L	60'
21	 =	 'L 120'
22	 =	 'L	180'
23	 =	 'D 30'
24	 =	 'D 60'
25   =  '  '
;
value $Tx
"A" = "iPRO30%/CHO35%"
"B" = "LPRO15%/CHO50%"
;
run;

%macro gplot(yvar,mean, lab);
goptions reset=all cback=white border htext=12pt htitle=14pt;

/* Define the axis characteristics */                                                                                                   
   *axis1 offset=(0,0) minor=none;
  axis1 label = (c=Black  f=swissl h=2 'Time(Min)')order = 0 to 14 by 1 value=(h=1 F=SWISS);                                                                                                       
  axis2 label = (c=Black a = 90 f=swissl h=2 " &lab");                                                                                                                   
                                                                                                                                        
/* Define the symbol characteristics */                                                                                                 
   symbol1 interpol=hiloctj color=blue line=1 w=3 MODE=INCLUDE;                                                                                          
   symbol2 interpol=hiloctj color=red line=1 w=3 MODE=INCLUDE;                      
/*   symbol3 interpol=hiloctj color=green line=1 w=3; */

   *symbol4 interpol=none color=blue value=dot height=1.6;
   *symbol5 interpol=none color=red value=dot height=1.6;
/*   symbol6 interpol=none color=green value=dot height=1.6; */
                                                                                                                                        
/* Define the legend characteristics */                                                                                                 
   legend1 label=('Tx:') frame;                                                                                                      
                                                                                                                                        
/* Plot the error bars using the HILOCTJ interpolation */                                                                               
/* and overlay symbols at the means. */                                                                                                 

 proc gplot data=derived.reshape;  
	where time_int < 13.5; 
   plot &yvar*time_int=treatment / haxis=axis1 vaxis=axis2 legend=legend1;                                                                    
    *plot2 &mean*time_int=treatment / /*vaxis=axis2*/ noaxis nolegend; 
format time_int timeint. treatment $Tx.; 
run;                                                                                                                                    
quit;                 
%mend gplot; 
           
proc print data=derived.reshape (obs=50);
run;

ods pdf file= "Q:\Sharon Irving\Anthroplus\documents\Reports\ZScore_Plots_Means with stderr bars overall &sysdate..pdf" style=journal;
options orientation = landscape;
options nodate;

ods rtf file="Q:\Kimberly Trout\iPRO_2017\documents\output\Day 1 Plot of FFA__mM_ Overlay trt A vs B Day 1 Plots of outcomes across time &sysdate..doc" style=minimal;
%gPlot(yvar_FFA__mM_, mean_FFA__mM_ , FFA mM );
ods rtf close;

ods rtf file="Q:\Kimberly Trout\iPRO_2017\documents\output\Day 1 Plot of COR ugdl Overlay trt A vs B Day 1 Plots of outcomes across time &sysdate..doc" style=minimal;
%gPlot(yvar_COR_ug_dl, mean_COR_ug_dl , COR (ug/dL) );
ods rtf close;

ods rtf file="Q:\Kimberly Trout\iPRO_2017\documents\output\Day 1 Plot  of INSULIN uIU mln Overlay trt A vs B Day 1 Plots of outcomes across time &sysdate..doc" style=minimal;
%gPlot(yvar_INS_uIU_ml_n, mean_INS_uIU_ml_n, INSULIN uIU ml/n); 
ods rtf close;

ods rtf file="Q:\Kimberly Trout\iPRO_2017\documents\output\Day 1 Plot of GLU YSI Overlay trt A vs B Day 1 Plots of outcomes across time &sysdate..doc" style=minimal;
%gplot(yvar_GLU_YSI_, mean_GLU_YSI_ , GLUCOSE YSI (mg/dL));
ods rtf close;

/*ods rtf file="Q:\Kimberly Trout\iPRO_2017\documents\output\Plot of GLU ACU Overlay trt A vs B plots of outcomes across time &sysdate..doc" style=minimal;*/
/*%gplot(yvar_GLU_ACU, mean_GLU_ACU, GLUCOSE ACU (mg/dL));*/
/*ods rtf close;*/
/**/
/*ods rtf file="Q:\Kimberly Trout\iPRO_2017\documents\output\Plot of GLU CGM Overlay trt A vs B plots of outcomes across time &sysdate..doc" style=minimal;*/
/*%gplot(yvar_GLU_CGM, mean_GLU_CGM, GLUCOSE CGM (mg/dL));*/
/*ods rtf close;*/




*ods rtf file='c:\cclark02\biostats\archive\request051304\no_ran_slope_int.rtf' style=minimal;
%macro grapovl(x,y,lab1);
proc gplot data=derived.mean_assay3;
	axis1 label = (c=Black a = 90 f=swissl h=2 " &lab1");
		axis2 label = (c=Black  f=swissl h=2 'Time(Min)')order = 1 to 24 by 2 value=(h=1 F=SWISS);
 	symbol1 i=join value=circle l=1 w=4 h=1.5 c=blue; 
	symbol2 i=join value=square l=1 w=4 h=1.5 c=red; 
	plot  &y*time_int=treatment/   vaxis=axis1 haxis=axis2;  
	format time_int timeint.;
	run;
quit; title1; title2;
%mend;

ods rtf file="Q:\Kimberly Trout\iPRO_2017\documents\output\Plot of Glucose YSI Overlay trt A vs B plots of outcomes across time &sysdate..doc" style=minimal;
%grapovl( ,GLU_YSI_, Glucose mg/dL  ); 
ods rtf close;

ods rtf file="Q:\Kimberly Trout\iPRO_2017\documents\output\Plot of INS_uIU_ml_n Overlay trt A vs B plots of outcomes across time &sysdate..doc" style=minimal;
%grapovl( ,INS_uIU_ml_n, INS uIU ml n  ); 
ods rtf close;


ods rtf file="Q:\Kimberly Trout\iPRO_2017\documents\output\Plot of FFA__mM_ Overlay trt A vs B plots of outcomes across time &sysdate..doc" style=minimal;
%grapovl( ,FFA__mM_, FFA mM  ); 
ods rtf close;


axis2 label = (c=black f=swissb h=1.5) minor=none
 value=(h=1 F=SWISSB);





 /**************Day 2 **************/
proc format;
value  timeint 
0    =   '     '
1	 =	 'Fasting'
2	 =	 'B	30'
3	 =	 'B	60'
4	 =	 'B	120'
5	 =	 'B	180'
6	 =	 'L	30'
7	 =	 'L	60'
8	 =	 'L 120'
9	 =	 'L	180'
10	 =	 'D 30'
11	 =	 'D 60'
12	 =	 'D 120'
13	 =	 '     '
14	 =	 'Fasting'
15	 =	 'B	30'
16	 =	 'B	60'
17	 =	 'B	120'
18	 =	 'B	180'
19	 =	 'L 30'
20	 =	 'L	60'
21	 =	 'L 120'
22	 =	 'L	180'
23	 =	 'D 30'
24	 =	 'D 60'
25   =   '  '
;
value $Tx
"A" = "iPRO30%/CHO35%"
"B" = "LPRO15%/CHO50%"
;
run;


 %macro gplot(yvar,mean, lab);
goptions reset=all cback=white border htext=12pt htitle=14pt;

/* Define the axis characteristics */                                                                                                   
   *axis1 offset=(0,0) minor=none;
  axis1 label = (c=Black  f=swissl h=2 'Time(Min)')order = 13 to 25 by 1 value=(h=1 F=SWISS);                                                                                                       
  axis2 label = (c=Black a = 90 f=swissl h=2 " &lab");                                                                                                                   
                                                                                                                                        
/* Define the symbol characteristics */                                                                                                 
   symbol1 interpol=hiloctj color=blue line=1 w=3 MODE=INCLUDE;                                                                                          
   symbol2 interpol=hiloctj color=red line=1 w=3 MODE=INCLUDE;                      
/*   symbol3 interpol=hiloctj color=green line=1 w=3; */

   *symbol4 interpol=none color=blue value=dot height=1.6;
   *symbol5 interpol=none color=red value=dot height=1.6;
/*   symbol6 interpol=none color=green value=dot height=1.6; */
                                                                                                                                        
/* Define the legend characteristics */                                                                                                 
   legend1 label=('Tx:') frame;                                                                                                      
                                                                                                                                        
/* Plot the error bars using the HILOCTJ interpolation */                                                                               
/* and overlay symbols at the means. */                                                                                                 

 proc gplot data=derived.reshape;  
	where time_int > 14.5; 
   plot &yvar*time_int=treatment / haxis=axis1 vaxis=axis2 legend=legend1;                                                                    
    *plot2 &mean*time_int=treatment / /*vaxis=axis2*/ noaxis nolegend; 
format time_int timeint. treatment $Tx.; 
run;                                                                                                                                    
quit;                 
%mend gplot; 
           
proc print data=derived.reshape (obs=50);
run;

ods pdf file= "Q:\Sharon Irving\Anthroplus\documents\Reports\ZScore_Plots_Means with stderr bars overall &sysdate..pdf" style=journal;
options orientation = landscape;
options nodate;

ods rtf file="Q:\Kimberly Trout\iPRO_2017\documents\output\Day 2 Plot of FFA__mM_ Overlay trt A vs B Day 1 Plots of outcomes across time &sysdate..doc" style=minimal;
%gplot(yvar_FFA__mM_, mean_FFA__mM_ , FFA mM );
ods rtf close;

ods rtf file="Q:\Kimberly Trout\iPRO_2017\documents\output\Day 2 Plot of COR ugdl Overlay trt A vs B Day 1 Plots of outcomes across time &sysdate..doc" style=minimal;
%gplot(yvar_COR_ug_dl, mean_COR_ug_dl , COR (ug/dL) );
ods rtf close;

ods rtf file="Q:\Kimberly Trout\iPRO_2017\documents\output\Day  2 Plot  of INSULIN uIU mln Overlay trt A vs B Day 1 Plots of outcomes across time &sysdate..doc" style=minimal;
%gplot(yvar_INS_uIU_ml_n, mean_INS_uIU_ml_n, INSULIN uIU ml/n); 
ods rtf close;

ods rtf file="Q:\Kimberly Trout\iPRO_2017\documents\output\Day 2 Plot of GLU YSI Overlay trt A vs B Day 1 Plots of outcomes across time &sysdate..doc" style=minimal;
%gplot(yvar_GLU_YSI_, mean_GLU_YSI_ , GLUCOSE YSI (mg/dL));
ods rtf close;





 /**************Day 2 **************/
proc format;
value  timeint 
0    =   '     '
1	 =	 'Fasting'
2	 =	 'B	30'
3	 =	 'B	60'
4	 =	 'B	120'
5	 =	 'B	180'
6	 =	 '   '
7	 =	 'L	60'
8	 =	 'L 120'
9	 =	 'L	180'
10	 =	 'D 30'
11	 =	 'D 60'
12	 =	 'D 120'
13	 =	 '     '
14	 =	 'Fasting'
15	 =	 'B	30'
16	 =	 'B	60'
17	 =	 'B	120'
18	 =	 'B	180'
19	 =	 'L 30'
20	 =	 'L	60'
21	 =	 'L 120'
22	 =	 'L	180'
23	 =	 'D 30'
24	 =	 'D 60'
25   =   '  '
;
value $Tx
"A" = "iPRO30%/CHO35%"
"B" = "LPRO15%/CHO50%"
;
run;


%macro gplot(yvar,mean, lab);
goptions reset=all cback=white border htext=12pt htitle=14pt;

/* Define the axis characteristics */                                                                                                   
   *axis1 offset=(0,0) minor=none;
  axis1 label = (c=Black  f=swissl h=2 'Time(Min)')order = 0 to 6 by 1 value=(h=1 F=SWISS);                                                                                                       
  axis2 label = (c=Black a = 90 f=swissl h=2 " &lab");                                                                                                                   
                                                                                                                                        
/* Define the symbol characteristics */                                                                                                 
   symbol1 interpol=hiloctj color=blue line=1 w=3 MODE=INCLUDE;                                                                                          
   symbol2 interpol=hiloctj color=red line=1 w=3 MODE=INCLUDE;                      
/*   symbol3 interpol=hiloctj color=green line=1 w=3; */

   *symbol4 interpol=none color=blue value=dot height=1.6;
   *symbol5 interpol=none color=red value=dot height=1.6;
/*   symbol6 interpol=none color=green value=dot height=1.6; */
                                                                                                                                        
/* Define the legend characteristics */                                                                                                 
   legend1 label=('Tx:') frame;                                                                                                      
                                                                                                                                        
/* Plot the error bars using the HILOCTJ interpolation */                                                                               
/* and overlay symbols at the means. */                                                                                                 

 proc gplot data=derived.reshape;  
	where time_int < 5.5; 
   plot &yvar*time_int=treatment / haxis=axis1 vaxis=axis2 legend=legend1;                                                                    
    *plot2 &mean*time_int=treatment / /*vaxis=axis2*/ noaxis nolegend; 
format time_int timeint. treatment $Tx.; 
run;                                                                                                                                    
quit;                 
%mend gplot; 


ods rtf file="Q:\Kimberly Trout\iPRO_2017\documents\output\Day 1 Breakfast Plot of GLU YSI Overlay trt A vs B Day 1 Plots of outcomes across time &sysdate..doc" style=minimal;
%gplot(yvar_GLU_YSI_, mean_GLU_YSI_ , GLUCOSE YSI (mg/dL));
ods rtf close;


/*********MEAL BY DAY OVERLAY**************/
/*DAY 1 Breakfast Overlay*/
proc format;
value  timeint 
0    =   '     '    /*adding space for the graph*/
1	 =	 'Fasting'
2	 =	 'B	30'
3	 =	 'B	60'
4	 =	 'B	120'
5	 =	 'B	180'
6	 =	 '   '      /*adding space for the graph*/
7	 =	 'L	60'
8	 =	 'L 120'
9	 =	 'L	180'
10	 =	 'D 30'
11	 =	 'D 60'
12	 =	 'D 120'
13	 =	 '     '
14	 =	 'Fasting'
15	 =	 'B	30'
16	 =	 'B	60'
17	 =	 'B	120'
18	 =	 'B	180'
19	 =	 'L 30'
20	 =	 'L	60'
21	 =	 'L 120'
22	 =	 'L	180'
23	 =	 'D 30'
24	 =	 'D 60'
25   =   '  '
;
value $Tx
"A" = "iPRO30%/CHO35%"
"B" = "LPRO15%/CHO50%"
;
run;
ods rtf file="Q:\Kimberly Trout\iPRO_2017\documents\output\Day 1 Breakfast Plot of GLU YSI Overlay trt A vs B Day 1 Plots of outcomes across time &sysdate..doc" style=minimal;
/*%gplot(yvar_GLU_YSI_, mean_GLU_YSI_ , GLUCOSE YSI (mg/dL));*/
%gplot(yvar_GLU_YSI_, mean_GLU_YSI_ , GLUCOSE YSI (mg/dL),0 to 6 ,time_int < 5.5);
ods rtf close;

/*DAY 2 Breakfast Overlay*/
proc format;
value  timeint 
0    =   '     '   
1	 =	 'Fasting'
2	 =	 'B	30'
3	 =	 'B	60'
4	 =	 'B	120'
5	 =	 'B	180'
6	 =	 'L 30'      
7	 =	 'L	60'
8	 =	 'L 120'
9	 =	 'L	180'
10	 =	 'D 30'
11	 =	 'D 60'
12	 =	 'D 120'
13	 =	 '     ' /*adding space for the graph*/
14	 =	 'Fasting'
15	 =	 'B	30'
16	 =	 'B	60'
17	 =	 'B	120'
18	 =	 'B	180'
19	 =	 '    '    /*adding space for the graph*/
20	 =	 'L	60'
21	 =	 'L 120'
22	 =	 'L	180'
23	 =	 'D 30'
24	 =	 'D 60'
25   =   '  '
;
value $Tx
"A" = "iPRO30%/CHO35%"
"B" = "LPRO15%/CHO50%"
;
run;
ods rtf file="Q:\Kimberly Trout\iPRO_2017\documents\output\Day 2 Breakfast Plot of GLU YSI Overlay trt A vs B Day 1 Plots of outcomes across time &sysdate..doc" style=minimal;
/*%gplot(yvar_GLU_YSI_, mean_GLU_YSI_ , GLUCOSE YSI (mg/dL));*/
%gplot(yvar_GLU_YSI_, mean_GLU_YSI_ , GLUCOSE YSI (mg/dL),14 to 19 ,14.5 < time_int < 18.5);
ods rtf close;

/**********DAY 1 Lunch Overlay***********/
proc format;
value  timeint 
0    =   '     '   
1	 =	 'Fasting'
2	 =	 'B	30'
3	 =	 'B	60'
4	 =	 'B	120'
5	 =	 '    '/*adding space for the graph*/
6	 =	 'L 30'      
7	 =	 'L	60'
8	 =	 'L 120'
9	 =	 'L	180'
10	 =	 '    '/*adding space for the graph*/
11	 =	 'D 60'
12	 =	 'D 120'
13	 =	 '     ' 
14	 =	 'Fasting'
15	 =	 'B	30'
16	 =	 'B	60'
17	 =	 'B	120'
18	 =	 'B	180'
19	 =	 '    '    
20	 =	 'L	60'
21	 =	 'L 120'
22	 =	 'L	180'
23	 =	 'D 30'
24	 =	 'D 60'
25   =   '  '
;
value $Tx
"A" = "iPRO30%/CHO35%"
"B" = "LPRO15%/CHO50%"
;
run;
ods rtf file="Q:\Kimberly Trout\iPRO_2017\documents\output\Day 1 Lunch Plot of GLU YSI Overlay trt A vs B Day 1 Plots of outcomes across time &sysdate..doc" style=minimal;
/*%gplot(yvar_GLU_YSI_, mean_GLU_YSI_ , GLUCOSE YSI (mg/dL));*/
%gplot(yvar_GLU_YSI_, mean_GLU_YSI_ , GLUCOSE YSI (mg/dL),5 to 10 ,5.5 < time_int < 9.5);
ods rtf close;

/*DAY 2 Lunch Overlay*/
proc format;
value  timeint 
0    =   '     '   
1	 =	 'Fasting'
2	 =	 'B	30'
3	 =	 'B	60'
4	 =	 'B	120'
5	 =	 '    '
6	 =	 'L 30'      
7	 =	 'L	60'
8	 =	 'L 120'
9	 =	 'L	180'
10	 =	 '    '
11	 =	 'D 60'
12	 =	 'D 120'
13	 =	 '     ' 
14	 =	 'Fasting'
15	 =	 'B	30'
16	 =	 'B	60'
17	 =	 'B	120'
18	 =	 '    '/*adding space for the graph*/
19	 =	 'L 30'    
20	 =	 'L	60'
21	 =	 'L 120'
22	 =	 'L	180'
23	 =	 '    '/*adding space for the graph*/
24	 =	 'D 60'
25   =   '  '
;
value $Tx
"A" = "iPRO30%/CHO35%"
"B" = "LPRO15%/CHO50%"
;
run;
ods rtf file="Q:\Kimberly Trout\iPRO_2017\documents\output\Day 2 lunch Plot of GLU YSI Overlay trt A vs B Day 1 Plots of outcomes across time &sysdate..doc" style=minimal;
/*%gplot(yvar_GLU_YSI_, mean_GLU_YSI_ , GLUCOSE YSI (mg/dL));*/
%gplot(yvar_GLU_YSI_, mean_GLU_YSI_ , GLUCOSE YSI (mg/dL),18 to 23 ,18.5 < time_int < 22.5);
ods rtf close;


/*DAY 1 Dinner Overlay*/
proc format;
value  timeint 
0    =   '     '   
1	 =	 'Fasting'
2	 =	 'B	30'
3	 =	 'B	60'
4	 =	 'B	120'
5	 =	 '    '
6	 =	 'L 30'      
7	 =	 'L	60'
8	 =	 'L 120'
9	 =	 '    '/*adding space for the graph*/
10	 =	 'D 30'
11	 =	 'D 60'
12	 =	 'D 120'
13	 =	 'D 180' 
14	 =	 '    '/*adding space for the graph*/
15	 =	 'B	30'
16	 =	 'B	60'
17	 =	 'B	120'
18	 =	 '    '
19	 =	 'L 30'    
20	 =	 'L	60'
21	 =	 'L 120'
22	 =	 'L	180'
23	 =	 '    '
24	 =	 'D 60'
25   =   '  '
;
value $Tx
"A" = "iPRO30%/CHO35%"
"B" = "LPRO15%/CHO50%"
;
run;
ods rtf file="Q:\Kimberly Trout\iPRO_2017\documents\output\Day 1 Dinner Plot of GLU YSI Overlay trt A vs B Day 1 Plots of outcomes across time &sysdate..doc" style=minimal;
/*%gplot(yvar_GLU_YSI_, mean_GLU_YSI_ , GLUCOSE YSI (mg/dL));*/
%gplot(yvar_GLU_YSI_, mean_GLU_YSI_ , GLUCOSE YSI (mg/dL),9 to 14 ,9.5 < time_int < 13.5);
ods rtf close;

/*DAY 2 Dinner Overlay*/
proc format;
value  timeint 
0    =   '     '   
1	 =	 'Fasting'
2	 =	 'B	30'
3	 =	 'B	60'
4	 =	 'B	120'
5	 =	 '    '
6	 =	 'L 30'      
7	 =	 'L	60'
8	 =	 'L 120'
9	 =	 '    '
10	 =	 'D 30'
11	 =	 'D 60'
12	 =	 'D 120'
13	 =	 'D 180' 
14	 =	 '    '
15	 =	 'B	30'
16	 =	 'B	60'
17	 =	 'B	120'
18	 =	 '    '
19	 =	 'L 30'    
20	 =	 'L	60'
21	 =	 'L 120'
22	 =	 '    '    /*adding space for the graph*/
23	 =	 'D 30'
24	 =	 'D 60'
25   =   '  '      /*adding space for the graph*/
;
value $Tx
"A" = "iPRO30%/CHO35%"
"B" = "LPRO15%/CHO50%"
;
run;
ods rtf file="Q:\Kimberly Trout\iPRO_2017\documents\output\Day 2 Dinner Plot of GLU YSI Overlay trt A vs B Day 1 Plots of outcomes across time &sysdate..doc" style=minimal;
/*%gplot(yvar_GLU_YSI_, mean_GLU_YSI_ , GLUCOSE YSI (mg/dL));*/
%gplot(yvar_GLU_YSI_, mean_GLU_YSI_ , GLUCOSE YSI (mg/dL),22 to 25 ,22.5 <time_int < 24.5);
ods rtf close;
