*Libname vetter 'C:\Users\amiagnoc\Vetter\Data';

data Vetter2;
infile 'C:\Users\amiagnoc\vetter\Data\vetter2.txt' dlm='09'x dsd missover firstobs=2;
input Id BL_Hepatic_Ins_Sens V2_Hepatic_Ins_Sens V3_Hepatic_Ins_Sens;
run;

/********************************************************************************************************/
/*																										*/
/*											PERCENT CHANGE ARRAY										*/
/*																										*/
/********************************************************************************************************/
data PChange (keep=Study_ID Visit Percent_Chng_Glu Percent_Chng_Ins);
infile'C:\Users\amiagnoc\vetter\Data\PercentChange.txt' dlm='09'x dsd missover firstobs=2;
input Study_ID	Pct_Chng_Glu_AUC_WtLoss	Pct_Chng_Glu_AUC_Ex9	Pct_Chng_Ins_AUC_WtLoss	Pct_Chng_Ins_AUC_Ex9;
Dummy=0;
Dummy2=0; 
array PCGA(*) dummy  Pct_Chng_Glu_AUC_WtLoss	Pct_Chng_Glu_AUC_Ex9;
array PCIA(*) dummy2 Pct_Chng_Ins_AUC_WtLoss	Pct_Chng_Ins_AUC_Ex9;
do i=1 to dim(PCGA);
	Percent_Chng_Glu=PCGA(i); Percent_Chng_Ins=PCIA(i);Visit=I;
	output PChange;
end;
run;

proc print data=PChange;
run;
/********************************************************************************************************/




proc print data=Vetter2;
run;

/*data vetter.vetter2;*/
/*	set vetter2;*/
/*run;*/
****************************************************************************************************************


-----Original Message-----
From: Vetter, Marion [mailto:Marion.Vetter@uphs.upenn.edu] 
Sent: Wednesday, October 09, 2013 6:02 AM
To: Chittams, Jesse
Subject: updated analytic plan

**************************************************************************************************

HI Jesse-

I finally reviewed the email that I had previously sent you and it looks like almost everything was there.
I added on more variable that I'd like to look at called beta cell function (Bcell_fxn), which I've calculated
for each visit (BL_Bcell_fxn for the baseline visit, V2_Bcell_fxn for the post-weight loss visit, V3_Bcell_function
for the post-weight loss visit with blockade of the GLP-1 receptor).  I've specified the additional comparisons in CAPS
below under the secondary analyses section.  Please let me know if this makes sense.

Primary analysis:
1) The change in glucose tolerance [defined as the glucose area under the curve (AUC)] between groups before (Baseline) and after
equivalent weight loss of 10% of initial body weight (Visit 2).  We hypothesized that individuals who underwent Roux-en-Y gastric
bypass (RYGB) would have greater improvements in glucose tolerance (i.e. greater change in glucose AUC) compared to those who lost
an equivalent amount of weight through lifestyle modification.  However, we did not find this to be the case.
2) The change in glucose tolerance (again glucose AUC) at the point of 10% weight loss without blockade of the GLP-1 receptor
(Visit 2) and with blockade of the GLP-1 receptor (Visit 3).  Note that we gave saline (placebo) and the GLP-1 receptor blocker
in random order during Visits 2 and 3.  For the purpose of the database, we entered the saline data under Visit 2 and the GLP-1
receptor blocker data under Visit 3.  We hypothesized that with GLP-1 receptor blockade, any improvements in glucose tolerance
that we expected to see with RYGB would be abolished.

Secondary analysis:
1) change in the GLP-1 response (defined as the GLP-1 AUC) between groups before and after equivalent weight loss.
2) change in the GLP-1 response (defined as the GLP-1 AUC) between groups before and after blockade of the GLP-1 receptor.
3) change in the insulin response (defined as the insulin AUC) between groups before and after equivalent weight loss.
4) change in the insulin response (defined as the insulin AUC) between groups before and after blockade of the GLP-1 receptor.
5) change in the glucagon response (defined as the glucagon AUC) between groups before and after equivalent weight loss.
6) change in the glucagon response (defined as the glucagon AUC) between groups before and after blockade of the GLP-1 receptor.
7) change in endogenous glucose production (defined as the EGP AUC) between groups before and after equivalent weight loss
8) CHANGE IN ENDOGENOUS GLUCOSE PRODUCTION BETWEEN GROUPS BEFORE AND AFTER BLOCKADE OF THE GLP-1 RECEPTOR
9) CHANGE IN BETA CELL FUNCTION (CALCULATED AS THE INSULIN AUC/GLUCOSE AUC) BETWEEN GROUPS BEFORE AND AFTER EQUIVALENT WEIGHT LOSS
10) CHANGE IN BETA CELL FUNCTION (CALCULATED AS THE INSULIN AUC/GLUCOSE AUC) BETWEEN GROUPS BEFORE AND AFTER BLOCKADE OF THE GLP-1 RECEPTOR

In addition to the changes in the AUCs, I would also like to compare changes in fasting and peak hormonal values both between and within groups.  For the mixed models, I recommend that we adjust for the following:

1) baseline weight
2) baseline HbA1c
3) duration of diabetes
4) number of diabetes medications (or we may just want to create a yes/no variable called "insulin use," with the rationale being
that patients who take insulin have more severe diabetes)

To ensure that we get the same results when we only include completers, I would like to do the mixed models under two sets of
conditions:
1) with all subjects (n=20)
2) with only the completers (n=16)

*********************************************************************************************************;

