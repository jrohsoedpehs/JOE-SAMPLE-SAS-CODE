/*First create a path macro that uses the path macro madde in cr00 (thus you need to run your personal cr00 before running
this code*/
%let pathToDirFile = &path\&project\M2_DCC_CR_SAS-Programs\sas_libs_m2.csv;

/*Second, Import the file containing the path information*/

proc import datafile= "&pathToDirFile" DBMS = csv
	out = directoryData
	replace;
run;

/*Third, Create the folders on the local drive 
-If the folders already exist, they will not be over-written or replaced */

data _null_;
	set work.directoryData;
	v2 = "&path";
	fullPath = "&path" || Folder;
	out = dcreate(Folder, v2);
	
	outRaw = dcreate("Raw Data", fullPath);
	outImported = dcreate("Imported Data", fullPath);
	outDerived = dcreate("Derived SAS Data", fullPath);
	outOutput = dcreate("Output", fullPath);
	
run;

/* Assign libraries */

data _null_;
	set work.directoryData;
	fullPath = "&path" || Folder;

	outRaw = cats("'", fullPath,"\Raw Data", "'");
	outImported = cats("'", fullPath,"\Imported Data", "'");
	outDerived = cats("'", fullPath,"\Derived SAS Data", "'");

	rawLibName = cats(stem, "r");
	importedLibName = cats(stem, "i");
	derivedLibName = cats(stem, "d");

	rawCall = catx(" ","libname ", rawLibName, outRaw, ";");
	importedCall = catx(" ","libname ", importedLibName, outImported, ";");
	derivedCall = catx(" ","libname ", derivedLibName, outDerived, ";");
	Call Execute(rawCall);
	Call Execute(importedCall);
	Call Execute(derivedCall);
run;
