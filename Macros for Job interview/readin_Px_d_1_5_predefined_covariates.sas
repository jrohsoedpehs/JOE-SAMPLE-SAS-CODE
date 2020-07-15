**********************************************************************************
** Program name : readin_Px_d_1_5_predefined_covariates.sas		  	  			 						  	
** input dataset :  /project/shennessy2/disdva/biostats/rawdata/MEDICAID/
**					in_ca1999-in_ca2012.sas7dbat ot_ca1999-ot_ca2012.sas7dbat
					in_pa1999-in_pa2012.sas7dbat ot_pa1999-ot_pa2012.sas7dbat
					in_fl1999-in_fl2012.sas7dbat ot_fl1999-ot_fl2012.sas7dbat
					in_ny1999-in_ny2012.sas7dbat ot_ny1999-ot_ny2012.sas7dbat
					in_oh1999-in_oh2012.sas7dbat ot_oh1999-ot_oh2012.sas7dbat
					lt_ca1999-lt_ca2012.sas7dbat lt_pa1999-lt_pa2012.sas7dbat 
					lt_fl1999-lt_fl2012.sas7dbat lt_ny1999-lt_ny2012.sas7dbat 
					lt_oh1999-lt_oh2012.sas7dbat 
					/project/shennessy2/disdva/biostats/rawdata/MEDICARE/
 					Raw_medpar1999-2012 
 					op1999.sas7dbat-op2002.sas7dbat  Bcarclms2003.sas7dbat-Bcarclms2012.sas7dbat 
 					pb1999.sas7dbat-bp2003.sas7dbat  Otptclms2003.sas7dbat-Otptclms2012.sas7dbat  
					/project/drugdrug_inter/biostats/OAD_SCAVA_0443/data/code/
 					code.Px_predefined_covariates_code .sas7dbat
** Output dataset :	/project/drugdrug_inter/biostats/OAD_SCAVA_0443/data/raw/
					 CPT_predefined_covariates.sas7dbat 
** Date Started  : 5/5/2018                                         
** Last Revised  : 5/5/2018                                          			
** Written by    :  Min Du                                 		
**********************************************************************************;

%let sh=U;** Rawmed Rawmcare drive letter **;
%let p=V;** Statin drive letter **;
%macro plat;
	%if &sysscp = WIN %then %do;
		%include  "&p.:\biostats\OAD_SCAVA_0443\programs\lib_name.sas";
	%end;
	%else %if &sysscp = SUN 4 or &sysscp = SUN 64 or (&sysscp = LIN X64) %then %do; 
		%include  '/project/drugdrug_inter/biostats/OAD_SCAVA_0443/programs/lib_name.sas'; 
	%end;
%mend;
%plat;

data code;
length medcode $ 8;
 	set  code.Px_predefined_covariates_code(rename=medcode=code) ;	
    medcode=strip(code);  
run;
%macro split1(orig,num);
data _null_;
if 0 then set &orig nobs=count;
call symput('numobs',put(count,10.));
run;
%let n=%sysevalf(&numobs/&num,ceil);
data %do J=1 %to &num ; &orig._&J %end; ;
set &orig;
%do I=1 %to &num;
if %eval(&n*(&i-1)) <_n_ <= %eval(&n*&I)
then output &orig._&I;
%end;
run;
%mend split1; 

%macro find_VA_Mcaid_ip(dataset);
%let varlist = oh*ca*pa*ny*fl;
%let varnum=5;
		%do a=1 %to &varnum;
		%let state = %scan(&varlist,&a, '*');
data temp&state;
   length  %do i=1 %to 6;  PROC&i._CODE_&dataset $ 8 %end;;
	set	 %DO d=1999 %TO 2012;
	rawmed.&dataset._&state.&d ( keep=state msis DT_PROC  
		%do i=1 %to 6;  
			PROC&i._CODE_&dataset  
		%end; )
	%end;;
run; 
data &dataset.&state;
 if _n_ = 1 then do;
   if 0 then set code;**The dataset containing the CHF codes;
   declare hash lookup(dataset:"code (keep=medcode class)");**The dataset containing the CHF codes;
   lookup.definekey("medcode");*Key is medcode;
   lookup.definedata("medcode","class");
   lookup.definedone();
 end;
 set temp&state;**Use the new THIN;
 	dataname="&dataset";
	%do i=1 %to 6;
	if lookup.find(key:strip(PROC&i._CODE_&dataset))=0 then 
		do;  
			dt_fill=DT_PROC; 
			format dt_fill mmddyy10.;
			output;
		end; 
	%end;
	run;
