/*Use the following macro functions to eliminate repetition in the following datastep*/

/*SUM Score*/
%macro SUMscore(name,n,scoreVars);
/*name is prepended to _nmiss*/
/*in the call %SUMscore(name,n,%str(scoreVars)), use %str(scoreVars) to list %str(var1,var2,...) as a string instead of parameters*/
&name._nmiss = nmiss(&scoreVars);	
label &name._nmiss = "Number of variables missing for &name";	

/*getting the percentage of missing questions*/	
/*n is the number of variables*/
/*name is prepended to _pctmiss*/
&name._pctmiss=round((&name._nmiss*100) / &n);	
label &name._pctmiss = "Percent of the variables missing &name";	

/*missing is not included in the numerator or denominator of the mean function*/	
/*name is prepended to _score*/
&name._score = &n * mean(&scoreVars);  ;	
label &name._score = "&name subscore";	

/*If subject is missing more than 20% of the subscales then the Global score variable will be converted to missing*/	
if &name._pctmiss gt 20 then &name._score = .;	
%mend;

%macro MEANscore(name,scoreVars);	
/*missing is not included in the numerator or denominator of the mean function*/	
&name._score = mean(&scoreVars);  ;	
label &name._score = "&name subscore";	
%mend;

/*QA Reverse Codes*/
%macro qareverse(vars);
proc freq data= derived.skin_to_skin_care;
tables &vars / list missing ;
run;
%mend;

/*QA scores*/
%macro QAscore(name,visit,scoreVars);
proc freq data=derived.skin_to_skin_care;
tables &name._nmiss * &name._pctmiss * &name._score * &scoreVars /list missing;
where redcap_event_name = "&visit";
run;
%mend;

/*Summary stats on subscores/total scores by visit*/
%macro summary(score,visit);
ods Excel OPTIONS(SHEET_INTERVAL="none" SHEET_NAME="Summary Stats");

title "";
proc means data= derived.skin_to_skin_care maxdec=2 n nmiss min max mean std;
var &score;
where redcap_event_name="&visit";
title "&score";
run;
%mend;


/*visit 6*/
data;
/*Reverse code example*/
array stateV6{*} calm_post2 secure_post2;
array stateV6_r{*} calm_post2_r secure_post2_r ;

do i=1 to dim(stateV6);
	stateV6_r[i]= 5 - stateV6[i];
end;
