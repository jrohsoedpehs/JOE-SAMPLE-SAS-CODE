libname raw 'U:\Jesse Chittams\admin\Mary\GLM\Final Project\data\Raw';
libname derived 'U:\Jesse Chittams\admin\Mary\GLM\Final Project\data\Derived';
footnote "U:\Jesse Chittams\admin\Joseph Rhodes\Notes\SAS\Experience\programs\Draft\testg3d";
options fmtsearch=(raw);
%let path= U:\Jesse Chittams\admin\Mary\GLM\Final Project\; /*DON'T RUN*/
 
/************************************************************************************************************************/

proc format library=RAW;
  value sistersite 	
	1= "Canada"
    2= "Australiza and New Zealand"
  	3= "USA"
 	4="Europe"
  	5="Latin America"
  	6="Asia";
run;


proc format library=RAW;
	value nutric_cat
		0="Low"
		1="High";
run;

proc format library=RAW;
	value cat
		1= "0-25"
		2="25-50"
		3="50-75"
		4="75-100"
		5="100-125"
		6="125-150";
run;

proc format library=RAW;
	value patientdied
		0="Died"
		1="Didn't die";
run;
options nofmterr; 


******************************LOGISITC: OUTCOME IS PATIENT MORTALITY (BiNARY)*******************************************************;

*stratified interaction analyses;


proc sort data=raw.analysis;
	by nutric_cat2; 
run;

%MACRO LOGISTIC (X ,Z , w, wher, titl);
ods select type3 ;
data estimates; run;
	Proc genmod data=raw.analysis DESCENDING; 
	by nutric_cat2;
	&wher;
    Class  &X  icuid;
    Model   Patientdied  =  &X   &Z &w / type3 LINK=LOGIT DIST=BIN; 
	repeated subject=icuid/ type=CS;
	format nutric_cat2 nutric_cat. sistersite sistersite.;
    title "&titl";
	ods output   GEEEmpPEst= GEEEmpPEst;
Run;

data estimates;
	set GEEEmpPEst;
where parm ne "Intercept";
	LBetaEstimate=exp(estimate);
	LBetaLowerCL=exp(LowerCL);
	LBetaUpperCL=exp(UpperCL);
run;
	
proc print data= estimates noobs;
      var  nutric_cat2 Parm LBetaEstimate StdErr LBetaLowerCL LBetaUpperCL ProbZ;
      label LBetaEstimate = 'Odds Ratio'
          LBetaLowerCL = 'Lower 95%CI'
          LBetaUpperCL = 'Upper 95%CI' 
      format LBetaEstimate StdErr LBetaLowerCL LBetaUpperCL 7.5;
run;
%MEND;

/***********************/
/*****4 DAY RESULTS*****/
/***********************/

/*Protein - Adjusting for covariates*/

ODS RTF FILE = "U:\Jesse Chittams\admin\Mary\GLM\Final Project\documents\output\4_Day_Macro_&sysdate..rtf";
%LOGISTIC(sistersite, ,mean_AdequacyProtTot_10 eval_days ,where totalprotein_missing=0 and icudays_4 = 1 and remain_oral=0, Stratified Recoded Nutric Score_Protein for 4 day);

/*Calories - Adjusting for covariates*/
%LOGISTIC(sistersite, ,  mean_AdequacyCalsTot_10 eval_days ,where totalprotein_missing=0 and icudays_4 = 1 and remain_oral=0,  Stratified Recoded Nutric Score_Energy for 4 day);

/*Not adjusting for any covariates- Simple logistic regression*/

/*Protein*/
%LOGISTIC( , ,  mean_AdequacyProtTot_10 ,where totalprotein_missing=0 and icudays_4 = 1 and remain_oral=0, Stratified Recoded Nutric Score_Protein for 4 day);
/*Calories*/
%LOGISTIC( , ,  mean_AdequacyCalsTot_10 ,where totalprotein_missing=0 and icudays_4 = 1 and remain_oral=0,  Stratified Recoded Nutric Score_Energy for 4 day);
ODS RTF CLOSE;

/************************/
/*****12 DAY RESULTS*****/
/************************/

ODS RTF FILE = "U:\Jesse Chittams\admin\Mary\GLM\Final Project\documents\output\12_Day_Macro_&sysdate..rtf";
/*Protein - Adjusting for covariates*/
%LOGISTIC(sistersite, ,  mean_AdequacyProtTot_10 ,where totalprotein_missing=0 and icudays_12 = 1 and remain_oral=0, Stratified Recoded Nutric Score_Protein for 12 day);

