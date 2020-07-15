
/*CREATE TEST WIDE(FLAT) DATASET*/
data wide;
  input famid faminc96 faminc97 faminc98;
cards;
1 40000 40500 41000 
2 45000 45400 45800
3 75000 76000 77000
;
run;
/*QA CHECK THAT DATA IS NOT EMPTY*/
proc print data=wide;
run;

/*METHOD 1 - MORE WORK (TYPING) ON THE PROGRAMMER*/
data longl;
set wide;
year=96;
faminc= faminc96;
output;

year=97;
faminc= faminc97;
output;

year=98;
faminc= faminc98;
output;

drop faminc96-faminc98;
run;
/*QA CHECK THAT LONG1 IS NOT EMPTY*/
proc print data=longl;
run;

/*QA COMPARE DESCRIPTIVES OF THE ORIGINAL AND NEW DATASETS*/
/*THEY SHOULD BE THE SAME*/
proc means data=wide maxdec=2;
var faminc96-faminc98;
run;

proc means data=longl maxdec=2;
class year;
var faminc;
run;


/*METHOD 2 - EFFICIENT LESS TYPING FOR THE PROGRAMMER*/
data test;
  set wide;
  array afaminc(*) faminc96 - faminc98;
    do year = 1 to 3;
      faminc =afaminc(year);
      output;
    end;
  drop faminc96-faminc98;
run;
/*QA CHECK THAT THE DATASET IS NOT EMPTY*/
proc print data=test;
run;

/*CHECK THAT THE SUMMARY STATS OF THE ORIGINAL AND NEW DATASETS ARE IDENTICAL*/
proc means data=wide maxdec=2;
var faminc96-faminc98;
run;

proc means data=test maxdec=2;
class year;
var faminc;
run;


data wide2;
  input famid faminc96 faminc97 faminc98 spend96 spend97 spend98;
cards;
1 40000 40500 41000 38000 39000 40000
2 45000 45400 45800 42000 43000 44000
3 75000 76000 77000 70000 71000 72000
;
run;
data long2;
  set wide2;
  array afaminc(3) faminc96 faminc97 faminc98;
  array aspend(96:98) spend96-spend98;

  do year = 96 to 98;
    faminc=afaminc(year);
    spend=aspend(year);
    output;
  end;

  drop faminc96-faminc98 spend96-spend98;
run;

proc print data=long2;
run;
