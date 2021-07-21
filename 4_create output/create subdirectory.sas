/*Hi Joseph,

If we have not already done so, I suspect that we should create a SC subdirectory 
similar to the way we have a DSMB directory.  Do you agree, since there will be 
repeating SC meetings just like repeating SC meetings?

Thanks,
Jesse
*/


/*The following creates a SC subdirectory */
/*similar to the way we have a DSMB directory*/

/*UPDATE PATH WITH SUBDIRECTORY AS NEEDED*/
%let path = Q:\Julio Chirinos\FERMIN_2020\SC;

%let test = SC_%sysfunc( today(), MONYY7.);
%put &test;

/*Create the monthly folder and standard subdirectories i.e. &path\SC_JUN2021
-If the folders already exist, they will not be over-written or replaced */

data _null_;
/*	set work.directoryData;*/
	v2 = "&path";
	fullPath = "&path" || "\SC_%sysfunc( today(), MONYY7. /*YYMMDDn8*/ )";
	out = dcreate("SC_%sysfunc( today(), MONYY7.)", v2);

	outarchive = dcreate("archive", fullPath);

    Pathdata = 	fullPath || "\data";
	outdata = dcreate("data", fullPath);
	outDerived = dcreate("Derived", Pathdata);
	outRaw = dcreate("Raw", Pathdata);

    Pathdocuments = fullPath || "\documents";
	outdocuments = dcreate("documents", fullPath);
	outbilling = dcreate("billing", Pathdocuments);
	outoutput = dcreate("output", Pathdocuments);
	outprotocol = dcreate("project protocol", Pathdocuments);
	outQA = dcreate("QA", Pathdocuments);
	outReports = dcreate("Reports", Pathdocuments);
	outprocedures = dcreate("scoring procedures", Pathdocuments);

    Pathprograms = 	fullPath || "\programs";
	outprograms = dcreate("programs", fullPath);
	outDraft = dcreate("Draft", Pathprograms);
	outFinal = dcreate("Final", Pathprograms);

	outREDCap = dcreate("REDCap Downloads", fullPath);
run;
