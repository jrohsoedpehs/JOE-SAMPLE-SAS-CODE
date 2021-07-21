/*CREATES A PIE CHART IN SAS*/

%macro piechart(title, var); 
title1 " &title ";

proc gchart data=raw.CISABigdata;
   pie &var / other=0
              value=none
              percent=arrow
              slice=arrow
              noheading 
              plabel=(font='Albany AMT/bold' h=1 color=depk);
	format experience_spss experience_stata experience_sas experience_redcap experience.; 
run;
quit; 
%mend piechart; 





%macro output(var1, var2, var3, var4);
ods layout Start width=10in height=8in columns=2 rows=2
column_gutter=.15in row_gutter=.25in row_heights=(3.5in 3.5in) column_widths = (4.5in 4.5in); 
ods region row=1 column=1;
%piechart(Interested in organizing data, &var1);
ods region row=1 column=2; 
%piechart(Interested in documentation, &var2);
ods region row=2 column=1; 
%piechart(Interested in naming conventions, &var3);
ods region row=2 column=2; 
%piechart(Interested in data dictionaries, &var4);
ods layout end;
%mend output; 
