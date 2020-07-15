/*
SAS experience at UPENN

libname
footnote
options fmtsearch=(raw);
Basic Summary Stats
Printing a rtf
merging
Data quality code (proc compare, etc)
Data Cleaning code
Macros (Catherine)
Do Loops
Arrays
Whitney notes
Make a file for each one

*/

/*CONVERTS CHARACTER VARIABLE FRACTIONS TO DECIMAL NUMERIC VARIABLES*/

data dsn4;
	infile datalines delimiter=','; 
	input id  NE_I5A_HT $ NE_I5C_HT $12.;   
	datalines;                      
	1,010,17 1/2
	2,20,21.8 3/4
	3,99,99
	4,99NR,99NR
	5,IL,15 3/4 - 3
	6,1.32,25 - 10
;

data converted;                                                
	set dsn4;
		array convert {8}$ NE_I5A_HT  NE_I5C_HT NE_I6A_WT NE_I6C_WT PD_BC1_WT PD_BC3_WT PD_BD1_HT PD_BD3_HT; /*[$] defines the group of variables as char*/
		array converted {8} NE_I5A_HT_n NE_I5C_HT_n NE_I6A_WT_n NE_I6C_WT_n PD_BC1_WT_n PD_BC3_WT_n PD_BD1_HT_n PD_BD3_HT_n;
		do i=1 to 8;
			integer_part=.;
			denominator=.;
			numerator=.;
*			dash_position=index(convert[i],"-");slash_position=index(convert[i],"/");    /*checks if there's a fraction by looking for a / */  
			blank_position=index(convert[i]," ");
				if slash_position=0 then do; /*integer case*/
					integer_part=convert[i]; /*no change to value*/                                     	
				end; 
				else if blank_position lt slash_position then do; /*mixed number*/                                      
					integer_part=scan(convert[i],1," /"); /*picks up the integer part, reads left to right*/                                     
					denominator=scan(convert[i],-1,"/"); /*picks up denominator, reads right to left*/                                    
					numerator=scan(convert[i],-2,"/ "); /* picks up numerator, reads right to left "/ "lists multiple delimiters (slash and space). Using only "\" should yield 1 01*/                                   
				end; 
				else if (slash_position lt blank_position) and slash_position ne 0 then do;  /*fraction*/  
					numerator=scan(convert[i],1," /"); /*picks up the integer part, reads left to right*/                                     
					denominator=scan(convert[i],-1,"/"); /*picks up denominator, reads right to left*/ 
				end;
				numeratorn=1*numerator;
				denominatorn=1*denominator;
				fraction= numeratorn/denominatorn; 
				integer=1*integer_part; 
				if slash_position=0 then number=integer;  /*If there are no fractions then we have our number*/                                
				else if integer_part ne . then number=round(integer+fraction,.0001);  /*If it is a mixed number, then add integer part and decimal form of fraction together*/       
				else number=round(fraction,.0001);  /*If it is a pure fraction, round the decimal form of it to four places.*/ 
				format number 10.4;  /*number has 8 bytes (digits) and four decimal places. Do I need to make these formats permanent?*/
*				if number=99 then number=.;
				converted[i]=number;
			if number=99 then converted[i]=.;
*		output; /*everytime you see output, a new row of data is created*/
		end;
run;

proc print data= converted;
*	var integer integer_part;
run;

proc contents data=converted;
run;
