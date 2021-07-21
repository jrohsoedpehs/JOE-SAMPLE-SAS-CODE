proc univariate data=raw.DoL_2021 normal plot ;
/*class TCode;*/
var RegardScale Attitudes EmpathyScale;
histogram RegardScale Attitudes EmpathyScale;
id ResponseId ;
title 'Checking Distributions of the Outcomes';
run;


/*RegardScale Attitudes EmpathyScale are numeric*/