*Jesse's laptop;
Libname vetter 'C:\Users\chittams\Dropbox\Marion Vetter\GLP_1_MANUSCRIPT_2013\data\Derived';

*SON desktop;
Libname vetter 'U:\Marion Vetter\GLP_1_MANUSCRIPT_2013\data\Derived';

proc format;
value visit
	1="ZBaseline"
	2= "Visit 2"
	3= "Visit 3" ;

value visitn	
	1="ZBaseline"
	2= "Visit 2"
	3= "Visit 3" ;

 value group
	1= "Diet (nonsurgical)"
	3= "RYGB (surgical)   ";

run;

proc sort data=vetter.vetter; by study_id; run;


data vetter.vetter3;
     set vetter.vetter2;
	 rename id=study_id;
run;

proc sort data=vetter.vetter3;
         by study_id;
run;

proc sort data=vetter.glp1_add; by study_id; run;

proc print data=vetter.glp1_add;run;

proc contents data=vetter.glp1_add;
run;

proc contents data=vetter.vetter;
run;

proc print data=vetter.vetter;
run;





data long2 (keep= BL_A1c  BL_wt DM_duration Number_DM_meds
	study_id group age gender race DM_Duration Number_DM_Meds
	Weight A1c BMI Waist_Circum Days_10pct_WtLoss Days_Bt_V2_V3 Visit completer Fasting_Glu
	GGON_AUC BL_Insulin_any Bcell_fxn Fasting_GGON Fasting_GIP Fasting_GLP Fasting_Glu 
	Fasting_Ins GIP_AUC GLP_AUC Glu_AUC HOMA_IR Ins_AUC Mean_EGP Peak_GGON Peak_GIP
	Peak_GLP Peak_Glu Peak_Ins Hepatic_Ins DI Cpep_AUC Fasting_Cpep Glu_AUC_0_120 Glu_AUC_120_180
    ISI Ins_AUC_0_120 MISI_0_120 Ratio_Cpep_Ins_AUC);
	merge vetter.vetter vetter.vetter3 vetter.glp1_add;
	by study_id;

	DM_MEDS = 1*BL_Oral_DM_med + 
	          2*BL_Insulin_Only +
			  3*BL_Oral_Insulin;
	IF DM_MEDS NE  .  THEN BL_Insulin_any = DM_MEDS IN (2,3);

	array Wt(*) BL_wt V2_wt V3_wt;
	array Ac(*) BL_A1c V2_A1c V3_A1c;
	array BM(*)BL_BMI V2_BMI V3_BMI;
	array WC(*) BL_waist_circum V2_waist_circum V3_waist_circum;
	array FGlu(*) BL_Fasting_Glu V2_Fasting_Glu V3_Fasting_Glu;
	array CGON(*) BL_GGON_AUC V2_GGON_AUC V3_GGON_AUC;
	array Bcell(*) BL_Bcell_fxn V2_Bcell_fxn V3_Bcell_fxn;
	array FGGON(*) BL_Fasting_GGON V2_Fasting_GGON V3_Fasting_GGON;
	array FGIP(*) BL_Fasting_GIP V2_Fasting_GIP V3_Fasting_GIP;
	array FGLP(*) BL_Fasting_GLP V2_Fasting_GLP V3_Fasting_GLP;
	array FIns(*) BL_Fasting_Ins V2_Fasting_Ins V3_Fasting_Ins;
	array CGIP(*) BL_GIP_AUC V2_GIP_AUC V3_GIP_AUC;
	array CGLP(*) BL_GLP_AUC V2_GLP_AUC V3_GLP_AUC;
	array CGlu(*) BL_Glu_AUC V2_Glu_AUC V3_Glu_AUC;
	array HOMA(*) BL_HOMA_IR V2_HOMA_IR V3_HOMA_IR;
	array CIns(*) BL_Ins_AUC V2_Ins_AUC V3_Ins_AUC;
	array EGPM(*) BL_Mean_EGP V2_Mean_EGP V3_Mean_EGP;
	array PGON(*) BL_Peak_GGON V2_Peak_GGON V3_Peak_GGON;
	array PGIP(*) BL_Peak_GIP V2_Peak_GIP V3_Peak_GIP;
	array PGLP(*) BL_Peak_GLP V2_Peak_GLP V3_Peak_GLP;
	array PGlu(*) BL_Peak_Glu V2_Peak_Glu V3_Peak_Glu;
	array PIns(*) BL_Peak_Ins V2_Peak_Ins V3_Peak_Ins;
	/*below change or add*/
	array HepIn(*) BL_Hepatic_Ins_Sens V2_Hepatic_Ins_Sens V3_Hepatic_Ins_Sens;
	array Cpep(*) BL_Cpep_AUC V2_Cpep_AUC V3_Cpep_AUC;
	array DIn(*) BL_DI V2_DI V3_DI;	
	array FCpep(*) BL_Fasting_Cpep V2_Fasting__Cpep V3_Fasting_Cpep;
	array GluAUC120 (*) BL_Glu_AUC_0_120 V2_Glu_AUC_0_120 V3_Glu_AUC_0_120;
	array GluAUC120_180 (*) BL_Glu_AUC_120_180 V2_Glu_AUC_120_180 V3_Glu_AUC_120_180;
	array ISIn (*) BL_ISI V2_ISI V3_ISI;
	array InsAUC120 (*) BL_Ins_AUC_0_120 V2_Ins_AUC_0_120 V3_Ins_AUC_0_120;
	array MISI (*) BL_MISI_0_120 V2_MISI_0_120 V3_MISI_0_120;
	array Cpep_Ins (*) BL_Ratio_Cpep_Ins_AUC V2_Ratio_Cpep_Ins_AUC V3_Ratio_Cpep_Ins_AUC;
		*condition = group;
		*subject = study_id;
		do i=1 to dim(wt);
			Weight=Wt(i); A1c=Ac(i); BMI=BM(i); Waist_Circum= WC(i); Fasting_Glu= FGlu(i); GGON_AUC= CGON(I); Bcell_fxn= Bcell(i);
			Fasting_GGON= FGGON(i); Fasting_GIP= FGIP(i); Fasting_GLP= FGLP(i); Fasting_Ins= FIns(i); GIP_AUC= CGIP(i);
			GLP_AUC= CGLP(i); Glu_AUC= CGlu(i); HOMA_IR= HOMA(i); Ins_AUC= CIns(i); Mean_EGP=EGPM(i); Peak_GGON= PGON(i); Peak_GIP=PGIP(i);
			Peak_GLP= PGLP(i); Peak_Glu= PGlu(i); Peak_Ins= PIns(i); 
            Hepatic_Ins=HepIn(i); Cpep_AUC=Cpep(i);DI=DIn(i); Fasting_Cpep=FCpep(i);Glu_AUC_0_120=GluAUC120(i);
            Glu_AUC_120_180=GluAUC120_180(i);ISI=ISIn (i);Ins_AUC_0_120=InsAUC120(i); MISI_0_120=MISI(i);
             Ratio_Cpep_Ins_AUC=Cpep_Ins(i);
             Visit=I; 
			output long2;
		end;
		
