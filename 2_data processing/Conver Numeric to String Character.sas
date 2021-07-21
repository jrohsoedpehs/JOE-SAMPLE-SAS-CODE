/*PUT FUNCTION*/
/*CONVERT NUMERIC TO STRING / CHARACTER*/

data NumericToChar;
    zip = 2100;
    charzip = put (zip, 4.);
    put zip 4.;
run;

proc contents data= NumericToChar;
run;

proc print data= NumericToChar;
run;