/*Protein - Adjusting for covariates*/
%LOGISTIC(sistersite,  ,  mean_AdequacyCalsTot_10 
	,where totalprotein_missing=0 and icudays_12 = 1 and remain_oral=0, Stratified Recoded Nutric Score_Energy for 12 day);

/*Not adjusting for any covariates- Simple logistic regression*/

/*Protein*/
%LOGISTIC( , ,  mean_AdequacyProtTot_10 
	,where totalprotein_missing=0 and icudays_12 = 1 and remain_oral=0, Stratified Recoded Nutric Score_Protein for 12 day);
/*Calories*/
%LOGISTIC( ,  ,  mean_AdequacyCalsTot_10 
	,where totalprotein_missing=0 and icudays_12 = 1 and remain_oral=0, Stratified Recoded Nutric Score_Energy for 12 day);
ODS RTF CLOSE;



*Create predicted probability of mortality score plots for weeks 4 and 12(PS);


/*MACRO FOR PREDICTED PROBABLITY PLOTS*/
proc sort data=raw.analysis; by nutric_cat2; run;
%MACRO plot (X ,Z , w, wher, titl, titlp);
ods select none ;
data probs; run;
Proc logistic data=raw.analysis DESCENDING; 
by nutric_cat2;
	&wher;
     Class  &X  icuid;
     Model   Patientdied  =  &X   &Z &w; 
	  output out=probs predicted=phat;
     title "&titl";	
	 *ods output   GEEEmpPEst= GEEEmpPEst;
Run;

ods select all;
axis1 label=(C=black F=SWISS H=2 "&titlp") order=(1 to 150 by 10) minor=(n=1);
axis2 label=(C=black F=SWISS angle=90 H=2 'Predicted Probability of Mortality') order=(0 to .5 by .1) minor=(n=1); 
proc gplot data=work.probs;
    symbol2 v=dot 	  c=black i=none w=1 l=2;/*robs;*/
	symbol1 v=circle  c=gray  i=none w=1 l=1;
	plot phat*&W = nutric_cat2/haxis=axis1 vaxis=axis2; 
	format nutric_cat2 nutric_cat.;
	label nutric_cat2= 'Risk Categories';
	title;
	footnote;
/*	title "&titlp"; */
run;
quit;

%MEND;


*4 DAY PREDICTED PROBABILITY MORTALITY PLOTS FOR PROTEIN AND CALORIES*/;

/*4 DAY*/
ods rtf file="U:\Charlene Compher\Michele Nicolo\R21_FALL2013\documents\output\4 Day Energy and Protein Predicted Prob. Plots for Mortality &sysdate..rtf" style=journal;
%PLOT( , ,  mean_AdequacyProtTot,where totalprotein_missing=0 and icudays_4 = 1 and remain_oral=0, Stratified Recoded Nutric Score_Protein for 4 day, Percent Goal Protein Intake at 4 Days);
%PLOT(, ,  mean_AdequacyCalsTot  ,where totalprotein_missing=0 and icudays_4 = 1 and remain_oral=0,  Stratified Recoded Nutric Score_Energy for 4 day, Percent Goal Energy Intake at 4 Days);
ods rtf close;

/*12 DAY*/
ods rtf file="U:\Charlene Compher\Michele Nicolo\R21_FALL2013\documents\output\12 Day Energy and Protein Predicted Prob. Plots for Mortality &sysdate..rtf" style=journal;
%PLOT( , ,  mean_AdequacyProtTot,where totalprotein_missing=0 and icudays_12 = 1 and remain_oral=0, Stratified Recoded Nutric Score_Protein for 12 day,Percent Goal Protein Intake at 12 Days);
%PLOT(, ,  mean_AdequacyCalsTot  ,where totalprotein_missing=0 and icudays_12 = 1 and remain_oral=0,  Stratified Recoded Nutric Score_Energy for 12 day, Percent Goal Energy Intake at 12 Days);
ods rtf close;



/*MACRO FOR AVERAGE MORTALITY PLOTS*/
proc sort data=raw.analysis; by nutric_cat2; run;
%MACRO avgplot (X ,Z , w, wher, titl, titlp);
ods select none ;
data probs; run;
Proc logistic data=raw.analysis DESCENDING; 
by nutric_cat2;
	&wher;
     Class  &X  icuid;
     Model   Patientdied  =  &X   &Z &w; 
	  output out=probs predicted=phat;
     title "&titl";	
	 *ods output   GEEEmpPEst= GEEEmpPEst;
