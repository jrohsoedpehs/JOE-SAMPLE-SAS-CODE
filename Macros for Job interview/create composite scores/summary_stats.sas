libname raw "Q:\STUDENT Stefanie Zavodny\Dissertation\data\raw";
libname derived "Q:\STUDENT Stefanie Zavodny\Dissertation\data\Derived";
footnote "Q:\STUDENT Stefanie Zavodny\Dissertation\programs\Draft\summary_stats.sas";
options fmtsearch=(redcap.nursing_formats raw.chop_formats);
options nofmterr;

/*Score Summary.pdf*/
ods pdf file="Q:\STUDENT Stefanie Zavodny\Dissertation\documents\output\Score Summary.pdf" ;
/*6.1 Primary Endpoint*/
/*The proportion of mothers in each group that scores positive PHQ9>=10 for depression*/
title "";
proc freq data= derived.chop_nursing_merge ;
tables group*depression/nocol nopercent chisq;
title "The proportion of mothers in each group that scores positive PHQ9>=10 for depression";
run;
/*Overall Scores*/
title "";
proc means data=derived.chop_nursing_merge maxdec=2 n nmiss min max mean std;
var phq_9_SUM_score phq_9_MEAN_score fad_score maternal_se_score irritability_score social_withdrwl_score Stereotypic_score hyperactivity_score Speech_score scq_yes_score scq_no_score;
title "Overall Scores";
run;
/*Scores by Treatment Group*/
title"";
proc means data=derived.chop_nursing_merge maxdec=2 n nmiss min max mean std;
class group;
var phq_9_SUM_score phq_9_MEAN_score fad_score maternal_se_score irritability_score social_withdrwl_score Stereotypic_score hyperactivity_score Speech_score scq_yes_score scq_no_score;
title "Scores by Treatment Group by Depression";
run;
ods pdf close;

/*Correlations amoung Outcomes.pdf*/
ods pdf file="Q:\STUDENT Stefanie Zavodny\Dissertation\documents\output\Correlations amoung Outcomes.pdf" ;
Proc corr  data = derived.chop_nursing_merge pearson spearman;
var phq_9_SUM_score phq_9_MEAN_score fad_score maternal_se_score irritability_score social_withdrwl_score Stereotypic_score hyperactivity_score Speech_score scq_yes_score scq_no_score;
title 'Correlation';
run;
ods pdf close;

/*npar1way.pdf*/
ods pdf file="Q:\STUDENT Stefanie Zavodny\Dissertation\documents\output\npar1way.pdf" ;
*************************************************************************************************************************;
* Without a by statement and more than one variable and predictor has more than two categories;
**************************************************************************************************************************;
proc format; 
  value p63val 
  low-<0.0001="<0.0001" ;
run;

proc means  data=derived.chop_nursing_merge n mean std min q1 median q3 max maxdec=2;
class group;
var phq_9_SUM_score phq_9_MEAN_score fad_score maternal_se_score irritability_score social_withdrwl_score 
    Stereotypic_score hyperactivity_score Speech_score scq_yes_score scq_no_score;
title 'Means by Groups';
quit;title;


ods select none;
*ods trace on/listing;
proc npar1way data=derived.chop_nursing_merge anova wilcoxon;
class group;
var phq_9_SUM_score phq_9_MEAN_score fad_score maternal_se_score irritability_score 
    social_withdrwl_score Stereotypic_score hyperactivity_score Speech_score scq_yes_score scq_no_score;
ods output  KruskalWallisTest=kruskal_wallis  ANOVA=anova;
title 'Means by Groups';
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
ods pdf close;


/*QA Groups.pdf*/
ods pdf file="Q:\STUDENT Stefanie Zavodny\Dissertation\documents\output\QA Groups.pdf" ;

title "";
proc freq data= derived.chop_nursing_merge ;
where trt = 1;
tables study_id*trt/list missing;
title "group 1";
run;

title "";
proc freq data= derived.chop_nursing_merge ;
where trt = 2;
tables study_id*trt/list missing;
title "group 2";
run;

title "";
proc freq data= derived.chop_nursing_merge ;
where trt = 3;
tables study_id*trt/list missing;
title "group 3";
run;

ods pdf close;


