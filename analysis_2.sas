libname raw 'H:\Secured Folders\Research Statistics\Jesse Chittams\Retail Clinic Data\data\Raw\'; 

libname derived 'H:\Secured Folders\Research Statistics\Jesse Chittams\Retail Clinic Data\data\Derived';

footnote "SAS program stored: H:\Secured Folders\Research Statistics\Jesse Chittams\Retail Clinic Data\programs\Analysis_2.sas";

*****************************************************************************************************************************************************************;
proc contents data=derived.retailclinics_all; run;
proc format ;
value mua	0='Non-MUA'
			1='MUA';
run;

*creating mua indicator variable for each clinic to help with mua analyses;
data derived.retailclinics_all;
	set derived.retailclinics_all;

	if mua_score = . then mua_status = 0;
	if mua_score ne . then mua_status = 1;
run;

*QA;
proc freq data=derived.retailclinics_all;
tables mua_score*mua_status/list missing;
run;

*finding open year of mua clinics;
ods rtf file="T:\documents\output\MUA clinics &sysdate..rtf" style=journal;
proc print data=derived.retailclinics_all noobs;
where mua_status=1;
var city mua_score openyear;
title 'Open Year of Clinics in MUAs';
run;
proc sort data=derived.retailclinics_all; by mua_status; run;
proc freq data=derived.retailclinics_all;
by mua_status;
tables openyear;
title 'Year Counts of When MUA Clinics Opened';
format mua_status mua.;
run;
ods rtf close;

*socio-demographic comparisons of mua clinics vs nonmua clinics;
%macro tab(x);
proc tabulate data=derived.retailclinics_all format=5.2;
	class mua_status;
	var &x;
	table(&x)*mua_status*(n mean std);
	title "&x summary of MUA clinics vs. Non-MUA clinics";
	format mua_status mua.;
run;
%mend tab;

ods rtf file="T:\documents\output\Clinic Comparisons &sysdate..rtf" ;
%tab(medage_06);
%tab(medhinc_06);
%tab(unemprt_06);
%tab(healthinsurance_06);
%tab(healthcare_06);
%tab(white_06);
%tab(black_06);
%tab(asian_06);
%tab(pacific_06);
%tab(amerind_06);
%tab(othrace_06);


ods select none;
proc npar1way data=derived.retailclinics_all anova wilcoxon;
	class mua_status;
	var medage_06 medhinc_06 unemprt_06 healthinsurance_06 healthcare_06 white_06 black_06 asian_06 pacific_06 amerind_06 othrace_06;
	ods output WilcoxonTest=WilcoxonTest  ANOVA=anova;
quit;
ods select all;

proc print data=anova label; where source = 'Among';
	var variable probf;
	title 'T-Test p-values';
	label probf = 'p-value';
	*format probf p63val.; 
	format probf  pvalue10.4; 
quit;

proc print data=WilcoxonTest label; where name1 = 'PT2_WIL';
	var variable nValue1;
	title 'Wilcoxon p-values';
	label nValue1 = 'p-value';
	*format nValue1 p63val.; 
	format probf  pvalue10.4; 
quit;
ods rtf close;

*demographics across states comparing 2000 census data and 2010 census data;
%macro tab(x,y);
proc tabulate data=raw.othstates format=5.2;
	class clinstate;
	var &x &y;
	table(&x &y),clinstate*(n mean std);
	title "&x summary by State";
run;
%mend tab;

ods rtf file="T:\documents\output\State Census Comparisons &sysdate..rtf" ;
%tab(medage_06, medage_11);
%tab(medhinc_06,medhinc_11 );
%tab(unemprt_06,unemprt_11);
%tab(healthinsurance_06, healthinsurance_11);
%tab(healthcare_06, healthcare_11);
%tab(pop2000, POP2010_1);
ods rtf close;

*creating permanent datasets for raw MUA data;
proc contents data=raw.pa_mua; run;
proc contents data=raw.region_mua; run;

*creating subset of Tom's data;
data a;
	set raw.retailclinicsnew;
	where state in ("PA", "NJ", "OH");
	clinid=clinic_id;
run;
*QA;
proc freq data=a;
	tables state;
run;

*merge mua data with state data;
proc sort data=raw.othstates; by clinid; run;
proc sort data=raw.pa_mua; by clinid; run;
proc sort data=raw.region_mua (keep=clinid mua hpsa_pc) ; by clinid; run;
proc sort data=a; by clinid; run;