Run;

data probs2;
	set probs;
	if . < &w < 25 then cat = 1;
	if 25 < &w < 50 then cat = 2;
	if 50 < &w < 75 then cat = 3;
	if 75 < &w < 100 then cat = 4;
	if 100 < &w < 125 then cat = 5;
	if 125 < &w < 150 then cat = 6;
run;

proc sort data=probs2;
	by nutric_cat2 cat;
run;

proc means data=probs2 noprint;
	by nutric_cat2 cat;
	var Patientdied;
	output out=probs3 mean = mean;
run;

ods select all;
axis1 label=(C=black F=SWISS H=2 "&titlp") order=(1 to 6 by 1) minor=(n=1); 
axis2 label=(C=black F=SWISS angle=90 H=2 'Average Mortality') order=(0 to .5 by .1) minor=(n=1); 
proc gplot data=work.probs3;
    symbol2 v=dot 	  c=black i=rl w=1 l=2;/*robs;*/
	symbol1 v=circle  c=gray  i=rl w=1 l=1;
	plot mean*cat = nutric_cat2/haxis=axis1 vaxis=axis2; 
	format nutric_cat2 nutric_cat. cat cat.;
	label nutric_cat2= 'Risk Categories';
	title;
	footnote;
run;
quit;
%MEND;


/*4 DAY AVERAGE MORTALITY PLOT RESULTS FOR PROTEIN AND CALORIES*/

/*4 DAY*/
ods rtf file="U:\Charlene Compher\Michele Nicolo\R21_FALL2013\documents\output\4 Day Mean Energy and Protein Plots &sysdate..rtf" style=journal;U:\Charlene Compher\Michele Nicolo\R21_FALL2013\documents\output
%avgPLOT( , ,  mean_AdequacyProtTot,where totalprotein_missing=0 and icudays_4 = 1 and remain_oral=0, Stratified Recoded Nutric Score_Protein for 4 day, Percent Goal Protein Intake at 4 Days);
%avgPLOT(, ,  mean_AdequacyCalsTot  ,where totalprotein_missing=0 and icudays_4 = 1 and remain_oral=0,  Stratified Recoded Nutric Score_Energy for 4 day, Percent Goal Energy Intake at 4 Days);
ods rtf close;

/*12 DAY*/
ods rtf file="U:\Charlene Compher\Michele Nicolo\R21_FALL2013\documents\output\12 Day Mean Energy and Protein Plots for Mortality &sysdate..rtf" style=journal;
%avgPLOT( , ,  mean_AdequacyProtTot,where totalprotein_missing=0 and icudays_12 = 1 and remain_oral=0, Stratified Recoded Nutric Score_Protein for 12 day,Percent Goal Protein Intake at 12 Days);
%avgPLOT(, ,  mean_AdequacyCalsTot  ,where totalprotein_missing=0 and icudays_12 = 1 and remain_oral=0,  Stratified Recoded Nutric Score_Energy for 12 day, Percent Goal Energy Intake at 12 Days);
ods rtf close;


/*QA to check the domain needed for the X-axis*/

proc means data=raw.analysis min max;
	var mean_AdequacyProtTot mean_AdequacyCalsTot;
run;

proc contents data=raw.analysis;
run;

proc freq data=raw.analysis;
	tables icudays_12 / list missing;
run;

proc freq data=work.probs3;
	tables nutric_cat2;
run;
 
proc means data=work.probs3 min max;
	var mean;
run;

/*QA 8/12/15*/

ods rtf file="U:\Charlene Compher\Michele Nicolo\R21_FALL2013\documents\output\Cross tab on Cal&Prot Intake and Mortality at 12 Days &sysdate..rtf" style=journal;
proc freq data=work.probs2;
	where totalprotein_missing=0 and icudays_12 = 1 and remain_oral=0;
	tables cat*patientdied;
	format cat cat. patientdied patientdied.;
	title 'Cross tab on Cal/Prot Intake and Mortality at 12 Days';
run;
ods rtf close;

proc freq data=work.probs2;
	tables patientdied;
run;

/*8/10/15*/

/*create plots for 3D TDA using the survival analysis code (PHREG)*/

proc sort data=raw.analysis; 
	by nutric_cat2;
run;

%MACRO plot2 (y,x,z,w,wher,titl,data);
;
/*ods select type3 ;*/
data &data; run;
 proc phreg data=raw.analysis covs(aggregate) ;