run;

proc sort data=long2;
       by study_id visit;
run;

proc print data=long2;
run;

/*proc print data=long2; */
/*var study_id visit di Cpep_AUC Fasting_Cpep Glu_AUC_0_120 Glu_AUC_120_180*/
/*    ISI Ins_AUC_0_120 MISI_0_120 Ratio_Cpep_Ins_AUC;*/
/*run;*/
/**/
/*data vetter.long3;*/
/*	set long2;*/
/*	format visit visit. group group.;*/
/*run;*/
/********************************************************************************************************/
/*																										*/
/*											MERGE PERCENT &												*/
/*											New Mixed SAS Data set										*/
/*																										*/
/********************************************************************************************************/

/*proc sort data=vetter.pchange;*/
/*	by Study_ID visit;*/
/*run;*/
/*proc sort data=vetter.long3;*/
/*	by Study_ID visit;*/
/*run;*/
/**/
/**/
/*data merged;*/
/*	merge vetter.long3 vetter.pchange; */
/*	by Study_ID visit;*/
/*run;*/
/**/
/*proc print data=vetter.merged;*/
/*run;*/

/*data vetter.mixed;*/
/*	set vetter.merged;*/
/*	format visit visit. group group.;*/
/*run;*/

data vetter.perchange;
     set vetter.mixed;
	 keep study_id visit Percent_Chng_Glu Percent_Chng_Ins GLP2_AUC Peak_GLP2 Fasting_GLP2;
run;

proc print data=vetter.perchange;
run;

data vetter.mergedadd;
     merge long2 vetter.perchange;
	 by study_id visit;
	 format visit visit. group group.;
run;



proc print data=vetter.mergedadd order=formatted ;
	where visit = 1;
     var study_id visit Percent_Chng_Glu Percent_Chng_Ins;
run;

 
proc freq data=vetter.mergedadd order=formatted ;
	where visit = 1;
     tables visit;
run;

 


/***********************************************************************************************************/



/*proc contents data=vetter.vetter short; run;*/

*BL_A1c BL_BMI BL_Bcell_fxn BL_Fasting_GGON BL_Fasting_GIP BL_Fasting_GLP BL_Fasting_Glu BL_Fasting_Ins BL_GGON_AUC BL_GIP_AUC
BL_GLP_AUC BL_Glu_AUC BL_HOMA_IR BL_Ins_AUC BL_Insulin_Only BL_Mean_EGP BL_Oral_DM_med BL_Oral_Insulin BL_Peak_GGON BL_Peak_GIP
BL_Peak_GLP BL_Peak_Glu BL_Peak_Ins BL_waist_circum BL_wt Completer DM_duration Days_10Pct_WtLoss Days_bt_V2_V3 Number_DM_meds
V2_A1c V2_BMI V2_Bcell_fxn V2_Fasting_GGON V2_Fasting_GIP V2_Fasting_GLP V2_Fasting_Glu V2_Fasting_Ins V2_GGON_AUC V2_GIP_AUC
V2_GLP_AUC V2_Glu_AUC V2_HOMA_IR V2_Ins_AUC V2_Insulin_Only V2_Mean_EGP V2_Off_DM_meds V2_Oral_Insulin V2_Oral_Meds_Only
V2_Peak_GGON V2_Peak_GIP V2_Peak_GLP V2_Peak_Glu V2_Peak_Ins V2_waist_circum V2_wt V3_BMI V3_Bcell_fxn V3_Fasting_GGON
V3_Fasting_GIP V3_Fasting_GLP V3_Fasting_Glu V3_Fasting_Ins V3_GGON_AUC V3_GIP_AUC V3_GLP_AUC V3_Glu_AUC V3_HOMA_IR V3_Ins_AUC
V3_Mean_EGP V3_Peak_GGON V3_Peak_GIP V3_Peak_GLP V3_Peak_Glu V3_Peak_Ins V3_waist_circum V3_wt _merge age gender group male_yn
race study_ID;

/*proc freq data=Vetter; */
/*	tables BL_Insulin_any BL_A1c  BL_wt DM_duration ;*/
/*run;*/

