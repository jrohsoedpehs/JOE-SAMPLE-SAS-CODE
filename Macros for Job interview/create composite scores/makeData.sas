libname raw "Q:\STUDENT Stefanie Zavodny\Dissertation\data\raw";
libname derived "Q:\STUDENT Stefanie Zavodny\Dissertation\data\Derived";
footnote "Q:\STUDENT Stefanie Zavodny\Dissertation\programs\Draft\makeData.sas";
/*options fmtsearch=(redcap.nursing_formats raw.chop_formats);*/
options nofmterr;

/*Macros to create and QA sum and mean scores and avoid repetitive code*/
%include "Q:\STUDENT Stefanie Zavodny\Dissertation\programs\Draft\macro_create_composite_scores.sas";

/*Goals*/
/*merge the derived chop and raw nursing*/

/*format group, yesno and fad_function*/
/*Assigning a format to trt will break Jean's macro*/
PROC FORMAT ;
/*This format will crash the Table 1 macro*/
	value yesno_
		1 = "Yes"
		0 = "No";
	value fad_function_
		1= "normal"
		0= "worse";
	value yesnoother_
		0 = "No"
		1 = "Yes"
		2 = "Other";
run;

/*Stefanie asked us to remove these ids*/
/*We used StatTransfer to import the dataset IDsToKeep to SAS in the following subdirectory*/
/*Q:\STUDENT Stefanie Zavodny\Dissertation\archive\archive20180913 Data from Stefanie*/

proc contents data=raw.IDsToKeep varnum;run;
proc print data= raw.IDsToKeep;run;

/*IDs to keep in Nursing dataset*/
data derived.IDsToKeepNursing;
set raw.IDsToKeep (keep=Penn_Redcap_Record_ID KEEP);
where KEEP = 1 ;
record_id_num = Penn_Redcap_Record_ID ;
run;

data derived.nursing1;
set raw.nursing;
/*format record_id to num and match format of record id in derived.IDsToKeepNursing*/
record_id_num = record_id * 1;
run;

/*Merge raw.nursing with IDsToKeepNursing to remove sample and duplicate data*/
proc sort data= derived.nursing1;by record_id_num;run;
proc sort data= derived.IDsToKeepNursing;by record_id_num;run;
data derived.nursing2;
	merge derived.IDsToKeepNursing(in=a) derived.nursing1(in=b);
	by record_id_num;
	if a=1 and b=1;
	if Penn_Redcap_Record_ID = . then delete;
run;

/*proc print data=derived.nursing2;run;*/

/*IDs to keep in CHOP dataset*/
data derived.IDsToKeepCHOP;
set raw.IDsToKeep (keep= CHOP_Redcap_Record_ID KEEP);
where KEEP = 1;
depression_study_id=CHOP_Redcap_Record_ID;
run;

/*Merge xxx with IDsToKeepCHOP to remove sample and duplicate data*/
proc sort data= raw.dissertation_chop;by depression_study_id;run;
proc sort data= derived.IDsToKeepCHOP;by depression_study_id;run;

/*proc contents data= derived.IDsToKeepCHOP varnum;run;*/
proc contents data= raw.dissertation_chop varnum;run;

