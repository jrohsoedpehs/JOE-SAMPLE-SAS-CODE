/*Clean out old SAS Work Folders*/
/**/
/*Often, old SAS Work folders do not get cleared when SAS closes. */
/*You can get back a lot of disk space by going to the path defined for SAS Work, */
/*and deleting all the old folders.*/
%put %sysfunc(pathname(work));

/*will show you where the current WORK library is located. */
/*One level up is where all SAS Work folders are created.*/

/*On my system, that returns:*/
/*C:\Users\dpazzula\AppData\Local\Temp\SAS Temporary Files\_TD9512_GXM2L12-PAZZULA_*/

/*That means that I should look in "C:\Users\dpazzula\AppData\Local\Temp\SAS Temporary Files\" */
/*to find old folders to delete*/