/*PROC PRINT DATA=VETTER;*/
/*VAR STUDY_ID COMPLETER;*/
/*RUN;*/


/*proc print data=mixed;*/
/*	var visit weight group ;*subject study_id a1c bmi waist_circum;*/
/*run;*/

/*ods rtf file='C:\Users\amiagnoc\Vetter\Documents\Long2Contents.rtf';*/
/*proc contents data=long2;*/
/*run;*/
/*ods rtf close;*/
/**/
/*ods rtf file='C:\Users\amiagnoc\Vetter\Documents\Long2Means.rtf';*/
/*proc means data=long2;*/
/*	class visit;*/
/*run;*/
 




 %macro mixW(y,x,z,titl,wher);
*********************************************************************************************************;
***|  Final model;  *with this marco the original outcome variable is included and estimate
 statements are used to compare the change scores over time;
*********************************************************************************************************;
ods select  /*ModelInfo*/ Tests3   estimates lsmeans;
  *ods trace on/listing;
proc mixed data=vetter.mergedadd   ORDER = FORMATTED; *WHERE WEIGHT_IN_WIND_EIGHTWKWIND = 1; &wher;
    class   visit group study_id &x; 
    model  &y = visit|group  &x &z/ solution OUTPRED=pred RESIDUAL E;* black_white;
      repeated visit/subject =study_id type=un; 
    title1 'Addition mixed model OUTCOMES TABLE';
    title2 "Outcome variable: &y | &titl"; 
    lsmeans visit*group;
    *lsmeans group  visit visit*group   ;

	ESTIMATE 'V2 vs BL'
		visit 1  0 -1; 
	ESTIMATE 'V3 vs BL'
		visit 0 1  -1; 
	ESTIMATE 'V3 vs V2'
		visit -1 1  0; 
	ESTIMATE 'DIET vs RYGB'
		group 1 -1; 

	ESTIMATE 'DIET CHNGE from BL to V2'  
    	 visit 1 0 -1   visit*group  1 0 0 0 -1 0/e; 
		 
	ESTIMATE 'RYGB CHNGE from BL to V2'  
    	 visit 1 0 -1   visit*group  0 1 0 0  0 -1/e; 
		 
	ESTIMATE 'DIET BL-V2 chnge vs. RYGB BL-V2 chnge'  
    	  	visit*group 1 -1 0 0 -1 1; 

	ESTIMATE 'DIET CHNGE from V2 to V3'  
    	 visit -1 1 0   visit*group  -1 0 1 0 0 0/e; 
		 
	ESTIMATE 'RYGB CHNGE from V2 to V3'  
    	 visit -1 1 0  visit*group 0 -1 0 1 0 0/e; 
		 
	ESTIMATE 'DIET V2-V3 chnge vs. RYGB V2-V3 chnge'  
    	  	visit*group -1 1 1 -1 0 0; 
	*ods output estimates=estimates lsmeans=lsmeans;
	*output r=residual;
quit;  

%MEND;

%macro mixpc(y,x,z,titl,wher);
*********************************************************************************************************;
***|  Final model;  *with this marco the original outcome variable is included and estimate
 statements are used to compare the change scores over time;
*********************************************************************************************************;
ods select  /*ModelInfo*/ Tests3   lsmeans diffs;
  *ods trace on/listing;
proc mixed data=vetter.mergedadd   ORDER = FORMATTED; *WHERE WEIGHT_IN_WIND_EIGHTWKWIND = 1; &wher;
    class   visit group study_id &x; 
    model  &y = visit|group  &x &z/ solution OUTPRED=pred RESIDUAL E;* black_white;
      repeated visit/subject =study_id type=un; 
    title1 'Addition mixed model OUTCOMES TABLE';
    title2 "Outcome variable: &y | &titl"; 
    lsmeans visit group visit*group/diffs ;
    *lsmeans group  visit visit*group   ;

quit;  
title ;

%MEND;



ods rtf file="U:\Marion Vetter\GLP_1_MANUSCRIPT_2013\documents\output\mixed_model_anal_update1_&sysdate..rtf" style=journal;

 footnote 'U:\Marion Vetter\GLP_1_MANUSCRIPT_2013\programs\Draft\7-10-14.sas';
