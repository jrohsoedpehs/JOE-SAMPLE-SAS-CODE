/*BMIZ - Macro*/


LIBNAME test XPORT "Q:\Terri Lipman\DFH_2019\data\Raw\sayrebmicals_fall.xpt";
libname data "Q:\Terri Lipman\DFH_2019\data\Raw";
PROC COPY in=test out=data;
RUN;

%let datalib='Q:\Terri Lipman\DFH_2019\data\Raw';   *subdirectory for your existing dataset;
%let datain=sayrebmi;     *the name of your existing SAS dataset;
%let dataout=sayrebmiout;    *the name of the dataset you wish to put the results into;
%let saspgm='Q:\Terri Lipman\DFH_2019\programs\Draft\gc-calculate-BIV.sas'; *subdirectory for the downloaded program gc-calculate-BIV.sas;

Libname mydata &datalib;

data _INDATA; set mydata.&datain;

%include &saspgm;

data mydata.&dataout; set _INDATA;
proc means;

run;

PROC EXPORT DATA= DATA.SAYREBMIOUT 
            OUTFILE= "Q:\Terri Lipman\DFH_2019\data\Raw\sayrebmiout2018_fall.dta" 
            DBMS=STATA REPLACE;
RUN;
