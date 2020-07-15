/*ADVICE FROM CATHERINE

Google the Stats Procedures that you're generating in SAS 
	- Khan Academy

SAS Code book - Developing a Dataset
Recipe for Success
•	Document
•	Know the end result
•	Check your log
•	QA

/*USEFUL MACROS THAT WE CAN CALL INTO OTHER PROGRAMS*/
*generate contents on dataset;
%macro getcont();
    proc contents data=raw.SIR;
/*	title4 font=Calibri j=left height=14pt color=&color "Proc cont: &var. variable"*/
	quit;
%mend getcont;

*generate frequency on categorical variables;
%macro getfreq(var,color);
      proc freq data=raw.sir;
      table &var;
      title4 font=Calibri j=left height=14pt color=&color "Proc freq: &var. variable"
      quit;
%mend getfreq;
 
 
*generate means on continuous variables;
%macro getmeans(); *var,color;
      proc means data=raw.sir n nmiss mean std min p25 median p75 max maxdec=2;
/*      var &var;*/
/*      title4 font=Calibri j=left height=14pt color=&color "Proc means: &var. variable"*/
      quit;
%mend getmeans;
 
 
*generate box plots on continuous variables, please note there is a ‘vnum’ variable you may need to change 
it to the name of visit variable in your dataset;
%macro getbox (var,color);
      proc boxplot data=CHECK ;
            plot (&var)*vnum/boxstyle=schematic;
            title4 font=Calibri j=left height=14pt color=&color "Box Plot: &var. (for each time point)";
      quit;
%mend getbox;
 
 
*generate scatter plots on continuous variables that need to be compare to each other;
%macro getscatter(var1, var2, color, title);
title4 font=Calibri j=left height=14pt color=&color "Scatter Plot: &title.";
proc gplot data=check;
      where &var1 ne . and &var2 ne .;
      symbol value=dot color=black height=1;
      plot &var1 * &var2;
run; quit;
%mend getscatter;
 
 
/**IMPORTANT: here are the macro calls, be sure to use the actual variable name where you see the word
‘var’ (the variable name should not have any spaces);*/

/*%getcont();*/
/*%getfreq(var,blue);*/
/*%getmeans(var,darkred);*/
/*%getbox(var,green);*/
/*%getscatter(var1,var2,purple,var1 vs var2 over all timepoints);*/

 
