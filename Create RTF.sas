/*Create RTF for each proc seperately*/
ods rtf file="&path/Recruitment/Output/title &sysdate..doc" style=journal;
title " ";
/*code*/
ods rtf close;


/*USE This code when things wrap*/
ods rtf file="R:\documents\output\providerNumber first 50 obs &sysdate..doc" style=journal;
options orientation = landscape;
proc print data=dsn (obs=50) width=minimum; /*width=minimum helps prevent wrapping*/
var variables;
run;
ods rtf close;
 
/*LANDSCAPE MODE*/
/*%macro frequency(course, question, title);*/
	ods rtf file="path\&title &sysdate..doc";
		options ps=120 orientation = landscape; /*ENABLES LANDSCAPE*/
		proc print data = dsn noobs label width=min; /*width=min HELPS ENABLE LANDSCAPE*/
			var &course &question;
			title "&title";
		run;
	ods rtf close;
/*%mend;*/



/*Create RTF for each proc seperately*/
/*macro call*/
/*%rtf(%str(code));*/

%macro rtf(title, code);
ods rtf file="dir\&title &sysdate..doc" style=journal;
/*title "&title";*/
&code;
ods rtf close;
%mend;


