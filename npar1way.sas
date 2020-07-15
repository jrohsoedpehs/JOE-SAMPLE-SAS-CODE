

************************************************************;
* With a by statement and more than one outcome variable;
************************************************************;

proc format; 
  value p63val 
  low-<0.0001="<0.0001" ;
run;

proc means  data=baseline mean std min q1 median q3 max maxdec=2;
	by medhisint14lymph;
	class group;
	var benchsucc legsucc;* bmi bf_nobo wbtot_fat wbtot_lean;
quit;
ods select none;
proc npar1way data=baseline anova wilcoxon;
	by medhisint14lymph;
	class group;
	var benchsucc legsucc;* bmi bf_nobo wbtot_fat wbtot_lean;
	ods output WilcoxonTest=WilcoxonTest  ANOVA=anova;
quit;
ods select all;

proc print data=anova label; where source = 'Among';
	var medhisint14lymph variable probf;
	title 'T-Test p-values';
	label probf = 'p-value';
	format probf p63val.; 
	format probf  pvalue10.4; 
quit;

proc print data=WilcoxonTest label; where name1 = 'PT2_WIL';
	var medhisint14lymph variable nValue1;
	title 'Wilcoxon p-values';
	label nValue1 = 'p-value';
	format nValue1 p63val.; 
	format probf  pvalue10.4; 
quit;

**********************************************************;
* Without a by statement and only one variable;
**********************************************************;
proc format; 
  value p63val 
  low-<0.0001="<0.0001" ;
run;

proc means  data=baseline mean std min q1 median q3 max maxdec = 2;
	class group;
	var benchsucc;
quit;
ods select none;
proc npar1way data=baseline anova wilcoxon;
	class group;
	var benchsucc;
	ods output WilcoxonTest=WilcoxonTest  ANOVA=anova;
quit;
ods select all;

proc print data=anova label; where source = 'Among';
	var  probf;
	title 'T-Test p-values';
	label probf = 'p-value';
	format probf p63val.; 
	format probf  pvalue10.4; 
quit;

proc print data=WilcoxonTest label; where name1 = 'PT2_WIL';
	var  nValue1;
	title 'Wilcoxon p-values';
	label nValue1 = 'p-value';
	format nValue1 p63val.; 
	format probf  pvalue10.4; 
quit;



**********************************************************;
* Without a by statement and more than one variable;
**********************************************************;
proc means  data=baseline mean std min q1 median q3 max maxdec =2;
	class poor;
	var internal_diff external_diff;
	title1 'Summary stats';
quit;
ods select none;
proc npar1way data=baseline anova wilcoxon;
	class poor;
	var internal_diff external_diff;
	ods output WilcoxonTest=WilcoxonTest  ANOVA=anova;
quit;
ods select all;

proc print data=anova label; where source = 'Among';
	var variable probf;
	title2 'T-Test p-values';
	label probf = 'p-value'; 
	format probf  pvalue10.4; 
quit;

proc print data=WilcoxonTest label; where name1 = 'PT2_WIL';
	var  variable nValue1;
	title2 'Wilcoxon p-values';
	label nValue1 = 'p-value'; 
	format nValue1  pvalue10.4; 
quit;
**********************************************************;
* Without a by statement and more than one variable;
**********************************************************;
proc format; 
  value p63val 
  low-<0.0001="<0.0001" ;
run;

proc means  data=baseline mean std min q1 median q3 max;
	class group;
	var benchsucc;
quit;
ods select none;
proc npar1way data=baseline anova wilcoxon;
	class group;
	var benchsucc legsucc;
	ods output WilcoxonTest=WilcoxonTest  ANOVA=anova;
quit;
ods select all;

proc print data=anova label; where source = 'Among';
	var variable probf;
	title 'T-Test p-values';
	label probf = 'p-value';
	format probf p63val.; 
	format probf  pvalue10.4; 
quit;

proc print data=WilcoxonTest label; where name1 = 'PT2_WIL';
	var  variable nValue1;
	title 'Wilcoxon p-values';
	label nValue1 = 'p-value';
	format nValue1 p63val.; 
	format probf  pvalue10.4; 
quit;
*************************************************************************************************************************;
* Without a by statement and more than one variable and predictor has more than two categories;
**************************************************************************************************************************;
proc format; 
  value p63val 
  low-<0.0001="<0.0001" ;
run;


proc means  data=derived.davids_merg_all n mean std min q1 median q3 max maxdec=2;
    where month=1;
	class condition;
var PF_SS SE_SS SL_SS PD_SS WK_SS QL_total 
    EUQ001 EUQ002 EUQ003 EUQ004 EUQ005 EUQ006 
    PCS12 MCS12 
    BPHQ_score 
    actual_hours_sleep_score sleep_efficiency_score sleep_latency_score sleep_disturbance_score 
    daytime_dysfunction_score sleep_medication_score subjective_sleep_quality_score global_score; 
title 'Baseline Means by Treatment Groups';
quit;title;


ods select none;
*ods trace on/listing;
proc npar1way data=derived.davids_merg_all anova wilcoxon;
    where month=1;
	class condition;
var PF_SS SE_SS SL_SS PD_SS WK_SS QL_total 
    EUQ001 EUQ002 EUQ003 EUQ004 EUQ005 EUQ006 
    PCS12 MCS12 
    BPHQ_score 
    actual_hours_sleep_score sleep_efficiency_score sleep_latency_score sleep_disturbance_score 
    daytime_dysfunction_score sleep_medication_score subjective_sleep_quality_score global_score; ;
	ods output  KruskalWallisTest=kruskal_wallis  ANOVA=anova;
title 'Baseline Means by Treatment Groups';
quit;
*ods trace off;
ods select all;

proc print data=anova label; 
    where source = 'Among';
	var variable probf;
	title2 'ANOVA P-values';
	label probf = 'P-value'; 
	format probf  pvalue10.4; 
quit;

proc print data=kruskal_wallis label; 
    where name1 = 'P_KW';
	var  variable nValue1;
	title2 'Kruskal Wallis P-values';
	label nValue1 = 'P-value';
	*format nValue1 p63val.; 
	format nValue1  pvalue10.4; 
quit;

footnote; title;
ODS RTF CLOSE;



* Summary statistics for FESI_TOTAL by FOFSCALE;
proc means  data=derived.fof_6_13_13 n mean std min q1 median q3 max maxdec=2 nonobs; 
	class FOFSCALE; 
	var FESI_TOTAL;
	title1 'Summary statistics for FESI_TOTAL by FOFSCALE';
run;title;


ods select none;
proc npar1way data=derived.fof_6_13_13 anova wilcoxon; 
	class FOFSCALE;
	var FESI_TOTAL;
	ods output  KruskalWallisTest=kruskal_wallis  ANOVA=anova;
quit;
ods select all;

proc print data=anova label; 
    where source = 'Among';
	var variable probf;
	title2 'ANOVA P-values';
	label probf = 'P-value'; 
	format probf  pvalue10.4; 
quit;

proc print data=kruskal_wallis label; 
    where name1 = 'P_KW';
	var  variable nValue1;
	title2 'Kruskal Wallis P-values';
	label nValue1 = 'P-value';
	*format nValue1 p63val.; 
	format nValue1  pvalue10.4; 
quit;

footnote; title;
ODS RTF CLOSE;



