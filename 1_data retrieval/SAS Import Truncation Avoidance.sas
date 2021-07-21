
PROC IMPORT OUT= DERIVED.DEIDENTIFIED3 
            DATAFILE= "U:\Charlene Compher\Malnutrition_2016\data\Raw\FY
2015 Penn Data Store Report No Malnutrition-deidentified 2.csv" 
            DBMS=CSV REPLACE;
	 GUESSINGROWS = 32767;
	 GETNAMES=YES;
     DATAROW=2; 
RUN;