OPTIONS PAGENO = 1;

	%mixW(Weight	, , , Mixed model with no covariates | ITT,  ); 
	%mixW(Weight	, ,BL_A1c /* BL_wt */DM_duration BL_Insulin_any, Mixed model with covariates | ITT,  ); 
	%mixW(Weight	, , , Mixed model with no covariates |Completers only,where Completer = 1 ); 

	%mixW(BMI	, , , Mixed model with no covariates | ITT,  ); 
	%mixW(BMI	, ,BL_A1c  BL_wt DM_duration BL_Insulin_any, Mixed model with covariates | ITT,  ); 
	%mixW(BMI	, , , Mixed model with no covariates |Completers only,where Completer = 1 ); 

	%mixW(A1c	, , , Mixed model with no covariates | ITT,  ); 
	%mixW(A1c	, ,BL_A1c  BL_wt DM_duration BL_Insulin_any, Mixed model with covariates | ITT,  ); 
	%mixW(A1c	, , , Mixed model with no covariates |Completers only,where Completer = 1 ); 

	  
	%mixW(Waist_Circum	, , , Mixed model with no covariates | ITT,  ); 
	%mixW(Waist_Circum	, ,BL_A1c  BL_wt DM_duration BL_Insulin_any, Mixed model with covariates | ITT,  ); 
	%mixW(Waist_Circum	, , , Mixed model with no covariates |Completers only,where Completer = 1 ); 

	%mixW(Fasting_Glu	, , , Mixed model with no covariates | ITT,  ); 
	%mixW(Fasting_Glu	, ,BL_A1c  BL_wt DM_duration BL_Insulin_any, Mixed model with covariates | ITT,  ); 
	%mixW(Fasting_Glu	, , , Mixed model with no covariates |Completers only,where Completer = 1 ); 

	%mixW(GGON_AUC	, , , Mixed model with no covariates | ITT,  ); 
	%mixW(GGON_AUC	, ,BL_A1c  BL_wt DM_duration BL_Insulin_any, Mixed model with covariates | ITT,  ); 
	%mixW(GGON_AUC	, , , Mixed model with no covariates |Completers only,where Completer = 1 ); 

	%mixW(Bcell_fxn	, , , Mixed model with no covariates | ITT,  ); 
	%mixW(Bcell_fxn	, ,BL_A1c  BL_wt DM_duration BL_Insulin_any, Mixed model with covariates | ITT,  ); 
	%mixW(Bcell_fxn	, , , Mixed model with no covariates |Completers only,where Completer = 1 ); 

	%mixW(Fasting_GGON	, , , Mixed model with no covariates | ITT,  ); 
	%mixW(Fasting_GGON	, ,BL_A1c  BL_wt DM_duration BL_Insulin_any, Mixed model with covariates | ITT,  ); 
	%mixW(Fasting_GGON	, , , Mixed model with no covariates |Completers only,where Completer = 1 ); 

	%mixW(Fasting_GIP	, , , Mixed model with no covariates | ITT,  ); 
	%mixW(Fasting_GIP	, ,BL_A1c  BL_wt DM_duration BL_Insulin_any, Mixed model with covariates | ITT,  ); 
	%mixW(Fasting_GIP	, , , Mixed model with no covariates |Completers only,where Completer = 1 ); 

	%mixW(Fasting_GLP	, , , Mixed model with no covariates | ITT,  ); 
	%mixW(Fasting_GLP	, ,BL_A1c  BL_wt DM_duration BL_Insulin_any, Mixed model with covariates | ITT,  ); 
	%mixW(Fasting_GLP	, , , Mixed model with no covariates |Completers only,where Completer = 1 ); 

	%mixW(Fasting_Ins	, , , Mixed model with no covariates | ITT,  ); 
	%mixW(Fasting_Ins	, ,BL_A1c  BL_wt DM_duration BL_Insulin_any, Mixed model with covariates | ITT,  ); 
	%mixW(Fasting_Ins	, , , Mixed model with no covariates |Completers only,where Completer = 1 ); 

	%mixW(GIP_AUC	, , , Mixed model with no covariates | ITT,  ); 
	%mixW(GIP_AUC	, ,BL_A1c  BL_wt DM_duration BL_Insulin_any, Mixed model with covariates | ITT,  ); 
	%mixW(GIP_AUC	, , , Mixed model with no covariates |Completers only,where Completer = 1 ); 

	%mixW(GLP_AUC	, , , Mixed model with no covariates | ITT,  ); 
	%mixW(GLP_AUC	, ,BL_A1c  BL_wt DM_duration BL_Insulin_any, Mixed model with covariates | ITT,  ); 
	%mixW(GLP_AUC	, , , Mixed model with no covariates |Completers only,where Completer = 1 ); 

	%mixW(Glu_AUC	, , , Mixed model with no covariates | ITT,  ); 
	%mixW(Glu_AUC	, ,BL_A1c  BL_wt DM_duration BL_Insulin_any, Mixed model with covariates | ITT,  ); 
	%mixW(Glu_AUC	, , , Mixed model with no covariates |Completers only,where Completer = 1 ); 

	%mixW(HOMA_IR	, , , Mixed model with no covariates | ITT,  ); 
	%mixW(HOMA_IR	, ,BL_A1c  BL_wt DM_duration BL_Insulin_any, Mixed model with covariates | ITT,  ); 
	%mixW(HOMA_IR	, , , Mixed model with no covariates |Completers only,where Completer = 1 ); 

	%mixW(Ins_AUC	, , , Mixed model with no covariates | ITT,  ); 
	%mixW(Ins_AUC	, ,BL_A1c  BL_wt DM_duration BL_Insulin_any, Mixed model with covariates | ITT,  ); 
	%mixW(Ins_AUC	, , , Mixed model with no covariates |Completers only,where Completer = 1 ); 

	%mixW(Mean_EGP	, , , Mixed model with no covariates | ITT,  ); 
	%mixW(Mean_EGP	, ,BL_A1c  BL_wt DM_duration BL_Insulin_any, Mixed model with covariates | ITT,  ); 
	%mixW(Mean_EGP	, , , Mixed model with no covariates |Completers only,where Completer = 1 ); 
	
	%mixW(Peak_GGON	, , , Mixed model with no covariates | ITT,  ); 
	%mixW(Peak_GGON	, ,BL_A1c  BL_wt DM_duration BL_Insulin_any, Mixed model with covariates | ITT,  ); 
	%mixW(Peak_GGON	, , , Mixed model with no covariates |Completers only,where Completer = 1 ); 
	
	%mixW(Peak_GIP	, , , Mixed model with no covariates | ITT,  ); 
	%mixW(Peak_GIP	, ,BL_A1c  BL_wt DM_duration BL_Insulin_any, Mixed model with covariates | ITT,  ); 
	%mixW(Peak_GIP	, , , Mixed model with no covariates |Completers only,where Completer = 1 ); 
	
	%mixW(Peak_GLP	, , , Mixed model with no covariates | ITT,  ); 
	%mixW(Peak_GLP	, ,BL_A1c  BL_wt DM_duration BL_Insulin_any, Mixed model with covariates | ITT,  ); 
	%mixW(Peak_GLP	, , , Mixed model with no covariates |Completers only,where Completer = 1 ); 
	
	%mixW(Peak_Glu	, , , Mixed model with no covariates | ITT,  ); 
	%mixW(Peak_Glu	, ,BL_A1c  BL_wt DM_duration BL_Insulin_any, Mixed model with covariates | ITT,  ); 
	%mixW(Peak_Glu	, , , Mixed model with no covariates |Completers only,where Completer = 1 ); 
	
	%mixW(Peak_Ins	, , , Mixed model with no covariates | ITT,  ); 
	%mixW(Peak_Ins	, ,BL_A1c  BL_wt DM_duration BL_Insulin_any, Mixed model with covariates | ITT,  ); 
	%mixW(Peak_Ins	, , , Mixed model with no covariates |Completers only,where Completer = 1 ); 
	
	%mixW(Hepatic_Ins	, , , Mixed model with no covariates | ITT,  ); 
	%mixW(Hepatic_Ins	, ,BL_A1c  BL_wt DM_duration BL_Insulin_any, Mixed model with covariates | ITT,  ); 
	%mixW(Hepatic_Ins	, , , Mixed model with no covariates |Completers only,where Completer = 1 );

	/*											NEW ADDITION TO MACRO 12/2									*/
