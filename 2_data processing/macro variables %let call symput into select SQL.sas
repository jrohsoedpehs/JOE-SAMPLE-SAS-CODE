/*macro variables*/

proc contents data=sashelp.cars varnum;run;
proc print data=sashelp.cars (obs=30);run;

/*Do not save the data set to */
/*Used to define a macro variable from a dataset*/
data _null_;
set sashelp.cars;
call symput(trim(type), enginesize);
call symput('SAMPLE', enginesize);

run;
%put &SUV;
%put &SAMPLE;





/*CREATE A LIST OF VARIABLES*/

/*INITIALIZE MACRO VARIABLE fieldslist1*/
%let fieldslist1=; 
data _null_;
set raw.ko_ae_nw_dictionary;
call symput('fields', field_name);/*ASSIGN MACRO VALUE*/
call execute('%let fieldslist1=&fieldslist1., &fields;');/*SAVE VALUE TO LIST USING %LET*/
run;
%put &fields;
%put &fieldslist1;

/*GENERATES A LIST VARIABLES FOR */
proc sql /*noprint*/;
select distinct field_name
into :fields separated by "," from raw.ko_ae_nw_dictionary;
quit;
/*VIEW THE LIST IN THE LOG*/
%put &fields;



/*SQL SELECT - CREATE MACRO VARIABLE*/
/*BASIC SUMMARY STATS TO CHECK DATA QUALITY*/
/*CREATE MACRO VARIABLE FOR PROC MEANS AND PROC FREQ*/
/*Assumes the data has been cleaned*/
proc contents data=temp varnum out=cont_out noprint;run;



proc print data=sashelp.cars (obs=10);run;
proc contents data=sashelp.cars varnum out=temp noprint;run;
proc print data=temp;run;

/*LOOK FOR FIELDS TO EXPLOIT IN cont_out*/
/*proc contents data = cont_out varnum;run;*/
/*proc print data = cont_out;run;*/
/*NUM VARIABLES*/
proc sql noprint;   
    select NAME   
    into : startswithE   
    separated by '', ''   
    from temp   
    where name in('M',)/*   char type=2*/
/*  num  type=1*/
/*  ANY VARIATION OF BEST IS THE DEFAULT NUM FORMAT*/
quit; 
/*VIEW VARIABLES IN &numlist*/
%put &measures;

%macro procedure(dsn, var);
proc print data= &dsn;
var &var;
run;
%mend;

%procedure(dsn, %str('var1', 'var2', ));
