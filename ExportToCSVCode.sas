PROC EXPORT DATA= RAW.F1 
            OUTFILE= "U:\Mark Fogel\R01 Nov2014\data\Derived\Saturations
TestExport.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;
