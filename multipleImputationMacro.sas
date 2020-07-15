

/* QA ON VISIT TO DETERMINE LEAST MISSING */
proc freq data= derived.derimp;
	table visit;
run;

/********************************************************
variables with no missing data:


use mi on variables with missing data:

*********************************************************/

/* MULTIPLE IMPUTATION MACRO */
%macro multiImp(outputSet, mivar, seed);
/* CALCULATE MEAN, MAX, AND MIN AUTOMATICALLY*/
proc means data= derived.derimp /*replace derived.derimp with dataset*/ mean max min;
	output out= mmm /*output dataset*/ mean = me max = ma min = mi;
	var &mivar /*variable we are imputing*/;
run;
/* ASSIGN MEAN MAX MIN TO MACRO VARIABLES */
data _null_;
	set mmm /*must match output dataset on line 20 */;
	call symput("mean", me);
	call symput("max", ma);
	call symput("min", mi);
run;
/* MI USING MACRO VARIABLES to autogenerate mean, max, mean */
proc mi data=&outputSet out=&outputSet seed=&seed mu0=&mean  NIMPUTe=1 simple maximum = &max minimum = &min;
		where visit = 2;
	  /* CATEGORICAL VARIABLES WITH LITTLE OR NO MISSING IN ORDER OF LEAST TO MOST MISSING*/
      class sick_healthy physposta inftgndc rachs;
	  /* CONTINUOUS VARIABLES WITH LITTLE OR NO MISSING 
	  LAST VARIABLE MUST BE THE VARIABLE FOR IMPUTATION */
      var   sick_healthy physposta inftgndc rachs &mivar; 
     monotone reg(&mivar = sick_healthy physposta inftgndc rachs);
run;
%prefixMaker(&outputSet, &mivar);
%beforeAfterMeans(&outputSet, &mivar);
%mend;

/* ATTACHES THE SUFFIX TO THE GIVEN MI VARIABLE */
%macro prefixMaker(outputSet, mivar);
data &outputSet;
	set &outputSet;
	mi_&mivar = &mivar;
	drop &mivar;
run;
%mend;

/* CALCULATES MEAN BEFORE AND AFTER TO SHOW MI EFFECT */
%macro beforeAfterMeans(outputSet, mivar);
proc means data=derived.derimp n mean std median min max;
	where visit = 2;
	var  &mivar sick_healthy physposta inftgndc rachs prndiagn patracec patethc mode_dc_b momeduc;
	title 'before imputation';
quit;

proc means data=&outputSet n mean std median min max;
	var mi_&mivar;
	title 'after imputation';
quit;
%mend;

/* INITIALIZATION OF SET FOR MI */
data finalMI;
	set derived.derimp;
run;

/*INITIAL IMPUTATION */
%multiImp(finalMI, mdi_m6, 2706571);
%multiImp(finalMI, mdi_m12, 6229245);
%multiImp(finalMI, pdi_m6, 5442658);
%multiImp(finalMI, pdi_m12, 1307171);
%multiImp(finalMI, attention_m6, 8018650);
%multiImp(finalMI, attention_m12, 6742025);
%multiImp(finalMI, orientation_m6, 6170675);
%multiImp(finalMI, orientation_m12, 4088818);
%multiImp(finalMI, emotional_m6, 9584074);
%multiImp(finalMI, emotional_m12, 5555613);
%multiImp(finalMI, motorquality_m6, 1302636);
%multiImp(finalMI, motorquality_m12, 1419736);
%multiImp(finalMI, additional_m6, 9852074);
%multiImp(finalMI, additional_m12, 3743791);		

/*QA IMPUTATIONS */
proc contents data= derived.imputedSet;
run;

/* FINDING STUDY IDS WITH MISSING */
proc means data= derived.imputedSet nmiss noprint;
by studyidn;
/* ORDER MATTERS ON THE NEXT TWO LINES */
	var mdi_m6 mdi_m12 mi_mdi_m6 mi_mdi_m12;
	output out = o  max=mdi_m6 mdi_m12 mi_mdi_m6 mi_mdi_m12;
