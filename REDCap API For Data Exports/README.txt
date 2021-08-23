DSMB ALL IN ONE PROGRAM INSTRUCTIONS

The following SAS program:

"Q:\Jordana Cohen\BLOCK HFpEF\programs\Draft\dsmb_all_in_one.sas"

will 1) create a time stamped subdirectory under 
Q:\Jordana Cohen\BLOCK HFpEF\DSMB\DSMB_MMMYYYY
i.e. Q:\Jordana Cohen\BLOCK HFpEF\DSMB\DSMB_AUG2021

2) export data to 
Q:\Jordana Cohen\BLOCK HFpEF\DSMB\DSMB_MMMYYYY\REDCap Downloads\archiveYYYYMMDD export data to SAS
i.e. Q:\Jordana Cohen\BLOCK HFpEF\DSMB\DSMB_AUG2021\REDCap Downloads\archive20210823 export data to SAS

3) import and respectively save the data to 
Q:\Jordana Cohen\BLOCK HFpEF\DSMB\DSMB_MMMYYYY\data\Raw\
i.e. Q:\Jordana Cohen\BLOCK HFpEF\DSMB\DSMB_AUG2021\data\Raw\

and
Q:\Jordana Cohen\BLOCK HFpEF\DSMB\DSMB_MMMYYYY\data\Derived\
i.e. Q:\Jordana Cohen\BLOCK HFpEF\DSMB\DSMB_AUG2021\data\Derived\



and 4) generate reports and save them under 
Q:\Jordana Cohen\BLOCK HFpEF\DSMB\DSMB_MMMYYYY\data\Derived\
i.e. Q:\Jordana Cohen\BLOCK HFpEF\DSMB\DSMB_AUG2021\documents\output\


In order for this code to work, please rename treatment group excel file from the pharmacist from default name (i.e. P1895 DSMB Subject Data  04 Aug 2021.xlsx) to treatment.xlsx
This allows a standard name to import data with out updating the SAS code