data raw.othstates;
	merge raw.pa_mua raw.region_mua a raw.othstates;
	by clinid;
	mua_code = mua*1;
	hpsa_code = hpsa_pc*1;

	if mua_code = . then mua_status = 0;
	if mua_code ne . then mua_status = 1;

	enterdatemiss = (Date_Entered = .);
	ClinOpenDatemiss = (Date_Opened = .);
	ClinCloseDatemiss = (Date_Closed  = .);
	openyear = year(Date_Opened);
	closedyear = year(Date_Closed);

	if state = "NY" then delete;

	drop mua hpsa_pc ;
run;

*QA;
proc contents data=raw.othstates; run;
proc print data=raw.othstates (obs=50); run;
proc freq data=raw.othstates;
tables mua_code*mua_status/list missing;
tables date_opened*openyear date_closed*closedyear/list missing;
run;

*summary stats;
ods rtf file=" U:\Jesse Chittams\Retail Clinic Data\documents\output\OH_PA MUA Comparison &sysdate..rtf" ;
proc sort data=raw.othstates; by state; run;
proc freq data=raw.othstates;
by state;
tables mua_status;
title 'Percentage of MUA clinics by State';
run;

proc means data=raw.othstates n mean std min max maxdec=2 nonobs;
class state;
var mua_code;
title 'Average MUA by State';
run;

proc freq data=raw.othstates;
where state="PA" or state="OH";
tables mua_status*state/chisq;
title 'Comparing MUA Status Between OH & PA';
run;
ods rtf close;

*finding 33 extra clinic's states;
data b;
	set raw.retailclinicsnew;
	clinid=clinic_id;
run;

proc sort data=b; by clinid; run;
proc sort data=raw.retailclinics0610; by clinid; run;

data find;
	merge b(in=a) raw.retailclinics0610(in=b);
	if a and not b;
	by clinid;
run;
 
ods rtf file="T:\documents\output\33 Extra Clinics' States &sysdate..rtf" style=journal;
proc print data=find;
var clinid state;
title "List of States From 33 Extra Clinics";
run;
ods rtf close;
*****************************************************************************
1)	For PA only, compute the number of Net (cumulative {opened – closed}) number of retail clinics open by County by year.
a.	Generate the difference between 2007 and 2006 and run a proc univariate to obtain inform on distribution (normal plot) and statistical significance (paired t-test and Wilcoxon)
2)	Repeat Step 1 for Ohio
3)	Compare the difference variable between PA and Ohio with County as the unit of analysis using NPAR1way.
*********************************************************************************************************************;

*Cumulative openings for PA;
**by year and county*;

proc sort data=raw.othstates;
where state="PA";
by ClinCensusCountyFips;
run;

**open**;


proc freq data=raw.othstates;
	where state="PA";
	by ClinCensusCountyFips;
	tables openyear/out=count_oy_pa;
run;

proc print data=count_oy_pa;
	run;

data oy_count_pa;
set count_oy_pa ;
count_oy_pa = count ;
year = openyear ;
drop count PERCENT ; 
run;

proc print data=oy_count_pa;
	run;

**closed**;
proc freq data=raw.othstates;
	where state="PA";
	by ClinCensusCountyFips;
	tables closedyear/out=count_cy_pa;
run;

proc print data=count_cy_pa;
	run;

data cy_count_pa;
set count_cy_pa ;
count_cy_pa = count ;
year = closedyear ;
drop count PERCENT;
run;

proc print data=cy_count_pa;
run;

proc sort data=oy_count_pa;
by ClinCensusCountyFips year ;
run;

proc sort data=cy_count_pa;
by ClinCensusCountyFips year;
run;

data oycy_count_pa;
merge oy_count_pa cy_count_pa  ;
by ClinCensusCountyFips year;

if year ne .;
run;

proc sort data=oycy_count_pa;
by ClinCensusCountyFips year;
run;

proc sort data=oycy_count_pa nodupkey out=county(keep=ClinCensusCountyFips) ;
by ClinCensusCountyFips;
run;

data county_yr;
	set county;
	do year = 2006 to 2013;
		output county_yr;
	end;
run;

proc sort data=county_yr;
by ClinCensusCountyFips year;
run;