run;

proc print data=o; run;

/*QA MISSING STUDY IDS */
proc print data= derived.imputedSet (obs = 30);
	where studyidn = "040-01" or studyidn = "009-01";
	var sick_healthy physposta inftgndc rachs visit studyidn;
run;


/* MULTIPLE IMPUTATION MACRO FOR MISSING VALUES, VISIT = 4*/
%macro multiImpMiss(outputSet, mivar, seed);
/* CALCULATE MEAN, MAX, AND MIN */
proc means data= derived.derimp mean max min;
	output out= mmm mean = me max = ma min = mi;
	var &mivar;
run;
/* ASSIGN MEAN MAX MIN TO MACRO VARIABLES */
data _null_;
	set mmm;
	call symput("mean", me);
	call symput("max", ma);
	call symput("min", mi);
run;
/* MI USING MACRO VARIABLES */
proc mi data=&outputSet out=&outputSet seed=&seed mu0=&mean  NIMPUTe=1 simple maximum = &max minimum = &min;
		where visit = 4;
	  /* CATEGORICAL VARIABLES WITH LITTLE OR NO MISSING IN ORDER OF LEAST TO MOST MISSING*/
      class sick_healthy physposta inftgndc rachs;
	  /* LAST VARIABLE MUST BE THE VARIABLE FOR IMPUTATION */
      var   sick_healthy physposta inftgndc rachs &mivar; 
     monotone reg(&mivar = sick_healthy physposta inftgndc rachs);
run;
%prefixMaker(&outputSet, &mivar);
%beforeAfterMeans(&outputSet, &mivar);
%mend;

/* INITIALIZE DATA SET FOR MISSING VALUE IMPUTATION */
data mis;
	set derived.derimp;
run;

/* FINAL IMPUTATIONS Each line imputes a variable (name of midataset, variable, random number at least 7 digits)*/
%multiImpMiss(mis, mdi_m6, 2706571);
%multiImpMiss(mis, mdi_m12, 6229245);
%multiImpMiss(mis, pdi_m6, 5442658);
%multiImpMiss(mis, pdi_m12, 1307171);
%multiImpMiss(mis, attention_m6, 8018650);
%multiImpMiss(mis, attention_m12, 6742025);
%multiImpMiss(mis, orientation_m6, 6170675);
%multiImpMiss(mis, orientation_m12, 4088818);
%multiImpMiss(mis, emotional_m6, 9584074);
%multiImpMiss(mis, emotional_m12, 5555613);
%multiImpMiss(mis, motorquality_m6, 1302636);
%multiImpMiss(mis, motorquality_m12, 1419736);
%multiImpMiss(mis, additional_m6, 9852074);
%multiImpMiss(mis, additional_m12, 3743791);

/* NEW IMPUTED FROM VISIT = 4 OF THE MISSING */
data mis;
	set mis;
	keep studyidn mi_mdi_m6 -- mi_additional_m12;
run;

/* SET MISSING INTO FINAL */
data finalMI;
	set finalMI mis;
	keep studyidn mi_mdi_m6 -- mi_additional_m12;
run;

/* QA FOR NO MISSING */
proc means data= finalMI nmiss;
	var mi_mdi_m6 -- mi_additional_m12;
run;

/* SORTS FOR FINAL MERGE */
proc sort data= derived.derimp; 
	by studyidn;
run;

proc sort data= finalMI; 
	by studyidn;
run;


/* MERGE INTO FINAL DATA SET */
data derived.imputedSet;
	merge derived.derimp finalMI;
	by studyidn;
run;


/*EXPORT IMPUTEDSET TO STATA*/
PROC EXPORT DATA= DERIVED.IMPUTEDSET 
            OUTFILE= "U:\path\datasetName.dta" 
            DBMS=STATA REPLACE;
RUN;
