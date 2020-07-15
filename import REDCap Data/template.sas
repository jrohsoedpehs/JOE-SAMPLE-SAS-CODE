/*ADD RAW LIBRARY*/
libname RAW "";



/*IMPORT CODE FROM REDCAP*/



/*SAVE FORMATS*/
proc format library=raw.pisces_formats; 
run; 

/*proc format library=raw.pisces_formats cntlin=redcap.pisces_formats; */
/*run; */


/*CNTLOUT=   Create a SAS data set that stores information about informats or formats. */
/*CNTLIN=    Specify a SAS data set from which PROC FORMAT builds informats or formats.*/