by nutric_cat2;
	  &wher;
  	  class &z  icuid;
      model &y*&x(1) = &z &w /RISKLIMITS ;
      id  icuid;
	  title1 "Access effect of sister site on &y adjusting for &x";
	  title2 "&titl";
output out=&data logsurv=logsurv  loglogs=loglog  survival=survival xbeta=xbeta;
     title "&titl";	
	 *ods output   GEEEmpPEst= GEEEmpPEst;
Run;

/*axis1 label=(C=black F=SWISS H=2 "&titlp") order=(1 to 15 by 1) minor=(n=1); */
/*axis2 label=(C=black F=SWISS angle=90 H=2 'Predicted Probability of Mortality') order=(0 to .5 by .1) minor=(n=1); */
/*proc gplot data=work.probs;*/
/*    symbol2 v=dot 	  c=black i=none w=1 l=2;/*robs;*/*/
/*	symbol1 v=circle  c=gray  i=none w=1 l=1;*/
/*	plot phat*&W = nutric_cat2/haxis=axis1 vaxis=axis2; */
/*	format nutric_cat2 nutric_cat.;*/
/*	label nutric_cat2= 'Risk Categories';*/
/*	title;*/
/*run;*/
quit;
%MEND;

/*this macro is also creating the 4 unique datasets that are needed to create the 3D TDA plots*/
%plot2 (time, censor, ,mean_AdequacyProtTot,where totalprotein_missing=0 and icudays_4 = 1 and remain_oral=0, time to discharge protein with 4 days, raw.tda4prot); 
%plot2 (time, censor, ,mean_AdequacyProtTot,where totalprotein_missing=0 and icudays_12 = 1 and remain_oral=0, time to discharge protein with 4 days, raw.tda12prot); 
%plot2 (time, censor, ,mean_AdequacyCalsTot,where totalprotein_missing=0 and icudays_4 = 1 and remain_oral=0, time to discharge calorie with 4 days, raw.tda4cal); 
%plot2 (time, censor, ,mean_AdequacyCalsTot,where totalprotein_missing=0 and icudays_12 = 1 and remain_oral=0, time to discharge calorie with 4 days, raw.tda12cal); 

ods rtf file="U:\Charlene Compher\Michele Nicolo\R21_FALL2013\documents\output\Contents for TDA temp dataset &sysdate..rtf" style=journal;
proc contents data=work.test;
run;
ods rtf close;

/*QA*/
title;
proc means data=raw.tda4prot;
	var mean_AdequacyProtTot ;
	title "prot at 4 days";
run;

proc means data=raw.tda12prot;
	var mean_AdequacyProtTot;
	title "prot at 12 days";
run;

proc means data=raw.tda4cal;
	var mean_AdequacycalsTot ;
	title "cals at 4 days";
run;

proc means data=raw.tda12cal;
	var mean_AdequacycalsTot;
	title "cals at 12 days";
run;

/*8/11/15*/
/************************************************************/
/*TDA 3D PLOTS*/
/************************************************************/

/* Create the grid data, this code prepares the data for proc g3d */

%MACRO tda (x,y,z,rotate,tilt,title);
	title;
	proc g3grid data=&x out=&y;
	  grid time*&z=survival / 
		axis1=4 to 65 by 5
		axis2=0 to 145 by 5;
	run;
	/* Plot the Surface */
	proc g3d data=&y;
	  plot time*&z=survival / rotate=&rotate tilt=&tilt ZMAX= 1  ZMIN=0;
	  title"&title";
	run;
	*quit;
%MEND;

/*TEST TO SEE WHY DATA DIPS*/
%tda (raw.tda4prot, tda4prot_, mean_AdequacyProtTot, 30,30,"3D TDA Plot for Protein at 4 Days"); /*If the scale doesn't change*/

%tda (raw.tda4prot, tda4prot_, mean_AdequacyProtTot, 300,30,"3D TDA Plot for Protein at 4 Days"); /*If the scale doesn't change*/





TITLE;
ods rtf file="U:\Charlene Compher\Michele Nicolo\R21_FALL2013\documents\output\3D TDA Graphs &sysdate..rtf" style=journal;
%tda (raw.tda4prot, tda4prot_, mean_AdequacyProtTot, 270,30,"3D TDA Plot for Protein at 4 Days"); /*If the scale doesn't change*/
%tda (raw.tda12prot, tda12prot_, mean_AdequacyProtTot, 270,30,"3D TDA Plot for Protein at 12 Days");		
%tda (raw.tda4cal, tda4cals_, mean_AdequacyCalsTot, 270,30,"3D TDA Plot for Calories at 4 Days");
%tda (raw.tda12cal, tda12cals_, mean_AdequacyCalsTot, 270,30,"3D TDA Plot for Calories at 12 Days");
ods rtf close;
title;