/*																										*/
/********************************************************************************************************/
	%mixW(GLP2_AUC	, , , Mixed model with no covariates | ITT,  ); 
	%mixW(GLP2_AUC	, ,BL_A1c  BL_wt DM_duration BL_Insulin_any, Mixed model with covariates | ITT,  ); 
	%mixW(GLP2_AUC	, , , Mixed model with no covariates |Completers only,where Completer = 1 );

	%mixW(Fasting_GLP2	, , , Mixed model with no covariates | ITT,  ); 
	%mixW(Fasting_GLP2	, ,BL_A1c  BL_wt DM_duration BL_Insulin_any, Mixed model with covariates | ITT,  ); 
	%mixW(Fasting_GLP2	, , , Mixed model with no covariates |Completers only,where Completer = 1 );

	%mixW(Peak_GLP2	, , , Mixed model with no covariates | ITT,  ); 
	%mixW(Peak_GLP2	, ,BL_A1c  BL_wt DM_duration BL_Insulin_any, Mixed model with covariates | ITT,  ); 
	%mixW(Peak_GLP2	, , , Mixed model with no covariates |Completers only,where Completer = 1 );



%mixW(Cpep_AUC	, , , Mixed model with no covariates | ITT,  ); 
	%mixW(Cpep_AUC	, ,BL_A1c  BL_wt DM_duration BL_Insulin_any, Mixed model with covariates | ITT,  ); 
	%mixW(Cpep_AUC	, , , Mixed model with no covariates |Completers only,where Completer = 1 );

%mixW(DI	, , , Mixed model with no covariates | ITT,  ); 
	%mixW(DI	, ,BL_A1c  BL_wt DM_duration BL_Insulin_any, Mixed model with covariates | ITT,  ); 
	%mixW(DI	, , , Mixed model with no covariates |Completers only,where Completer = 1 );

%mixW(Fasting_Cpep	, , , Mixed model with no covariates | ITT,  ); 
	%mixW(Fasting_Cpep	, ,BL_A1c  BL_wt DM_duration BL_Insulin_any, Mixed model with covariates | ITT,  ); 
	%mixW(Fasting_Cpep	, , , Mixed model with no covariates |Completers only,where Completer = 1 );

%mixW(Glu_AUC_0_120	, , , Mixed model with no covariates | ITT,  ); 
	%mixW(Glu_AUC_0_120	, ,BL_A1c  BL_wt DM_duration BL_Insulin_any, Mixed model with covariates | ITT,  ); 
	%mixW(Glu_AUC_0_120	, , , Mixed model with no covariates |Completers only,where Completer = 1 );

%mixW(Glu_AUC_120_180	, , , Mixed model with no covariates | ITT,  ); 
	%mixW(Glu_AUC_120_180	, ,BL_A1c  BL_wt DM_duration BL_Insulin_any, Mixed model with covariates | ITT,  ); 
	%mixW(Glu_AUC_120_180	, , , Mixed model with no covariates |Completers only,where Completer = 1 );

%mixW(ISI	, , , Mixed model with no covariates | ITT,  ); 
	%mixW(ISI	, ,BL_A1c  BL_wt DM_duration BL_Insulin_any, Mixed model with covariates | ITT,  ); 
	%mixW(ISI	, , , Mixed model with no covariates |Completers only,where Completer = 1 );

%mixW(Ins_AUC_0_120	, , , Mixed model with no covariates | ITT,  ); 
	%mixW(Ins_AUC_0_120	, ,BL_A1c  BL_wt DM_duration BL_Insulin_any, Mixed model with covariates | ITT,  ); 
	%mixW(Ins_AUC_0_120	, , , Mixed model with no covariates |Completers only,where Completer = 1 );

%mixW(MISI_0_120 	, , , Mixed model with no covariates | ITT,  ); 
	%mixW(MISI_0_120 	, ,BL_A1c  BL_wt DM_duration BL_Insulin_any, Mixed model with covariates | ITT,  ); 
	%mixW(MISI_0_120 , , , Mixed model with no covariates |Completers only,where Completer = 1 );


