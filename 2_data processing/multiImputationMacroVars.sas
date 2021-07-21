libname derived "U:\STUDENT Nadya Golfenshtein\Dissertation\Data\Derived";
footnote "SAS Program stored in U:\STUDENT Nadya Golfenshtein\Dissertation\programs\Draft\read_in_data.sas";

/* Attached is the dataset both in a sas and stata formats after the changes I made (for some reason, I cannot upload 
	it to the shared drive so I don't know if it opens in sas). It contains only subjects with at least one outcome 
	/predictor of interest.
 
To refresh your memory-
1. the aim says regressing MDI/PDI (at 6 and 12mo) on PSI (at 3,6,9,12mo) in separate models. 
 
2. The cov that we will be using are:  physposta, sick_healthy, inftgndc, brthwgtn, patethc patracec, gestagef, 
	prndiagn, weight, length, hc, mode_dc_b, losn, rachs, momeduc.
 
3. The cov with none, or the least missingness are: sick_healthy, inftgndc, losn, brthwgtn, patracec, prndiagn, rachs, 
 
Please let me know if you have any additional questions. I really appreciate your help.  */


/* IMPORT THE RAW DATASET AS A PERMANENT DATASET 9/25/2015 */
PROC IMPORT OUT= derived.derimp
            DATAFILE= "U:\STUDENT Nadya Golfenshtein\Dissertation\Data\Raw\derived dataset for imputations Sep2015.
dta" 
            DBMS=STATA REPLACE;

RUN;

proc print data= derived.derimp (obs = 20);
run;

/* DATASET USING JUST CATEGORICAL VARS*/
data derived.derimpcat;
	set derived.derimp;
	keep physposta sick_healthy inftgndc patethc patracec prndiagn mode_dc_b rachs momeduc;
run;

/* PRINT FIRST 10 OBSERVATIONS */
proc print data= derived.derimpcat (obs=10);
run;

ods pdf file= "U:\STUDENT Nadya Golfenshtein\Dissertation\documents\output\Means_for_all_vars_&sysdate..pdf";
title "";
/* PRINT VARIABLE NAMES AND FORMATS */
proc contents data= derived.derimp;
	title "Contents Cat Vars";
run;

/* GENERATE MEANS FOR ALL VARIABLE */
proc means data= derived.derimp nmiss n mean std min max maxdec = 2;
	title "Means Cat Vars";
run;

/* FREQUENCY FOR ALL VARIABLES */
proc freq data= derived.derimp;
	title "Freqs Cat Vars";
	table physposta sick_healthy inftgndc patethc patracec prndiagn mode_dc_b rachs momeduc;
run;
ods pdf close;

/* PROC MEANS FOR THE VARIABLES IN STEP 1 */
proc means data= derived.derimp nmiss n mean std min max maxdec = 2;
	class visit;
	/* : PICKS UP ALL VARS WITH THE PREFIX */
	vars mdi: pdi: attention: orientation: emotional: motorquality: additional:;
	title "Means Step 1 Vars";
run;

/* QA ON VISIT TO DETERMINE LEAST MISSING */
proc freq data= derived.derimp;
	table visit;
run;

/********************************************************
To refresh your memory-
1. the aim says regressing MDI/PDI (at 6 and 12mo) on PSI (at 3,6,9,12mo) in separate models. 
 
2. The cov that we will be using are:  physposta, sick_healthy, inftgndc, brthwgtn, patethc patracec, gestagef, prndiagn, weight, length, hc, mode_dc_b, losn, rachs, momeduc.
 
3. The cov with none, or the least missingness are: sick_healthy, inftgndc, losn, brthwgtn, patracec, prndiagn,   rachs, 

Hi Olek,
 
Thank you for your email, I will take a look at the contents soon and will get back to you.
 
My apologies, the PSI has 17 subscales  as follows:
din adn ren dem mon acn cdn con isn atn hen ron den spn pdn tsn lfn (long format) -generate summary stats
 
And I forgot to mention that the development outcome has also a BRS scale, additionally to the MDI/PDI. The scale contains 5 subscales in two time points, which are: 
attention_m6 orientation_m6 emotional_m6 motorquality_m6 additional_m6 
attention_m12 orientation_m12 emotional_m12 motorquality_m12 additional_m12 
 
These are in wide format with the same repeated values over time (same as MDI PDI).
 
Thank you!
 
Nadya. 


use mi on:

mdi:
pdi:
attention:
orientation:
emotional:
motorquality:
additional:

mdi_m6 
mdi_m12 
pdi_m6 
pdi_m12 
attention_m6 
attention_m12 
orientation_m6 
orientation_m12 
emotional_m6 
emotional_m12
motorquality_m6 
motorquality_m12 
additional_m6 
additional_m12 
*********************************************************/

/* MULTIPLE IMPUTATION MACRO */
%macro multiImp(outputSet, mivar, seed);
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
		where visit = 2;
	  /* CATEGORICAL VARIABLES WITH LITTLE OR NO MISSING IN ORDER OF LEAST TO MOST MISSING*/
      class sick_healthy physposta inftgndc rachs;
	  /* LAST VARIABLE MUST BE THE VARIABLE FOR IMPUTATION */
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

/* FINAL IMPUTATIONS */
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
	if studyidn = "040-01" or studyidn = "009-01";
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

proc print data= finalMI (obs = 10);
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

/* QA FOR PREVIOUSLY MISSING */
PROC print data= derived.imputedSet;
	where studyidn = "040-01" or studyidn = "009-01";
run;

PROC print data= derived.imputedSet (obs = 30);run;


/*EXPORT IMPUTEDSET TO STATA*/
PROC EXPORT DATA= DERIVED.IMPUTEDSET 
            OUTFILE= "U:\STUDENT Nadya Golfenshtein\Dissertation\Data\De
rived\imputed20151001.dta" 
            DBMS=STATA REPLACE;
RUN;
