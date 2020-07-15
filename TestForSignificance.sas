**********************************************************;
* Without a by statement and more than one variable;
**********************************************************;
proc means  data=derived.combined_subscales mean std min q1 median q3 max maxdec =2;
    class Hospital;
    var com_score_subscale Ptp_subscale Qty_Subscale Lshp_Subscale  Rcs_Subscale  Rns_Subscale;
	title1 'Summary stats';
quit;
ods select none;
proc npar1way data=derived.combined_subscales anova wilcoxon; /*category hospital by continous scale*/
    class Hospital;
    var com_score_subscale Ptp_subscale Qty_Subscale Lshp_Subscale  Rcs_Subscale  Rns_Subscale;
	ods output WilcoxonTest=WilcoxonTest  ANOVA=anova;
quit;
ods select all;

proc print data=anova label; where source = 'Among'; /*normal distribution*/
	var variable probf;
	title2 'T-Test p-values';
	label probf = 'p-value'; 
	format probf  pvalue10.4; 
quit;

proc print data=WilcoxonTest label; where name1 = 'PT2_WIL'; /*skewed distribution non-parametric*/
	var  variable nValue1;
	title2 'Wilcoxon p-values';
	label nValue1 = 'p-value'; 
	format nValue1  pvalue10.4; 
quit;


proc freq data= derived.combined_subscales;
   tables (age children exp Educ	ITL	JS	M_Status	Nationality	job	sex	unit)*hospital/chisq nopercent norow;
/*   tables (age children exp Educ	ITL	JS	M_Status	Nationality	job	sex	unit)*hospital/fisher nopercent norow;*/
   title"FREQ-Hospital";
run;


/*Entire Sample*/
title"";
proc means  data=derived.combined_subscales mean std min q1 median q3 max maxdec =2; /*gets total N*/
    var com_score_subscale Ptp_subscale Qty_Subscale Lshp_Subscale  Rcs_Subscale  Rns_Subscale;
title"NUM-Entire Sample";
run;

/*hospital*/
title"";
proc means  data=derived.combined_subscales mean std min q1 median q3 max maxdec =2;
    class Hospital;
    var com_score_subscale Ptp_subscale Qty_Subscale Lshp_Subscale  Rcs_Subscale  Rns_Subscale;
title"NUM-Hospital";
quit;
ods select none;
proc npar1way data=derived.combined_subscales anova wilcoxon;
    class Hospital;
    var com_score_subscale Ptp_subscale Qty_Subscale Lshp_Subscale  Rcs_Subscale  Rns_Subscale;
	ods output WilcoxonTest=WilcoxonTest  ANOVA=anova;
quit;
ods select all;

proc print data=anova label; where source = 'Among'; /*normal distribution*/
	var variable probf;
	title2 'T-Test p-values';
	label probf = 'p-value'; 
	format probf  pvalue10.4; 
quit;

proc print data=WilcoxonTest label; where name1 = 'PT2_WIL'; /*skewed distribution, non-parametric*/
	var  variable nValue1;
	title2 'Wilcoxon p-values';
	label nValue1 = 'p-value'; 
	format nValue1  pvalue10.4; 
quit;


/*FREQ*/

proc sort data= derived.combined_subscales; /*gets total %*/
    by hospital;
run;
/*Hospital*/
title"";
proc freq data= derived.combined_subscales;
   by hospital;
   tables (age children exp Educ	ITL	JS	M_Status	Nationality	job	sex	unit)*;
   title"FREQ-Hospital";
run;
proc freq data= derived.combined_subscales;
   tables (age children exp Educ	ITL	JS	M_Status	Nationality	job	sex	unit)*hospital/chisq nopercent norow;
/*   tables (age children exp Educ	ITL	JS	M_Status	Nationality	job	sex	unit)*hospital/fisher nopercent norow;*/
   title"FREQ-Hospital";
run;


/*Entire Sample*/
title"";
proc freq data= derived.combined_subscales;
   tables age children exp Educ	ITL	JS	M_Status	Nationality	job	sex	unit;
   title"FREQ-Entire Sample";
run;