data derived.dissertation_chop;
	merge derived.IDsToKeepCHOP(in=c) raw.dissertation_chop(in=d);
	by depression_study_id;
	if c=1 and d=1;

	/*Clean FAD vars before creating score*/

	/*SET 0 TO MISSING IN FAD so they don't affect the scoring*/
	if fad_q01 = 0 then fad_q01 = . ;
	if fad_q02 = 0 then fad_q02 = . ;
	if fad_q03 = 0 then fad_q03 = . ;
	if fad_q04 = 0 then fad_q04 = . ;
	if fad_q05 = 0 then fad_q05 = . ;
	if fad_q06 = 0 then fad_q06 = . ;
	if fad_q07 = 0 then fad_q07 = . ;
	if fad_q08 = 0 then fad_q08 = . ;
	if fad_q09 = 0 then fad_q09 = . ;
	if fad_q10 = 0 then fad_q10 = . ;
	if fad_q11 = 0 then fad_q11 = . ;
	if fad_q12 = 0 then fad_q12 = . ;


	/*REVERSE CODING*/

	/*REVERSE CODE EVEN NUMBER ITEMS IN FAD (4,3,2,1)*/
	array fadEVEN {*} fad_q02 fad_q04 fad_q06 fad_q08 fad_q10 fad_q12;
	array R_fadEVEN {*} fad_q02_r fad_q04_r fad_q06_r fad_q08_r fad_q10_r fad_q12_r;
	do i=1 to dim(fadEVEN);
		R_fadEVEN[i] = 5 - fadEVEN[i];
	end;

	/*REVERSE CODE ITEMS 2,9, AND 19 IN SOCIAL COMMUNICATION QUESTIONNAIRE*/
	array SCQ {*} scq_lifetime_2003_02 scq_lifetime_2003_09 scq_lifetime_2003_19;
	array R_SCQ {*} scq_lifetime_2003_02_r scq_lifetime_2003_09_r scq_lifetime_2003_19_r;
	do i=1 to dim(SCQ);
		R_SCQ[i] = 1 - SCQ[i];
	end;

	/*CREATE SCORES*/

	/*PHQ9 N=9*/
	%SUMscore(phq_9_SUM,9,%str(phq_9_q01, phq_9_q02, phq_9_q03, phq_9_q04, phq_9_q05, phq_9_q06, phq_9_q07, phq_9_q08, phq_9_q09));
	%MEANscore(phq_9_MEAN,%str(phq_9_q01, phq_9_q02, phq_9_q03, phq_9_q04, phq_9_q05, phq_9_q06, phq_9_q07, phq_9_q08, phq_9_q09));

	/*create depression flag*/
	if phq_9_SUM_score >= 10 then depression = 1;
	if phq_9_SUM_score < 10 then depression = 0;
	if phq_9_SUM_score = . then depression = .;


	/*FADscore N=12*/
/*	%SUMscore(fad,12,%str(fad_q01, fad_q02_r, fad_q03, fad_q04_r, fad_q05, fad_q06_r, fad_q07, fad_q08_r, fad_q09, fad_q10_r, fad_q11,fad_q12_r));*/
	%MEANscore(fad,%str(fad_q01, fad_q02_r, fad_q03, fad_q04_r, fad_q05, fad_q06_r, fad_q07, fad_q08_r, fad_q09, fad_q10_r, fad_q11,fad_q12_r));

	/*CREATE FAMILY FUNCTIONING FLAG*/
	IF FAD_SCORE = . THEN fad_function = . ;
	if 1 <= fad_score < 2 then fad_function = 1 ;
	if 2 <= fad_score <= 4then fad_function = 0 ;

	/*maternal se sub score N=10*/
	%SUMscore(maternal_se,10,%str(maternal_se_scale_q01, maternal_se_scale_q02, maternal_se_scale_q03, maternal_se_scale_q04, maternal_se_scale_q05, maternal_se_scale_q06, maternal_se_scale_q07, maternal_se_scale_q08, maternal_se_scale_q09, maternal_se_scale_q10));

	/*ABC Factor 1 Irritability (15 items) n=15*/
	%SUMscore(irritability,15,%str(abc2_q02, abc2_q04, abc2_q08, abc2_q10, abc2_q14, abc2_q19, abc2_q25, abc2_q29, abc2_q34, abc2_q36, abc2_q41, abc2_q47, abc2_q50, abc2_q52, abc2_q57));

	/*ABC Factor 2 Social Withdrawal(16 items)
	n=16 */
	%SUMscore(social_withdrwl,16,%str(abc2_q03, abc2_q05, abc2_q12, abc2_q16, abc2_q20, abc2_q23, abc2_q26, abc2_q30, abc2_q32, abc2_q37, abc2_q40, abc2_q42, abc2_q43, abc2_q54, abc2_q55, abc2_q58));

	/*ABC Factor 3 Stereotypic behavior (7 items) n=7*/
	%SUMscore(Stereotypic,7,%str(abc2_q06, abc2_q11, abc2_q17, abc2_q27, abc2_q35, abc2_q45, abc2_q49));

	/*ABC Factor 4 hyperactivity/Noncompliance (16 items) n=16 */
	%SUMscore(hyperactivity,16,%str(abc2_q01, abc2_q07, abc2_q13, abc2_q15, abc2_q18, abc2_q21, abc2_q24, abc2_q28, abc2_q31, abc2_q38, abc2_q39, abc2_q44, abc2_q48, abc2_q51, abc2_q54, abc2_q56));

	/*ABC Factor 5 Inappropriate Speech (4 items) n=4*/
	%SUMscore(Speech,4,%str(abc2_q09, abc2_q22, abc2_q33, abc2_q46));

