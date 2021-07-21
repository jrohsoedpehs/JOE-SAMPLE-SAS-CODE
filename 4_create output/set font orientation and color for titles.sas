%let dsn = ;

%macro getcont();
    proc contents data=raw.SIR;
/*	title4 font=Calibri j=left height=14pt color=&color "Proc cont: &var. variable"*/
	quit;
%mend getcont;

*generate frequency on categorical variables;
%macro getfreq(/*var,color*/); 
      proc freq data=&dsn;
/*      table &var;*/
/*      title4 font=Calibri j=left height=14pt color=&color "Proc freq: &var. variable"*/
      quit;
%mend getfreq;
 
 
*generate means on continuous variables;
%macro getmeans(/*var,color*/); 
      proc means data=&dsn;
/*      var &var;*/
/*      title4 font=Calibri j=left height=14pt color=&color "Proc means: &var. variable"*/
      quit;
%mend getmeans;
