/*DEFAULT IMPORT CODE*/
PROC IMPORT OUT= WORK.Data 
            DATAFILE= "Path\file.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;


/*IMPORT CODE - AVOIDS TRUNCATION*/
PROC IMPORT OUT= DERIVED.dsn 
            DATAFILE= "Path\file.csv" 
            DBMS=CSV REPLACE;
	 GUESSINGROWS = 32767;  /*avoids truncation by checking x rows for format vs default 20*/
	 GETNAMES=YES;
     DATAROW=2;            /*read data starting at row 2*/
RUN;
