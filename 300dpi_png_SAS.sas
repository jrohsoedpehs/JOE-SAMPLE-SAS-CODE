/*300 dpi png*/



/*Images have a prefix followed by a number*/
/*set image prefix*/
ods graphics on / imagename="Image";

ods listing gpath="Q:\Terri Lipman\DFH_2019\documents\output";
ods listing image_dpi=300;   

filename grafout "Number of Sessions Attended &sysdate..png";
goptions reset=all device=png /*pngt*/ border xmax=8in ymax=8in 
         gsfname=grafout gsfmode=replace;

proc sgplot data=raw.DFH_Data_Fall_2018_anal;
	vbar weeksdanced/group=agegp groupdisplay=cluster;
	xaxis values=(1 to 12 by 1); 
	yaxis values=(0 to 20 by 1); 
	where visit=1; 
	format agegp agegp.; 
	label weeksdanced="Number of Sessions Attended"
		  agegp="Age Cohort"; 
	title "histogram of total number of children and adults by visit"; 
run;



































libname raw "U:\Sharon Irving\Anthroplus\data\Raw";
libname derived "U:\Sharon Irving\Anthroplus\data\Derived";
footnote "SAS PROGRAM STORED: U:\Sharon Irving\Anthroplus\programs\plots.sas";
/*options fmtsearch=(raw);*/

proc format;
	value eth 1 = "Hispanic"
			  2 = "Non-Hispanic"
			  3 = "Unknown";

	value race 0 = "No Response"
			   2 = "African American"
			   3 = "Asian"
			   4 = "White/Caucasian"
			   6 = "More than One";

	value phys 1 = "Single Ventricle"
			   2 = "2 Ventricle"
			   3 = "Healthy/Control";

	value visit 1=" "
				2 = "3 months"
			   3 = "6 months"
			   4 = "9 months"
			   5 = "12 months"
			   6 = " ";

	value sex 1 = "Male"
			  2 = "Female";
	value chd 0 = 'Healthy'
			  1 = 'Congenital Heart Disease';
run;

/*RUN THIS CODE TO CREATE THE MEANS THAT WILL BE USED IN THE Z-SCORE PLOT*/
proc sort data = derived.table1_final; by visit_no physposta; run;
proc means data = derived.table1_final noprint;
	by visit_no physposta;
	var _zac _zts _zss _zbmi _zwei _zlen;
	output out = derived.who_means mean=mean_zac mean_zts mean_zss mean_zbmi mean_zwei mean_zlen median=med_zac med_zts med_zss med_zbmi std = std;
run;



/*Creates a 300 dpi png image*/
ods _all_ close; 
ods listing image_dpi=300;   

/*filename grafout 'U:\Sharon Irving\Anthroplus\documents\Plots\6142016\';*/
filename grafout 'dir\Plots\yyyymmdd\';
goptions reset=all device=pngt border xmax=8in ymax=8in 
         gsfname=grafout gsfmode=replace;
    
axis2 label=(angle=90 H=2) order=(-2 to 2 by 1) minor=(n=1); 

proc gplot data = derived.who_means;
    symbol1 v=circle  c=red i=join w=2 /*w is line width higher numbers is make a thicker line Screen (Copy and Paste output as .tif file b/c rtf distorts output)*/ l=1;
    symbol2 v=dot c=black i=join w=5 l=2;
	symbol3 v=star c=blue i=join w=5 l=3;
 	plot( mean_zac mean_zts mean_zss mean_zbmi mean_zwei mean_zlen )*visit_no = physposta/ /*haxis=axis1*/ vaxis=axis2
 	vref=(0 -1 1 )lvref=(1 2 2);	title1 "Z-Score Means";
	label physposta="Post-Operative Physiology Classification";
	label visit_no="Visit";
	label mean_zac="Mid Upper Arm Circumfrence";
	title;
    footnote; /*supresses format on the graph for professional quality for manuscript or journal article*/
run;

quit;
