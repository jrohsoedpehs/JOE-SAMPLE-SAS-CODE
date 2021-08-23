/**U drive;*/

/*libname raw 'U:\Julio Chirinos\Paper_Fall_2012\data\Raw' ;*/
/**/
/*footnote "SAS program stored: U:\Julio Chirinos\Paper_Fall_2012\programs\Draft"; */


*H drive;

libname raw 'H:\Secured Folders\Research Statistics\Julio Chirinos\Paper_Fall_2012\data\Raw' ;

footnote "SAS program stored: H:\Secured Folders\Research Statistics\Julio Chirinos\Paper_Fall_2012\programs\Draft";

*proc contents;
proc contents data=raw.cosa_ali_1; run;

proc contents data=raw.cosa_ali_2; run;

*convert from Char to Num QNS converted to missing;
data ncosa_ali_1;
    set raw.cosa_ali_1;
	Apo_CIII_ = Apo_CIII*1;
run;

data ncosa_ali_2;
    set raw.cosa_ali_2;
	Apo_CIII_ = Apo_CIII*1;
run;

*proc means;

proc means data=ncosa_ali_1 maxdec=2;
var Apo_CIII_;
run;

proc means data=ncosa_ali_2 maxdec=2;
var Apo_CIII_;
run;