proc sort data=	&dataset.&state (keep=state msis medcode dt_fill) nodup;
    by _all_;
run;
%end;
%mend; 
%find_VA_Mcaid_ip(in);

%macro find_VA_Mcaid_ot(dataset);
%let varlist = ca*pa*ny*oh*fl;
%let varnum=5;
		%do a=1 %to &varnum;
		%let state = %scan(&varlist,&a, '*');
data temp&state;
   length  PROC1_&dataset.  $ 8  ;
	set %DO d=1999 %TO 2012;
		rawmed.&dataset._&state.&d ( keep=state msis dt_beg_&dataset. PROC1_&dataset. ) 
		%end;;
run;  
data  &dataset.&state;
 if _n_ = 1 then do;
   if 0 then set code;**The dataset containing the CHF codes;
   declare hash lookup(dataset:"code (keep=medcode class)");**The dataset containing the CHF codes;
   lookup.definekey("medcode");*Key is medcode;
   lookup.definedata("medcode","class");
   lookup.definedone();
 end;
 set temp&state;**Use the new THIN;
  	dataname="&dataset";
	if (lookup.find(key:strip(PROC1_&dataset.)) = 0) then 
		do;
			  dt_fill=dt_beg_&dataset ; 
			output; 
		end;
	run;
	
proc sort data=	&dataset.&state (keep=state msis medcode dt_fill)nodup;
    by _all_;
run;
%end;
%mend;
%find_VA_Mcaid_ot(ot);

%macro medicare(dataset);
data tempCA tempPA tempNY tempFL tempOH;
	length  %do i=1 %to 25;  PRCDR_CD&i  $ 8 %end;;
	set %DO I=1999 %TO 2012;
		rawmcare.Raw_medpar&I ( keep=state msis PRCDRDT: PRCDR_CD:)
		%END;;    
   if  strip(State)='CA' then output tempCA;
   if  strip(State)='PA' then output tempPA;
   if  strip(State)='NY' then output tempNY;
   if  strip(State)='FL' then output tempFL;
   if  strip(State)='OH' then output tempOH;  
run;
%let varlist = ca*pa*ny*oh*fl;
		%do a=1 %to 5;
		%let state = %scan(&varlist,&a, '*');
data &dataset.&state;
 if _n_ = 1 then do;
   if 0 then set code;**The dataset containing the CHF codes;
   declare hash lookup(dataset:"code (keep=medcode class)");**The dataset containing the CHF codes;
   lookup.definekey("medcode");*Key is medcode;
   lookup.definedata("medcode","class");
   lookup.definedone();
 end;
 set temp&state;**Use the new THIN;
 	dataname="&dataset";
	%do i=1 %to 25;
	if lookup.find(key:strip(PRCDR_CD&i) )=0 then 
		do;
			dnum=&i; dt_fill=PRCDRDT&i;
			output;
		end;
	%end;
run;

proc sort data=	&dataset.&state (keep=state msis  dt_fill medcode ) nodup;
    by _all_;
run;
%end;
%mend;
%medicare(mpar);

%macro find_VA_Car(dataset);
data tempCA tempPA tempNY tempFL tempOH;
   length  %do i=1 %to 9;  HCPSCD0&i $ 8 %end;
		   %do i=10 %to 13;  HCPSCD&i $ 8 %end;;
	set %DO y=1999 %TO 2003;
		rawmcare.pb&y( keep= state msis HCPSCD: EXP_DT: )
		%END;; 
    if  strip(State)='CA' then output tempCA;
    if  strip(State)='PA' then output tempPA;
    if  strip(State)='NY' then output tempNY;
    if  strip(State)='FL' then output tempFL;
    if  strip(State)='OH' then output tempOH; 
run;
%let varlist = ca*pa*ny*oh*fl;
		%do a=1 %to 5;
		%let state = %scan(&varlist,&a, '*');