data derived.oycy_count_1;
merge  oycy_count_pa county_yr ;
by ClinCensusCountyFips year;
if count_oy_pa = . then count_oy_pa = 0;
if count_cy_pa = . then count_cy_pa = 0;
total_count = count_oy_pa + count_cy_pa ;
diff_count = count_oy_pa - count_cy_pa ; 

retain cum_diff;
if first.ClinCensusCountyFips then cum_diff = diff_count; 
 else cum_diff = cum_diff + diff_count; 
if year=2014 then delete; 
run;


proc sort data=derived.oycy_count_1;
	by ClinCensusCountyFips year;
run;

proc print data=derived.oycy_count_1 (obs=50);
var ClinCensusCountyFips year cum_diff  diff_count  count_oy_pa  count_cy_pa;
run;


data oycy_count_1;
	set derived.oycy_count_1;
	if year=2006 or year=2007;
	by ClinCensusCountyFips;

	retain bl_count ;
	if first.ClinCensusCountyFips and year=2006 then bl_count = cum_diff; 
 	Change_count = cum_diff - bl_count;  

	if year=2007;
run;

proc print data=oycy_count_1; run;

*ods rtf file="T:\documents\output\State Census Comparisons &sysdate..rtf" ;
ods trace on;
proc univariate data=oycy_count_1 normal plot ;
where change_count < 12;
var change_count;
histogram change_count;
run;
ods trace off;







proc sort data=raw.othstates;
by state ClinCensusCountyFips;
run;

**open**;


proc freq data=raw.othstates;
	by state ClinCensusCountyFips;
	tables openyear/out=count_oy_pa;
run;

proc print data=count_oy_pa;
	run;

data oy_count_pa;
set count_oy_pa ;
count_oy_pa = count ;
year = openyear ;
drop count PERCENT ; 
run;

proc print data=oy_count_pa;
	run;

**closed**;
proc freq data=raw.othstates;
	by state ClinCensusCountyFips;
	tables closedyear/out=count_cy_pa;
run;

proc print data=count_cy_pa;
	run;

data cy_count_pa;
set count_cy_pa ;
count_cy_pa = count ;
year = closedyear ;
drop count PERCENT;
run;

proc print data=cy_count_pa;
run;

proc sort data=oy_count_pa;
by state ClinCensusCountyFips year ;
run;

proc sort data=cy_count_pa;
by state ClinCensusCountyFips year;
run;

data oycy_count_pa;
merge oy_count_pa cy_count_pa  ;
by state ClinCensusCountyFips year;

if year ne .;
run;

proc sort data=oycy_count_pa;
by state ClinCensusCountyFips year;
run;

proc sort data=oycy_count_pa nodupkey out=county(keep=state ClinCensusCountyFips) ;
by state ClinCensusCountyFips;
run;

proc freq data=county;
tables state;
run;

data county_yr;
	set county;
	do year = 2006 to 2013;
		output county_yr;
	end;
run;

proc sort data=county_yr;
by state ClinCensusCountyFips year;
run;

data derived.oycy_count_1;
merge  oycy_count_pa county_yr ;
by state ClinCensusCountyFips year;
if count_oy_pa = . then count_oy_pa = 0;
if count_cy_pa = . then count_cy_pa = 0;
total_count = count_oy_pa + count_cy_pa ;
diff_count = count_oy_pa - count_cy_pa ; 

retain cum_diff;
if first.ClinCensusCountyFips then cum_diff = diff_count; 
 else cum_diff = cum_diff + diff_count; 
if year=2014 then delete; 
run;


proc sort data=derived.oycy_count_1;
	by state ClinCensusCountyFips year;
run;

proc print data=derived.oycy_count_1 (obs=50);
var state ClinCensusCountyFips year cum_diff  diff_count  count_oy_pa  count_cy_pa;
run;


data oycy_count_1;
	set derived.oycy_count_1;
	if year=2006 or year=2007;
	by state ClinCensusCountyFips;

	retain bl_count ;
	if first.ClinCensusCountyFips and year=2006 then bl_count = cum_diff; 
 	Change_count = cum_diff - bl_count;  

	if year=2007;
run;

proc print data=oycy_count_1; run;

ods rtf file="T:\documents\output\Univariate Analysis &sysdate..rtf" style=journal;
ods exclude Plots ExtremeObs Quantiles TestsForNormality Moments;
proc univariate data=oycy_count_1 ;
class state;
var change_count;
histogram change_count;
run;
ods rtf close;

*generating t-tests comparing regional states to PA with clinic openings;

