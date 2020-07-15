
/*Check if the distribution is normal for numeric variables*/
/*mean = or is close to the median*/
/*Wilk statistic bwt .85 and 1 and xxx bwt 0 and .2 (below wilk) are great identifiers*/
proc univariate data=derived.combined_subscales plot normal;
	var com_score_subscale Ptp_subscale Qty_Subscale Lshp_Subscale  Rcs_Subscale  Rns_Subscale BOT_score;
	by hospital;
run;