/*Social Communication Questionnaire – Lifetime*/
/*Scoring Guidelines*/
/**/
/*Directions*/
/*Item 1 does not have a scoring value but does dictate which items are to be added to determine the Total Score. */
/**/
/*If the answer to Item 1 is yes, add Items 2 to 40. A total score of 11 or higher is a positive screening for autism.*/
/**/
/*If the answer to Item 1 is no, add only Items 8 to 40. A total score of 15 or higher is a positive screening for autism.*/

	/*Social Communication Questionnaire – Lifetimesubgroup yes */
/*	If IF SCQ_LIFETIME_2003_01 = "yes" THEN SCORE ITEMS 2 - 40   n=39*/
	if scq_lifetime_2003_01= "yes" then do;
	%SUMscore(scq_yes,39,%str(scq_lifetime_2003_02, scq_lifetime_2003_03, scq_lifetime_2003_04, scq_lifetime_2003_05, scq_lifetime_2003_06, scq_lifetime_2003_07, scq_lifetime_2003_08, scq_lifetime_2003_09, scq_lifetime_2003_10, scq_lifetime_2003_11, scq_lifetime_2003_12, scq_lifetime_2003_13, scq_lifetime_2003_14, scq_lifetime_2003_15, scq_lifetime_2003_16, scq_lifetime_2003_17, scq_lifetime_2003_18, scq_lifetime_2003_19, scq_lifetime_2003_20, scq_lifetime_2003_21, scq_lifetime_2003_22, scq_lifetime_2003_23, scq_lifetime_2003_24, scq_lifetime_2003_25, scq_lifetime_2003_26, scq_lifetime_2003_27, scq_lifetime_2003_28, scq_lifetime_2003_29, scq_lifetime_2003_30, scq_lifetime_2003_31, scq_lifetime_2003_32, scq_lifetime_2003_33, scq_lifetime_2003_34, scq_lifetime_2003_35, scq_lifetime_2003_36, scq_lifetime_2003_37, scq_lifetime_2003_38, scq_lifetime_2003_39, scq_lifetime_2003_40));

	/*Create Autism Flag*/
	if scq_yes_score ge 11 then autism = 1;
	if .< scq_yes_score lt 11 then autism = 0;
	end;

	/*If IF SCQ_LIFETIME_2003_01 = "NO" THEN SCORE ITEMS 8 - 40     n=33*/
	if scq_lifetime_2003_01= "no" then do;
	%SUMscore(scq_no,33,%str(scq_lifetime_2003_08, scq_lifetime_2003_09, scq_lifetime_2003_10, scq_lifetime_2003_11, scq_lifetime_2003_12, scq_lifetime_2003_13, scq_lifetime_2003_14, scq_lifetime_2003_15, scq_lifetime_2003_16, scq_lifetime_2003_17, scq_lifetime_2003_18, scq_lifetime_2003_19, scq_lifetime_2003_20, scq_lifetime_2003_21, scq_lifetime_2003_22, scq_lifetime_2003_23, scq_lifetime_2003_24, scq_lifetime_2003_25, scq_lifetime_2003_26, scq_lifetime_2003_27, scq_lifetime_2003_28, scq_lifetime_2003_29, scq_lifetime_2003_30, scq_lifetime_2003_31, scq_lifetime_2003_32, scq_lifetime_2003_33, scq_lifetime_2003_34, scq_lifetime_2003_35, scq_lifetime_2003_36, scq_lifetime_2003_37, scq_lifetime_2003_38, scq_lifetime_2003_39, scq_lifetime_2003_40));
	/*Create Autism Flag*/
	if scq_no_score >= 15 then autism = 1;
	if .< scq_no_score < 15 then autism = 0;

	end ;

	format autism depression yesno_. fad_function fad_function_.;
	run;