proc means data=raw.tda4prot;
var mean_AdequacyProtTot survival;
run;
proc means data=raw.tda12prot;
var mean_AdequacyProtTot survival;
run;
proc means data=raw.tda4cal;
var mean_AdequacyCalsTot survival;
run;
proc means data=raw.tda12cal;
var mean_AdequacyCalsTot survival ;
run;

/*****original*****/
/**/
/*proc g3grid data=raw.tda4prot out=a;*/
/*  grid time*mean_AdequacyProtTot=survival / */
/*    axis1=4 to 65 by 5*/
/*    axis2=0 to 145 by 5;*/
/*run;*/
/**/
/*/* Plot the Surface */*/
/*proc g3d data=a;*/
/*  plot time*mean_AdequacyProtTot=survival / rotate=45 tilt=120;*/
/*run;*/
/**/
/**/
/**/
/**/
/**/
/**/
/**/
/**/
/*/********************/*/
/*proc gcontour data=a;*/
/*  plot time*mean_AdequacyProtTot=survival;*/
/*run;*/
/**/
/*proc print data=raw.tda4prot (obs=50);*/
/*	where time = .;*/
/*	var time mean_adequacyprottot survival;*/
/*run;*/

/******3D PLOTS*******/
/*options nofmterr; */
/*data raw.tda4prot;*/
/*	set test(keep= id icuid time xbeta loglog logsurv survival mean_AdequacyProtTot censor totalprotein_missing icudays_4 remain_oral);*/
/*	where totalprotein_missing=0 and icudays_4 = 1 and remain_oral=0 ;*/
/*	keep time survival mean_AdequacyProtTot_10 ;*/
/*run;*/
/**/
/*proc print data=raw.tda4prot (obs=50);*/
/**	var time survival mean_AdequacyProtTot_10 ;*/
/*run;*/
/**/
/**/
/*data raw.tda4prot2;*/
/*	set test(keep= id icuid time xbeta loglog logsurv survival mean_AdequacyProtTot_10 censor totalprotein_missing icudays_4 remain_oral);*/
/*	where totalprotein_missing=0 and icudays_4 = 1 and remain_oral=0 ;*/
/*	keep time survival mean_AdequacyProtTot_10 ;*/
/*	if time ne .;*/
/*	obs = _n_; */
/*	if obs < 11;*/
/*run;*/
/**/
/**/
/*proc sort data=raw.tda4prot2; by time;*/
/*run;*/
/**/
/*proc transpose data=raw.tda4prot2 prefix = _ out=temp;*/
/*	by time;*/
/*	var survival;*/
/*	id mean_AdequacyProtTot_10;*/
/*run;*/
/**/
/*proc print data=temp (drop= _name_ _label_); run;*/
/**/
/*proc print data=raw.tda4prot2; run;*/
/**/
/**/
/*/*NEED CALL STATEMENT*/*/
/*data raw.tda12;*/
/*	set test(keep= id icuid time xbeta loglog logserv survival mean_AdequacyProtTot_10 censor);*/
/*	where totalprotein_missing=0 and icudays_4 = 1 and remain_oral=0 ;*/
/*run;*/
/**/
/**/
/**/
/**/
/**/
/*logsurv=logsurv or loglogs=loglog or survival=survival*/
/**/
/*/*from original program*/*/
/**/
/*%macro adj (y,x,z,w,wher,titl);*/
/*proc sort data=derived.analysis;*/
/*	by nutric_cat2;*/
/*run;*/
/* ods select Type3  ParameterEstimates ;*/
/* proc phreg data=derived.analysis covs(aggregate) ;*/
/* *by nutric_cat2;*/
/* 	  &wher; */
/*      *class Prior(ref='no') Cell(ref='large') Therapy(ref='standard');*/
/*   	  class &z  icuid  ;*/
/*      model &y*&x(1) = &z &w /RISKLIMITS ;*/
/*      id  icuid;*/
/*	  title1 "Access effect of sister site on &y adjusting for &x";*/
/*	  title2 "&titl";*/
/* run;*/
/**/
/*%mend;*/
