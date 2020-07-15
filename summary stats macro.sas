libname raw "U:\Caroline Peterson\Walk Study\data\Raw";
footnote "SAS Program Stored: U:\Caroline Peterson\Walk Study\programs\Draft\summary stats";
options fmtsearch=(raw);

%MACRO summary (DATASET,character);
/*	ods rtf file=" U:\Caroline Peterson\Walk Study\documents\output\summary stats &sysdate..rtf" style=journal;*/
/*	title;*/
/*	proc contents data= *raw.walkabout_form1;	&DATASET; */
/*		title "Contents";*/
/*	run;*/
	
	title;
	proc means data= /*raw.walkabout_form1*/	&DATASET;  
		(drop= &charvar) 								/*REMOVES CHAR VARIABLES*/	
		maxdec=2 MIN MAX;
		title "Means";
	run;

	title;
	proc freq data= /*raw.walkabout_form1*/	&DATASET; 
		tables 	&charvar /*&character*/;							/*FREQUENCIES FOR CHAR VARIABLES*/	
		title "Frequency";	
	run;
	ods rtf close;
%MEND;