/*QA Reverse codes*/
/*FAD*/
%qareverse(derived.dissertation_chop,fad_q02*fad_q02_r);
%qareverse(derived.dissertation_chop,fad_q04*fad_q04_r);
%qareverse(derived.dissertation_chop,fad_q06*fad_q06_r);
%qareverse(derived.dissertation_chop,fad_q08*fad_q08_r);
%qareverse(derived.dissertation_chop,fad_q10*fad_q10_r);
%qareverse(derived.dissertation_chop,fad_q12*fad_q12_r);

/*SOCIAL COMMUNICATION QUESTIONNAIRE*/
%qareverse(derived.dissertation_chop,scq_lifetime_2003_02*scq_lifetime_2003_02_r);
%qareverse(derived.dissertation_chop,scq_lifetime_2003_09*scq_lifetime_2003_09_r);
%qareverse(derived.dissertation_chop,scq_lifetime_2003_19*scq_lifetime_2003_19_r);

/*QA scores*/
%QAMEANscore(derived.dissertation_chop,phq_9_MEAN,phq_9_q01*phq_9_q02*phq_9_q03*phq_9_q04*phq_9_q05*phq_9_q06*phq_9_q07*phq_9_q08*phq_9_q09);
%QAMEANscore(derived.dissertation_chop,fad,fad_q01* fad_q02_r* fad_q03* fad_q04_r* fad_q05* fad_q06_r* fad_q07* fad_q08_r* fad_q09* fad_q10_r* fad_q11*fad_q12_r);
%QASUMscore(derived.dissertation_chop,maternal_se,maternal_se_scale_q01* maternal_se_scale_q02* maternal_se_scale_q03* maternal_se_scale_q04* maternal_se_scale_q05* maternal_se_scale_q06* maternal_se_scale_q07* maternal_se_scale_q08* maternal_se_scale_q09* maternal_se_scale_q10);
%QASUMscore(derived.dissertation_chop,irritability,abc2_q02* abc2_q04* abc2_q08* abc2_q10* abc2_q14* abc2_q19* abc2_q25* abc2_q29* abc2_q34* abc2_q36* abc2_q41* abc2_q47* abc2_q50* abc2_q52* abc2_q57);
%QASUMscore(derived.dissertation_chop,social_withdrwl,abc2_q03* abc2_q05* abc2_q12* abc2_q16* abc2_q20* abc2_q23* abc2_q26* abc2_q30* abc2_q32* abc2_q37* abc2_q40* abc2_q42* abc2_q43* abc2_q54* abc2_q55* abc2_q58);
%QASUMscore(derived.dissertation_chop,Stereotypic,abc2_q06* abc2_q11* abc2_q17* abc2_q27* abc2_q35* abc2_q45* abc2_q49);
%QASUMscore(derived.dissertation_chop,hyperactivity,abc2_q01* abc2_q07* abc2_q13* abc2_q15* abc2_q18* abc2_q21* abc2_q24* abc2_q28* abc2_q31* abc2_q38* abc2_q39* abc2_q44* abc2_q48* abc2_q51* abc2_q54* abc2_q56);
%QASUMscore(derived.dissertation_chop,Speech,abc2_q09* abc2_q22* abc2_q33* abc2_q46);
%QASUMscore(derived.dissertation_chop,scq_yes,scq_lifetime_2003_02* scq_lifetime_2003_03* scq_lifetime_2003_04* scq_lifetime_2003_05* scq_lifetime_2003_06* scq_lifetime_2003_07* scq_lifetime_2003_08* scq_lifetime_2003_09* scq_lifetime_2003_10* scq_lifetime_2003_11* scq_lifetime_2003_12* scq_lifetime_2003_13* scq_lifetime_2003_14* scq_lifetime_2003_15* scq_lifetime_2003_16* scq_lifetime_2003_17* scq_lifetime_2003_18* scq_lifetime_2003_19* scq_lifetime_2003_20* scq_lifetime_2003_21* scq_lifetime_2003_22* scq_lifetime_2003_23* scq_lifetime_2003_24* scq_lifetime_2003_25* scq_lifetime_2003_26* scq_lifetime_2003_27* scq_lifetime_2003_28* scq_lifetime_2003_29* scq_lifetime_2003_30* scq_lifetime_2003_31* scq_lifetime_2003_32* scq_lifetime_2003_33* scq_lifetime_2003_34* scq_lifetime_2003_35* scq_lifetime_2003_36* scq_lifetime_2003_37* scq_lifetime_2003_38* scq_lifetime_2003_39* scq_lifetime_2003_40);
%QASUMscore(derived.dissertation_chop,scq_no,scq_lifetime_2003_08* scq_lifetime_2003_09* scq_lifetime_2003_10* scq_lifetime_2003_11* scq_lifetime_2003_12* scq_lifetime_2003_13* scq_lifetime_2003_14* scq_lifetime_2003_15* scq_lifetime_2003_16* scq_lifetime_2003_17* scq_lifetime_2003_18* scq_lifetime_2003_19* scq_lifetime_2003_20* scq_lifetime_2003_21* scq_lifetime_2003_22* scq_lifetime_2003_23* scq_lifetime_2003_24* scq_lifetime_2003_25* scq_lifetime_2003_26* scq_lifetime_2003_27* scq_lifetime_2003_28* scq_lifetime_2003_29* scq_lifetime_2003_30* scq_lifetime_2003_31* scq_lifetime_2003_32* scq_lifetime_2003_33* scq_lifetime_2003_34* scq_lifetime_2003_35* scq_lifetime_2003_36* scq_lifetime_2003_37* scq_lifetime_2003_38* scq_lifetime_2003_39* scq_lifetime_2003_40);


/*merge by key field study_id and keep only study_id's in CHOP dataset*/
/*sort nursing dataset*/
proc sort data=derived.nursing;
	by study_id;
run;
/*sort CHOP data set*/
proc sort data=derived.dissertation_chop;
	by study_id;
run;

/*merge chop with nursing based on study_ids in chop*/
data derived.chop_nursing_merge;
merge derived.dissertation_chop(in=a) derived.nursing;
	by study_id;
/*boolean for study_id is in derived.dissertation_chop*/
	if a;
	if study_id in ("ZachTest","Zachtest2","test")then delete ;
	trt = group + 1;

run;

/*QA that trt is not missing*/
/*proc freq data = derived.chop_nursing_merge;*/
/*where trt = .;*/
/*tables record_id*study_id*trt*age*screen_2*screen_3*screen_4*screen_5*screen_6*screen_7*screen_11*screen_12*screen_13*screen_14*screen_15*screen_16*screen_17*screen_18/list missing;*/
/*tables study_id*trt/list missing;*/
/*run;*/








