PROC IMPORT OUT= WORK.Data 
            DATAFILE= "U:\Jinyoung Kim\Snoring_2015\data\Raw\Data _ Copy
 of Jesse_9_29_2015.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
