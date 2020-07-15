/*FORMATS*/
options fmtsearch=(raw.iCare4me_formats);
options nofmterr;
proc format;
	value cg_race_
        1 ='Black or African-American'
        2 ='White or Caucasian'
        3 ='Asian'
        4 ='Hispanic or Latino'
        5 ='American Indian or Alaskan Native'
        6 ='Native Hawaiian or other Pacific Islander'
        7 ='Other'
		8 = 'Multi-racial';
run;   

data dsn;
set sample_data;
/*CREATE CAREGIVER RACE*/
race_count = sum(cg_demog_race___1, cg_demog_race___2, cg_demog_race___3, cg_demog_race___4, 
                    cg_demog_race___5, cg_demog_race___6, cg_demog_race___7);
If race_count > 1 then cg_race = 8;
If race_count = 1 then cg_race = 1*cg_demog_race___1 +  2*cg_demog_race___2 +  3*cg_demog_race___3 
                               + 4*cg_demog_race___4 +  5*cg_demog_race___5 +  6*cg_demog_race___6 
                               + 7*cg_demog_race___7;
format cg_race cg_race_.;
run;

/*QA cg_race*/
proc freq data = derived.iCare4me ;
tables race_count * cg_race * cg_demog_race___1 * cg_demog_race___2 * cg_demog_race___3 
* cg_demog_race___4 * cg_demog_race___5 * cg_demog_race___6 * cg_demog_race___7 / list missing;
run;
