/*HOW TO EXPORT AND IMPORT FORMATS (AS SAS DATASETS)*/

proc format library=work.formats cntlout = redcap.formats; 
run; 

proc format library=raw.pisces_formats cntlin=redcap.formats; 
run; 