data t1&dataset.&state;
 if _n_ = 1 then do;
   if 0 then set code;**The dataset containing the CHF codes;
   declare hash lookup(dataset:"code (keep=medcode class)");**The dataset containing the CHF codes;
   lookup.definekey("medcode");*Key is medcode;
   lookup.definedata("medcode","class");
   lookup.definedone();
 end;
 set temp&state;**Use the new THIN;
 	dataname="&dataset";
    
	%do i=1 %to 9;
	if lookup.find(key:strip(HCPSCD0&i ))=0 then 
		do; 
			dt_fill=EXP_DT1&i;
			if EXP_DT1&i=. then  dt_fill=EXP_DT2&i;
			output;
		end;
	%end;
	%do i=10 %to 13;
	if lookup.find(key:strip(HCPSCD&i ))=0 then 
		do; 
			dt_fill=EXP_DT1&i;
			if EXP_DT1&i=. then  dt_fill=EXP_DT2&i;
			output; 
		end;
	%end;
run;
%end; 
data tempCA tempPA tempNY tempFL tempOH;
	length HCPCS_CD $ 8 ;
	set %DO y=2004 %TO 2012;
		rawmcare.Bcarline&y ( keep= state msis EXPNSDT: HCPCS_CD)
		%END;;  
	   if  strip(State)='CA' then output tempCA;
	   if  strip(State)='PA' then output tempPA;
	   if  strip(State)='NY' then output tempNY;
	   if  strip(State)='FL' then output tempFL;
	   if  strip(State)='OH' then output tempOH;  
run;
%let varlist = ca*pa*ny*oh*fl;
%do a=1 %to 5;
		%let state = %scan(&varlist,&a, '*');
data t2&dataset.&state;
 if _n_ = 1 then do;
   if 0 then set code;**The dataset containing the CHF codes;
   declare hash lookup(dataset:"code (keep=medcode class)");**The dataset containing the CHF codes;
   lookup.definekey("medcode");*Key is medcode;
   lookup.definedata("medcode","class");
   lookup.definedone();
 end;
 set temp&state;**Use the new THIN;
 	dataname="&dataset";
	if lookup.find(key:strip(HCPCS_CD) )=0 then
		do; 
		dt_fill=EXPNSDT1;
		if EXPNSDT1=. then dt_fill=EXPNSDT2;
	    format dt_fill mmddyy10.; 
		output;
		end;
run;
%end;
data &dataset;
    set %do f=1 %to 5; 
	%let state = %scan(&varlist,&f, '*'); 
	t1&dataset.&state t2&dataset.&state %end;;
	keep state msis medcode dt_fill ;
run;

proc sort data=	&dataset nodup;
    by _all_;
run;
%mend;
%find_VA_Car(carrier);

%macro find_VA_SAF(dataset);
data tempCA tempPA tempNY tempFL tempOH;
	length 	%do a=1 %to 6; PRCDRCD&a $ 8 %end;
			%do b=1 %to 9; HCPSCD0&b $ 8 %end;
			%do c=10 %to 45; HCPSCD&c $ 8 %end;;
	set %DO I=1999 %TO 2003;
		rawmcare.op&I ( keep= state msis PRCDRCD: PRCDR_DT: REVDT: HCPSCD:)
		%END;;  
   if  strip(State)='CA' then output tempCA;
   if  strip(State)='PA' then output tempPA;
   if  strip(State)='NY' then output tempNY;
   if  strip(State)='FL' then output tempFL;
   if  strip(State)='OH' then output tempOH;  
run;
%let varlist = ca*pa*ny*oh*fl;
		%do a=1 %to 5;
		%let state = %scan(&varlist,&a, '*');
data t1&dataset.&state;
 if _n_ = 1 then do;
   if 0 then set code;**The dataset containing the CHF codes;
   declare hash lookup(dataset:"code (keep=medcode class)");**The dataset containing the CHF codes;
   lookup.definekey("medcode");*Key is medcode;
   lookup.definedata("medcode","class");
   lookup.definedone();
 end;
 set temp&state;**Use the new THIN;
 	dataname="&dataset";
	%do i=1 %to 6;
	if lookup.find(key:strip(PRCDRCD&i ))=0 then 
		do;
			dt_fill=PRCDR_DT&i;
			output; 
		end;
	%end;
 	%do i=1 %to 9;
	if lookup.find(key:strip(HCPSCD0&i ))=0 then 
		do;
			dt_fill=REVDT0&i;
			output; 
		end;
	%end;
	%do i=10 %to 45;
	if lookup.find(key:strip(HCPSCD&i ))=0 then 
		do;
			dt_fill=REVDT&i;
			output; 
		end;
	%end;
