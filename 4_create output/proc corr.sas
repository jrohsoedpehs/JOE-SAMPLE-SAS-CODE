/*PROC CORR - CORRELATION BETWEEN NUM VARIABLES (VARS IN PROC MEAN)*/

Proc corr  data = derived.mean_assay2 pearson spearman;
var FFA__mM_ COR_ug_dl INS_uIU_ml_n GLU_YSI_ GLU_ACU GLU_CGM ;
title 'Correlation among observations at the individual patient level';
run;

/*pearson assumes normal distribution*/

/*spearman does not assume normal distribution*/
