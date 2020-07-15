/*use to pull macros into code %include = "Q:\STUDENT Stefanie Zavodny\Dissertation\programs\Draft create_composite_scores.sas";*/
/*SUMscore has 3 parameters*/
/*name (name of composite score)*/
/*n (number of variables)*/
/*scoreVars (a list of variables seperated by commas)*/

/*use %str() to treat commas as text for parameter scoreVars*/


%SUMscore(name,n,%str(scoreVars));
%MEANscore(name,%str(scoreVars));




/*Macros to avoid repetitive code*/
%macro SUMscore(name,n,scoreVars);

&name._nmiss = nmiss(&scoreVars);	
label &name._nmiss = "Number of variables missing for &name";	

/*getting the percentage of missing questions*/	
&name._pctmiss=round((&name._nmiss*100) / &n);	
label &name._pctmiss = "Percent of the variables missing &name";	

/* global score*/	
/*missing is not included in the numerator or denominator of the mean function*/	
&name._score = &n * mean(&scoreVars);  ;	
label &name._score = "&name subscore";	

/*If subject is missing more than 20% of the subscales then the Global score variable will be converted to missing*/	
if &name._pctmiss gt 20 then &name._score = .;	
%mend;

%macro MEANscore(name,scoreVars);
/* global score*/	
/*missing is not included in the numerator or denominator of the mean function*/	
&name._score = mean(&scoreVars);  ;	
label &name._score = "&name subscore";	
%mend;

/*QA Reverse Codes*/
%macro qareverse(dsn,vars);
proc freq data= &dsn;
tables &vars / list missing ;
run;
%mend;

/*QA scores*/
%macro QAscore(dsn,name,scoreVars);
proc freq data=&dsn;
tables &name._nmiss * &name._pctmiss * &name._score * &scoreVars /list missing;
run;
%mend;
