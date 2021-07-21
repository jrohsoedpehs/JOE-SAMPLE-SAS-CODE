/********************************************************
Reading and Processing the Contents of a Directory 
Ben Cochran, The Bedford Group, Raleigh, NC 
(email this)

Write a DATA Step that will read this directory and each file 
within it.  

Use the DOPEN,  DNUM, and DREAD functions to process a directory. 
 
This step is just a proof on concept to see if we are actually 
reading the contents correctly.  

The results are written to the log.

Directory Functions

DOPEN - opens a directory and returns the directory identifier
DNUM - returns the number of members in a directory
DREAD - returns the name of a directory member (file or folder)
DCLOSE - closes a directory opened by DOPEN
********************************************************/

/*directory Q:\SAMPLE_SAS_PROGRAM\JOE-SAMPLE-SAS-CODE*/

/********************************************************
STEP 1:  Write a DATA Step that will read this directory 
and each file within it.  

Use the DOPEN,  DNUM, and DREAD functions to process a directory.

This step is just a proof on concept to see if we are 
actually reading the contents correctly.  

The results are written to the log.
********************************************************/

data _null_;
rc=filename("mydir", "Q:\SAMPLE_SAS_PROGRAM\JOE-SAMPLE-SAS-CODE\sample accelerometer data");
did=dopen("mydir");
if did > 0 then do;
    num = dnum(did);
    do i = 1 to num;
        fname=dread(did, i);
        put fname=;
		output;
    end;
end;
run;


/********************************************************
filename()

libname raw "path";
libname associates a shortcut name with a path

filename is similar but the shortcut name 
is used for dopen()(limit 8 characters-cannot use full path) 
********************************************************/



/********************************************************

Everything appears to be working fine, so let's modify 
the DATA step to create a SAS dataset that contains an 
observation for each spreadsheet name.  

********************************************************/
data ss_list;
    rc=filename("mydir", "Q:\SAMPLE_SAS_PROGRAM\JOE-SAMPLE-SAS-CODE\sample accelerometer data");
    did=dopen("mydir");
    num = dnum(did);
    if did > 0 then do i = 1 to dnum(did);
        ss_name=dread(did, i);
        output;
    end;
    rc=dclose(did);
run;

proc print data= work.ss_list noobs;
run;


/* PROC IMPORT program to read the first spreadsheet and create the first SAS dataset*/
proc import out= work._8_50_Start_3_11_19_W4
    datafile = "Q:\SAMPLE_SAS_PROGRAM\JOE-SAMPLE-SAS-CODE\sample accelerometer data\Start_8 50 3 11 19_W4.xlsx"
    dbms=xlsx;
run;



%let sas_ds = _8_50_Start_3_11_19_W4;
%let ssheet = 8 50 Start_3 11 19_W4.xlsx;

proc import out= work.&sas_ds
    datafile = "Q:\SAMPLE_SAS_PROGRAM\JOE-SAMPLE-SAS-CODE\sample accelerometer data\&ssheet"
    dbms=xlsx;
run;


/*MACRO*/


%macro read_ss(sas_ds, ssheet);

proc import out= work.&sas_ds
    datafile = "Q:\SAMPLE_SAS_PROGRAM\JOE-SAMPLE-SAS-CODE\sample accelerometer data\&ssheet"
    dbms=xlsx;
run;

%mend read_ss;

/*%read_ss(_8_50_Start_3_11_19_W4, 8 50 Start_3 11 19_W4.xlsx);*/
%read_ss(Start_3_11_19_W4, Start_3 11 19_W4.xlsx);


/* Write a DATA Step to create valid SAS names 
from the spreadsheet names*/
data _null_;
    set work.ss_list;
    sas_name = scan(translate(ss_name, '_', ' '), 1, '.');
/*    put ss_name = +5 sas_name=;*/
    put ss_name  sas_name;
run;

/*CALL EXECUTE*/
data _null_;
    set work.ss_list;
    sas_name = scan(translate(ss_name, '_', ' '), 1, '.');
	macro_call = cats('%read_ss(',sas_name, ',', ss_name, ')');
    call execute(macro_call);
run;

%read_ss(sas_name, ss_name);
