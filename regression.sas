/*proc logistic*/
/**/
/*%macro code(w,x); */
*ods trace on/listing;
/*restricts output to the following listed after select*/
/*ods select Logistic.Type3 Logistic.ParameterEstimates Logistic.OddsRatios; */
proc logistic data=code order= internal;
	class &w; /*&w category predictors*/
	model Code=&x &W /*/rsquare*/; /*&x continuous predictors|R^2 tells if the model is a good fit|significance tells if there are too many variables for the model*/
	title1 "DUCOM 2260 - Effect on code status";
	title2 "predictor variable: &x";
quit;
*ods trace off;
%mend;
