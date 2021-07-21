/*COMPARE 2 CATEGORY VARIABLES*/

/*TEST FOR STATISTICAL SIGNIFICANCE BETWEEN 2 CATEGORY VARIABLES*/
/*SAS WILL NOTIFY IF THERE IS TOO MUCH MISSING DATA FOR chisq*/
/*IN THIS CASE, USE fisher*/
proc freq data=dsn;
table trt*(var1 var2)/chisq fisher nopercent nocol;
format clean_role role_.;
run;


/*USE proc genmod TO DETERMINE WHICH GROUPS HAVE */
/*A DIFFERENCE*/
/*NO DIFFERENCE*/
/*THE STRONGEST DIFFERENCE*/
proc genmod data= derived.survey_bl   descending ;
class clean_role;
model been_kicked= clean_role /link = logit dist=binomal;
lsmeans clean_role /exp diff cl;
format clean_role role_.;
run;