%macro test(wher);
proc means  data=oycy_count_1 n mean std median min max maxdec = 2 nonobs;
	&wher; 
	class state;
	var change_count;
quit;
ods select none;
proc npar1way data=oycy_count_1 anova wilcoxon;
	&wher;
	class state;
	var change_count;
	ods output WilcoxonTest=WilcoxonTest  ANOVA=anova;
quit;
ods select all;

proc print data=anova label; where source = 'Among';
	var  probf;
	title 'T-Test p-values';
	label probf = 'p-value';
	*format probf p63val.; 
	format probf  pvalue10.4; 
quit;

proc print data=WilcoxonTest label; where name1 = 'PT2_WIL';
	var  nValue1;
	title 'Wilcoxon p-values';
	label nValue1 = 'p-value';
	*format nValue1 p63val.; 
	format probf  pvalue10.4; 
quit;

%mend test;

ods rtf file="T:\documents\output\State Clinic Differences &sysdate..rtf" style=journal;
%test(where state in ("PA" "OH"));
%test(where state="PA" or state="NY");
%test(where state="PA" or state="NJ");
ods rtf close;


*finding open and closed years for all MUA clinics in states of interest;
ods rtf file="T:\documents\output\Open-Closed Years &sysdate..rtf" style=journal;
proc print data=raw.othstates noobs;
where mua_status=1 and state ne "NY";
var clinid city state openyear closedyear;
title 'Open and Closed Years for MUA Clinics';
run;
ods rtf close;

*clinic doesn't have open year;
proc print data=raw.othstates noobs;
where clinid = 18265;
var Date_Entered Date_Opened Date_Closed openyear closedyear;
run;

*redoing race percentages across states;
%macro race(dat,x,titl);

proc sort data=raw.othstates; by mua_status clinid; run;
proc transpose data=raw.othstates  out=a;
where clinstate="PA";
by mua_status clinid;
var &x;
run;

proc freq data=a noprint;
by mua_status clinid;
tables _name_/out=race;
weight col1 ;
run;


%mend race;
%race(percent_mean06, black_06 white_06 asian_06 amerind_06 pacific_06 othrace_06 hisppop_06, 2006 Race Percentages Across States ); 

ods rtf file="T:\documents\output\Clinic Race Comparisons PA &sysdate..rtf" style=journal;
proc sort data=race;
	by _name_;
run;
proc means  data=race n mean std median min max maxdec = 2 nonobs;
	by _name_;
	class mua_status;
	var percent;
	format mua_status mua.;
	title 'Average Race Percents for MUA & Non-MUA Clinics';
quit;
ods select none;
proc npar1way data=race anova wilcoxon;
	by _name_;
	class mua_status;
	var percent;
	ods output WilcoxonTest=WilcoxonTest  ANOVA=anova;
quit;
ods select all;

proc print data=anova label noobs; where source = 'Among';
	var  _name_ probf;
	title 'T-Test p-values';
	label probf = 'p-value';
	*format probf p63val.; 
	*format probf  pvalue10.4; 
quit;

proc print data=WilcoxonTest label noobs; where name1 = 'PT2_WIL';
	var  _name_ nValue1;
	title 'Wilcoxon p-values';
	label nValue1 = 'p-value';
	*format nValue1 p63val.; 
	*format probf  pvalue10.4; 
quit;
ods rtf close;

*checking out the discrepancy of other race;
ods rtf file="T:\documents\QA\Other Race &sysdate..rtf" style=journal;
proc univariate data=race normal plot;
	class mua_status;
	where _name_ = "OTHRACE_06";
	var percent;
	histogram percent;
	title 'Residual Analysis on Other Race Variable';
	format mua_status mua.;
run;
ods rtf close;

*QA clinic 18084;
proc print data=race noobs;
where percent > 9 and _name_="OTHRACE_06" and mua_status=1;
var clinid percent mua_status ;
run;
proc print data=raw.othstates;
where clinid=18084;
var clinaddres city state openyear closedyear mua_status black_06 white_06 asian_06 amerind_06 pacific_06 othrace_06 hisppop_06;
run;
proc means data=raw.othstates;
where state="PA";
var othrace_06;
run;


*most recent;
Proc freq data=derived.retailclinics_all;
    Tables operator;
    Title ‘Clinic Retailers’;
Run;

*    ;
proc freq data=raw.retailclinicsnew;
    tables operator;
    where state = "OH";
run;