run;
%end;
data tempCA tempPA tempNY tempFL tempOH;
   length  %do i=1 %to 25; PRCDRCD&i $ 8 %end;;
	set %DO I=2004 %TO 2012;
		rawmcare.Otptclms&I ( keep= state msis PRCDR_DT: PRCDRCD: )
		%END;;
   if  strip(State)='CA' then output tempCA;
   if  strip(State)='PA' then output tempPA;
   if  strip(State)='NY' then output tempNY;
   if  strip(State)='FL' then output tempFL;
   if  strip(State)='OH' then output tempOH;
run;
%let varlist = ca*pa*ny*oh*fl;
		%do a=1 %to 5;
		%let state = %scan(&varlist,&a, '*');
data t2&dataset.&state;
 if _n_ = 1 then do;
   if 0 then set code;**The dataset containing the CHF codes;
   declare hash lookup(dataset:"code (keep=medcode class)");**The dataset containing the CHF codes;
   lookup.definekey("medcode");*Key is medcode;
   lookup.definedata("medcode","class");
   lookup.definedone();
 end;
 set temp&state;**Use the new THIN;
 	dataname="&dataset";
	%do i=1 %to 25;
	if lookup.find(key:strip(PRCDRCD&i ))=0 then 
		do;
			dt_fill=PRCDR_DT&i; 
			output;
		end;
	%end;
run;
%end;
data tempCA tempPA tempNY tempFL tempOH;
   length  HCPCS_CD $ 8  ;
	set %DO I=2004 %TO 2012;
		rawmcare.Otptrev&I ( keep= state msis rev_dt HCPCS_CD )
		%END;;
   if  strip(State)='CA' then output tempCA;
   if  strip(State)='PA' then output tempPA;
   if  strip(State)='NY' then output tempNY;
   if  strip(State)='FL' then output tempFL;
   if  strip(State)='OH' then output tempOH;
run;
%let varlist = ca*pa*ny*oh*fl;
		%do a=1 %to 5;
		%let state = %scan(&varlist,&a, '*');
data t3&dataset.&state;
 if _n_ = 1 then do;
   if 0 then set code;**The dataset containing the CHF codes;
   declare hash lookup(dataset:"code (keep=medcode class)");**The dataset containing the CHF codes;
   lookup.definekey("medcode");*Key is medcode;
   lookup.definedata("medcode","class");
   lookup.definedone();
 end;
 set temp&state;**Use the new THIN;
 	dataname="&dataset";
	 
	if lookup.find(key:strip(HCPCS_CD))=0 then 
		do;	
			dt_fill=rev_dt; 
			output;
		end;
run;
%end;

data &dataset;
    set %do f=1 %to 5; 
	%let state = %scan(&varlist,&f, '*'); 
	t1&dataset.&state(keep=state msis medcode dt_fill)
	t2&dataset.&state(keep=state msis medcode dt_fill)
	t3&dataset.&state(keep=state msis medcode dt_fill)
	%end;;
run;

proc sort data=	&dataset 
	out= &dataset nodup;
    by _all_;
run;
%mend;
%find_VA_SAF(outsnf);

%macro set_rx();
%let statelist = ca fl ny oh pa;
data dis_confounders;
	set outsnf carrier  
		%do b=1 %to 5;	%let state = %scan(&statelist,&b);
		ot&state in&state mpar&state 
		%end;;
	keep state msis medcode dt_fill  ;
run;  
proc sort data=dis_confounders  nodup;
	by state msis medcode dt_fill;
run;
data raw.CPT_predefined_covariates;
   set dis_confounders;
   by state msis medcode dt_fill;
/*   where  mdy(1,1,1999)<=dt_fill<=mdy(12,31,2005);*/
   format dt_fill mmddyy10.;
run;
%mend;
%set_rx(); 	
data CPT_predefined_covariates;
set raw.CPT_predefined_covariates;
run;
proc sql;
	create table raw.CPT_predefined_covariates as
	select state, msis, dt_fill as diag_date,  a.medcode,b.class 
	from work.CPT_predefined_covariates   as a , work.code  as b
	where trim(left(a.medcode))=trim(left(b.medcode))  ;
quit;  