%mixW(Ratio_Cpep_Ins_AUC, , , Mixed model with no covariates | ITT,  ); 
	%mixW(Ratio_Cpep_Ins_AUC	, ,BL_A1c  BL_wt DM_duration BL_Insulin_any, Mixed model with covariates | ITT,  ); 
	%mixW(Ratio_Cpep_Ins_AUC	, , , Mixed model with no covariates |Completers only,where Completer = 1 );


ods rtf close;


ods rtf file="U:\Marion Vetter\GLP_1_MANUSCRIPT_2013\documents\output\mixed_model_anal_update2_&sysdate..rtf" style=journal;

 footnote 'U:\Marion Vetter\GLP_1_MANUSCRIPT_2013\programs\Draft\7-10-14.sas';
OPTIONS PAGENO = 1;

/*************************************************************************************************************************/
/*            percent change                                                                                      */

	%mixpc(Percent_Chng_Ins	, , , Mixed model with no covariates | ITT, where visit ne 1  ); 
	%mixpc(Percent_Chng_Ins	, ,BL_A1c  BL_wt DM_duration BL_Insulin_any, Mixed model with covariates | ITT, where visit ne 1 ); 
	%mixpc(Percent_Chng_Ins	, , , Mixed model with no covariates |Completers only,where Completer = 1 and visit ne 1 );

	%mixpc(Percent_Chng_Glu	, , , Mixed model with no covariates | ITT,  ); 
	%mixpc(Percent_Chng_Glu	, ,BL_A1c  BL_wt DM_duration BL_Insulin_any, Mixed model with covariates | ITT,where visit ne 1  ); 
	%mixpc(Percent_Chng_Glu	, , , Mixed model with no covariates |Completers only,where Completer = 1 and visit ne 1 );


/******************************************************************************************************/
/*     no visit 3 data for A1c                                                                              */
%mixpc(a1c	, , , Mixed model with no covariates | ITT, where visit ne 3  ); 
    %mixpc(a1c	, , BL_wt DM_duration BL_Insulin_any, Mixed model with covariates | ITT,where visit ne 3  ); 
	%mixpc(a1c	, , , Mixed model with no covariates |Completers only,where Completer = 1 and visit ne 3 );

ods rtf close;







