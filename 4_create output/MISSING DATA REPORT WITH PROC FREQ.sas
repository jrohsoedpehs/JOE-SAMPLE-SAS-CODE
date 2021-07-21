/*https://www.lexjansen.com/nesug/nesug11/ds/ds12.pdf*/

/*MISSING DATA REPORT WITH PROC FREQ*/

proc contents data=derived.demo; run;

proc freq data=derived.demo;
tables _all_ / missing;
run;
/*too much output*/


/*What is needed is some way to group the*/
/*non-missing values and that will be done with formats, one*/
/*each for numeric and character variables.*/

* EXAMPLE 2;
proc format;
    value nm
        . = 'MISSING'
        other = 'OK';

    value $ch
        ' ' = 'MISSING'
        other = 'OK';
run;


/*Example 2 creates the two formats, NM. for numeric variables*/
/*and $CH. for character variables. Since SAS has twenty-seven*/
/*different ways of representing missing numeric, a period plus .a*/
/*through .z, you could use a range for missing numeric data in*/
/*example 2 ...*/
/*. - .z = 'MISSING'*/


* EXAMPLE 3;
proc freq data=derived.demo;
    tables _all_ / missing;
    format _numeric_ nm. _character_ $ch.;
run;

/*Using the formats as shown in example 3 condenses all the*/
/*tables to just two entries, OK and MISSING*/

/*However, when the number of*/
/*variables in a data set is large, even the condensed tables*/
/*would require a lot of room. If the results of example 3 could be*/
/*sent to a data set rather than to the display manager output*/
/*window or a file, the information could be reformatted.*/

* EXAMPLE 4;
proc freq data=derived.demo;
    tables _all_ / noprint missing out=tables;
    format _numeric_ nm. _character_ $ch.;
run;

proc print data=tables; run;
/*One common way to direct the results of PROC FREQ to a*/
/*data set is to use procedure options as shown in example 4.*/
/*The NOPRINT option is used to suppress printed results and*/
/*the OUT option directs the results to a data set name TABLES.*/
/*Though example 4 produces a data set, that date set only*/
/*contains a table of values for the last variable in the data set.*/



/*ODS offers an alternative to procedure options for an easy way to produce a data set with tables of all variables in a*/
/*data set. An ODS OUTPUT statement can be used to direct all or parts of the output of any procedure to a data*/
/*set. The key piece of information is the ODS table name for PROC FREQ output of one-way tables (i.e. tables with*/
/*only one variable). You can find that name by running PROC FREQ with the ODS TRACE option turned on and*/
/*looking in the LOG for the ODS table name. You can also find that name in SAS online help and the name that*/
/*ODS assigns to that output is ONEWAYFREQS.*/

* EXAMPLE 5;
proc format;
    value nm . = '0' other = '1';
    value $ch ' ' = '0' other = '1';
run;

ods listing close;
ods output onewayfreqs=tables;

proc freq data=derived.demo;
   tables _all_ / missing;
    format _numeric_ nm. _character_ $ch.;
run;

ods output close;
ods listing;

proc print data=tables;
    format _all_;
run;



/**************************/
proc format;
    value nm . = '0' other = '1';
    value $ch ' ' = '0' other = '1';
run;

ods Excel file="Q:\Barbara Riegel\Caregiver_RO1_2019\DSMB\DSMB_2021_Spring\documents\output\Missing Data for Caregivers with Proc Print &sysdate..xlsx" ;
ods Excel OPTIONS(SHEET_INTERVAL="none" SHEET_NAME="Sheet1" EMBEDDED_TITLES="yes");

proc freq data=derived.demo;
    tables _all_ / noprint missing out=tables;
    format _numeric_ nm. _character_ $ch.;
run;



* EXAMPLE 6;
data report;
    length var $32; 
    do until (last.table);
        set tables;
        by table notsorted;
        array names(*) f_: ;

        select (names(_n_));
 
            when ('0') do;
                miss = frequency;
                p_miss = percent;
            end;

            when ('1') do;
                ok = frequency;
                p_ok = percent;
            end;

        end;
   end;

    miss = coalesce(miss,0);
    ok = coalesce(ok,0);
    p_miss = coalesce(p_miss,0);
    p_ok = coalesce(p_ok,0);
    var = scan(table,-1);

    keep var miss ok p_: ;

    format miss ok comma7. p_: 5.1;

    label
    miss = 'N_MISSING'
    ok = 'N_OK'
    p_miss = '%_MISSING'
    p_ok = '%_OK'
    var = 'VARIABLE';
run;

ods excel close;