/**/
/*/*  BELOW THIS LINE IS OLD CODE THAT  IS NOTE CURRENTLY NEEDED*/
/**/
/**ods trace off;*/
/*/**/*/
/*/*PROC SORT DATA = LSMEANS; BY visit group; QUIT;*/*/
/*/**/*/
/*/*proc print data=lsmeans(drop = DF   tValue   ) label;*/*/
/*/* 	where effect = 'visit*group';*/*/
/*/*	 var visit group Estimate StdErr ;*/*/
/*/*    label Probt = 'p-value';*/*/
/*/*    title3 'Model based means'; */*/
/*/*	format estimate stderr  lower upper 8.2 group GROUP. format visit visitn.;*/*/
/*/*quit;  */*/
/*/**/*/
/*/*data estimates;*/*/
/*/*	set estimates;*/*/
/*/*	obs = _n_;*/*/
/*/*run;*/*/
/*/**/*/
/*/*proc print data=estimates(drop = DF   tValue  Alpha   ) label noobs;*/*/
/*/*    label Probt = 'p-value'; where obs < 13; */*/
/*/*	var obs label estimate stderr lower upper;*/*/
/*/*    title3 'Esimated change from BL';*/*/
/*/*	format estimate stderr  lower upper 8.2;*/*/
/*/*quit;*/*/
/*/**/*/
/*/*proc print data=estimates (drop = DF   tValue  Alpha) label noobs; */*/
/*/*    where obs > 12; */*/
/*/*    label Probt = 'p-value'; */*/
/*/*	var obs label estimate stderr probt lower upper;*/*/
/*/*    title3 'Pair-wise Comparisons';	*/*/
/*/*	format estimate stderr  lower upper 8.2;*/*/
/*/*quit; */*/
/**/
/**/
/*/*PROC UNIVARIATE DATA=PRED NORMAL;*/*/
/*/*VAR  StudentResid;*/*/
/*/*HISTOGRAM;*/*/
/*/*TITLE3 'Residual analysis';*/*/
/*/*QUIT;*/*/
/**/
/**/
/**/
/**/
/*data long1(keep=study_id group age gender race DM_Duration Number_DM_Meds BaseLine Visit2 Visit3  Days_10pct_WtLoss Days_Bt_V2_V3);*/
/* set vetter.vetter;*/
/* array BL(*) BL_wt BL_A1c BL_BMI BL_Waist_circum;*/
/* array V2(*) V2_wt V2_A1c V2_BMI V2_waist_circum;*/
/* array V3(*) V3_wt V3_A1c V3_BMI V3_waist_circum;*/
/* 	do i=1 to dim(BL);*/
/* 		BaseLine= BL(i); Visit2=V2(i); Visit3=V3(i); output long1;*/
/*	end;*/
/*run;*/
/**/
/*data vetter.long1;*/
/*	set long1;*/
/*run;*/
/**/
/*proc print data=long1;*/
/* run;*/
/**/
/*ods rtf file='C:\Users\amiagnoc\Vetter\Documents\Long1Contents.rtf';*/
/*proc contents data=long1;*/
/*run;*/
/*ods rtf close;*/
/**/
/*ods rtf file='C:\Users\amiagnoc\Vetter\Documents\Long1Means.rtf';*/
/*proc means data=long1;*/
/*class Days_10pct_WtLoss;*/
/*run;*/
/**/
/*proc means data=long1;*/
/*class Days_Bt_V2_V3;*/
/*run;*/
/*ods rtf close;*/
/**/
/**/
/** outcome SI needs more digits behind the decimal place;*/
/*%macro mixC1c(y,x,z,titl,wher);*/
/*ods select Tests3 ;*/
/*data lsmeans; data diffs; run;*/
/*proc mixed data=analysis noclprint ORDER=FORMATTED; *ORDER=INTERNAL; */
/*&wher;*/
/*    class   weeks condition subject &z;*/
/*    model  &y = weeks|condition   &x &z/OUTPRED=pred RESIDUAL;*/
/*    lsmeans weeks condition weeks*condition /diffs cl;*/
/*    repeated weeks/subject =SUBJECT type=un;*/
/*    ods output lsmeans=lsmeans diffs=diffs;     */
/*    title1 "Julio's Paper ";*/
/*    title2 "&y | &titl";*/
/*quit;  */
/* */
/*/*Residual analysis;*/*/
/*/*proc univariate data=pred normal plot;*/*/
/*/*	var StudentResid;*/*/
/*/*run;*/*/
/**/
/*/**/
/*PROC SORT DATA = LSMEANS; BY weeks CONDITION; QUIT;*/
/*proc print data=lsmeans(drop = DF   tValue  Alpha ) label ; *NOOBS;*/
/* 	*where effect = 'weeks*Condition';*/
/*	 var weeks condition Estimate StdErr  Lower  Upper Probt;*/
/*    label Probt = 'P-value';*/
/*    title3 'Estimated Change from Baseline'; */
/*	format estimate stderr  lower upper 8.4 ;*/
/*quit;  */
/**/
/*PROC SORT DATA=DIFFS; BY weeks CONDITION  _condition; QUIT;*/
/*proc print data=diffs (drop = DF   tValue  Alpha); * NOOBS label; */
/*   where weeks = _weeks and effect not = 'condition';* or effect  = 'weeks';  */
/*   *where weeks = _weeks ; */
/*    label Probt = 'P-value';*/
/*    title3 'Pairwise Comparisons';	*/
/*	var  weeks  condition _weeks  _condition Estimate StdErr Probt  Lower  Upper;*/
/*	format estimate stderr  lower upper 8.4;* CONDITION  _condition GROUP.;*/
/*quit; */
/**/
/**/
/*%MEND;  */
/**/
/**/*/
/**/
/**/
/*data bio1;*/
/*	set bio2;*/
/*	by subject; */
/*	retain bl_Adiponectin;*/
/*	if first.subject and weeks=0 then bl_Adiponectin = Adiponectin;*/
/*	Change_Adiponectin = Adiponectin - bl_Adiponectin; */
/**/
/*	retain bl_IL6;*/
/*	if first.subject then bl_IL6 = IL6;*/
/*	Change_IL6 = IL6 - bl_IL6;*/
/**/
/*	log_Il6 = log(IL6);*/
/*	retain log_bl_IL6;*/
/*	if first.subject then log_bl_IL6 = log_IL6;*/
/*	Change_log_IL6 = log_IL6 - log_bl_IL6;*/
/* */
/*	retain bl_Leptin ;*/
/*	if first.subject then bl_Leptin  = Leptin;*/
/*	Change_Leptin  = Leptin - bl_Leptin ; */
/**/
/*	retain bl_PIIINP;*/
/*	if first.subject then bl_PIIINP = PIIINP;*/
/*	Change_PIIINP = PIIINP - bl_PIIINP; */
/**/
/*	retain bl_Resistin;*/
/*	if first.subject then bl_Resistin = Resistin;*/
/*	Change_Resistin = Resistin - bl_Resistin; */
/**/
/*	if weeks = 0 then delete;*/
/*	subj = id;*/
/*run;*/
/**/
/**QA TO CONFIRM THAT THE OUTCOME VARIABLE WAS CREATED CORRECTLY;*/
/*proc print data=bio1; */
/*	var id weeks Change_Adiponectin Adiponectin bl_Adiponectin;  */
/*run;*/
/*proc print data=bio1; */
/*	var id weeks Change_log_IL6 log_Il6 log_bl_IL6 IL6  bl_IL6;*/
/*run; *lots of missing data but the change values are correct;*/
/**/
/*proc print data=bio1; */
/*	var id weeks Change_IL6 IL6  bl_IL6;*/
/*run; *lots of missing data but the change values are correct;*/
/**/
/**/
/**/
/* */
/**variables needed in the call statements: Change_Blooddias Change_Bloodsys Change_HeartRat Change_WaistSiz Change_Weight Change_BMI;*/
/**ods rtf file="C:\Users\chittams\Dropbox\son\Julio Chirinos\Paper_Fall_2012\documents\output\tono analysis results &sysdate..rtf" style=journal;*/
/*ods rtf file="U:\Julio Chirinos\Paper_Fall_2012\documents\output\biomarker signs residual analysis results with week 16 &sysdate..rtf" style=journal;*/
/**/
/* footnote 'program:son\Julio Chirinos\Paper_Fall_2012\programs\Draft\biomarker_analysis.sas';*/
/*OPTIONS PAGENO = 1;*/
/**/
/*/*call 1*/ 	%mixC1b(Change_Adiponectin ,  ,  ,  OUTCOME: bio Adiponectin CHANGE SCORE| ITT, );*/
/*/*call 2*/ 	%mixC1b(Change_Adiponectin ,  ,  ,  OUTCOME: bio Adiponectin CHANGE SCORE- where compliant=1, where compliant = 1 );*/
/**/
/**/
/**/
/**/
/**/
