/* Edit the following line to reflect the full path to your CSV file */
%let csv_file = 'APITest_DATA_NOHDRS_2021-01-27_1018.csv';

OPTIONS nofmterr;

proc format;
	value my_first_instrument_complete_ 0='Incomplete' 1='Unverified' 
		2='Complete';
	value psqi_5a_ 0='Not during the past month' 1='Less than once a week' 
		2='Once or twice a week' 3='Three or more times a week';
	value psqi_5b_ 0='Not during the past month' 1='Less than once a week' 
		2='Once or twice a week' 3='Three or more times a week';
	value psqi_5c_ 0='Not during the past month' 1='Less than once a week' 
		2='Once or twice a week' 3='Three or more times a week';
	value psqi_5d_ 0='Not during the past month' 1='Less than once a week' 
		2='Once or twice a week' 3='Three or more times a week';
	value psqi_5e_ 0='Not during the past month' 1='Less than once a week' 
		2='Once or twice a week' 3='Three or more times a week';
	value psqi_5f_ 0='Not during the past month' 1='Less than once a week' 
		2='Once or twice a week' 3='Three or more times a week';
	value psqi_5g_ 0='Not during the past month' 1='Less than once a week' 
		2='Once or twice a week' 3='Three or more times a week';
	value psqi_5h_ 0='Not during the past month' 1='Less than once a week' 
		2='Once or twice a week' 3='Three or more times a week';
	value psqi_5i_ 0='Not during the past month' 1='Less than once a week' 
		2='Once or twice a week' 3='Three or more times a week';
	value psqi_5othera_ 0='Not during the past month' 1='Less than once a week' 
		2='Once or twice a week' 3='Three or more times a week';
	value psqi_6_ 0='Very good' 1='Fairly good' 
		2='Fairly bad' 3='Very bad';
	value psqi_7_ 0='Not during the past month' 1='Less than once a week' 
		2='Once or twice a week' 3='Three or more times a week';
	value psqi_8_ 0='Not during the past month' 1='Less than once a week' 
		2='Once or twice a week' 3='Three or more times a week';
	value psqi_9_ 0='No problem at all' 1='Only a very slight problem' 
		2='Somewhat of a problem' 3='A very big problem';
	value psqi_10_ 0='No bed partner or room mate' 1='Partner/room mate in other room' 
		2='Partner in same room, but not same bed' 3='Partner in same bed';
	value psqi_10a_ 0='Not during the past month' 1='Less than once a week' 
		2='Once or twice a week' 3='Three or more times a week';
	value psqi_10b_ 0='Not during the past month' 1='Less than once a week' 
		2='Once or twice a week' 3='Three or more times a week';
	value psqi_10c_ 0='Not during the past month' 1='Less than once a week' 
		2='Once or twice a week' 3='Three or more times a week';
	value psqi_10d_ 0='Not during the past month' 1='Less than once a week' 
		2='Once or twice a week' 3='Three or more times a week';
	value psqi_10e1_ 0='Not during the past month' 1='Less than once a week' 
		2='Once or twice a week' 3='Three or more times a week';
	value pittsburgh_sleep_qua_v_0_ 0='Incomplete' 1='Unverified' 
		2='Complete';

	run;

data work.redcap; %let _EFIERR_ = 0;
infile &csv_file  delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=1 ;

	informat record_id $500. ;
	informat my_first_instrument_complete best32. ;
	informat psqi_date yymmdd10. ;
	informat psqi_1 time5. ;
	informat psqi_2 best32. ;
	informat psqi_3 time5. ;
	informat psqi_4 best32. ;
	informat psqi_5a best32. ;
	informat psqi_5b best32. ;
	informat psqi_5c best32. ;
	informat psqi_5d best32. ;
	informat psqi_5e best32. ;
	informat psqi_5f best32. ;
	informat psqi_5g best32. ;
	informat psqi_5h best32. ;
	informat psqi_5i best32. ;
	informat psqi_5other $5000. ;
	informat psqi_5othera best32. ;
	informat psqi_6 best32. ;
	informat psqi_7 best32. ;
	informat psqi_8 best32. ;
	informat psqi_9 best32. ;
	informat psqi_10 best32. ;
	informat psqi_10a best32. ;
	informat psqi_10b best32. ;
	informat psqi_10c best32. ;
	informat psqi_10d best32. ;
	informat psqi_10e $5000. ;
	informat psqi_10e1 best32. ;
	informat pittsburgh_sleep_qua_v_0 best32. ;

	format record_id $500. ;
	format my_first_instrument_complete best12. ;
	format psqi_date yymmdd10. ;
	format psqi_1 time5. ;
	format psqi_2 best12. ;
	format psqi_3 time5. ;
	format psqi_4 best12. ;
	format psqi_5a best12. ;
	format psqi_5b best12. ;
	format psqi_5c best12. ;
	format psqi_5d best12. ;
	format psqi_5e best12. ;
	format psqi_5f best12. ;
	format psqi_5g best12. ;
	format psqi_5h best12. ;
	format psqi_5i best12. ;
	format psqi_5other $5000. ;
	format psqi_5othera best12. ;
	format psqi_6 best12. ;
	format psqi_7 best12. ;
	format psqi_8 best12. ;
	format psqi_9 best12. ;
	format psqi_10 best12. ;
	format psqi_10a best12. ;
	format psqi_10b best12. ;
	format psqi_10c best12. ;
	format psqi_10d best12. ;
	format psqi_10e $5000. ;
	format psqi_10e1 best12. ;
	format pittsburgh_sleep_qua_v_0 best12. ;

input
	record_id $
	my_first_instrument_complete
	psqi_date
	psqi_1
	psqi_2
	psqi_3
	psqi_4
	psqi_5a
	psqi_5b
	psqi_5c
	psqi_5d
	psqi_5e
	psqi_5f
	psqi_5g
	psqi_5h
	psqi_5i
	psqi_5other $
	psqi_5othera
	psqi_6
	psqi_7
	psqi_8
	psqi_9
	psqi_10
	psqi_10a
	psqi_10b
	psqi_10c
	psqi_10d
	psqi_10e $
	psqi_10e1
	pittsburgh_sleep_qua_v_0
;
if _ERROR_ then call symput('_EFIERR_',"1");
run;

proc contents;run;

data redcap;
	set redcap;
	label record_id='Record ID';
	label my_first_instrument_complete='Complete?';
	label psqi_date='Date';
	label psqi_1='1. During the past month, what time have you usually gone to bed at night?';
	label psqi_2='2. During the past month, how long (in minutes) has it usually taken you to fall asleep each night?';
	label psqi_3='3. During the past month, what time have you usually gotten up in the morning?';
	label psqi_4='4. During the past month, how many hours of actual sleep did you get at night? (This may be different than the number of hours you spent in bed.)';
	label psqi_5a='5a) Cannot get to sleep within 30 minutes';
	label psqi_5b='5b) Wake up in the middle of the night or early morning';
	label psqi_5c='5c) Have to get up to use the bathroom';
	label psqi_5d='5d) Cannot breathe comfortably';
	label psqi_5e='5e) Cough or snore loudly';
	label psqi_5f='5f) Feel too cold';
	label psqi_5g='5g) Feel too hot';
	label psqi_5h='5h) Had bad dreams';
	label psqi_5i='5i) Have pain';
	label psqi_5other='5j) Other reason(s), please describe';
	label psqi_5othera='How often during the past month have you had trouble sleeping because of this?';
	label psqi_6='6. During the past month, how would you rate your sleep quality overall?';
	label psqi_7='7. During the past month, how often have you taken medicine to help you sleep (prescribed or over the counter)?';
	label psqi_8='8. During the past month, how often have you had trouble staying awake while driving, eating meals, or engaging in social activity?';
	label psqi_9='9. During the past month, how much of a problem has it been for you to keep up enough enthusiasm to get things done?';
	label psqi_10='10. Do you have a bed partner or room mate?';
	label psqi_10a='10a) Loud snoring';
	label psqi_10b='10b) Long pauses between breaths while asleep';
	label psqi_10c='10c) Legs twitching or jerking while you sleep';
	label psqi_10d='10d) Episodes of disorientation or confusion during sleep';
	label psqi_10e='10e) Other restlessness while you sleep; please describe';
	label psqi_10e1='';
	label pittsburgh_sleep_qua_v_0='Complete?';
	format my_first_instrument_complete my_first_instrument_complete_.;
	format psqi_5a psqi_5a_.;
	format psqi_5b psqi_5b_.;
	format psqi_5c psqi_5c_.;
	format psqi_5d psqi_5d_.;
	format psqi_5e psqi_5e_.;
	format psqi_5f psqi_5f_.;
	format psqi_5g psqi_5g_.;
	format psqi_5h psqi_5h_.;
	format psqi_5i psqi_5i_.;
	format psqi_5othera psqi_5othera_.;
	format psqi_6 psqi_6_.;
	format psqi_7 psqi_7_.;
	format psqi_8 psqi_8_.;
	format psqi_9 psqi_9_.;
	format psqi_10 psqi_10_.;
	format psqi_10a psqi_10a_.;
	format psqi_10b psqi_10b_.;
	format psqi_10c psqi_10c_.;
	format psqi_10d psqi_10d_.;
	format psqi_10e1 psqi_10e1_.;
	format pittsburgh_sleep_qua_v_0 pittsburgh_sleep_qua_v_0_.;
run;

proc contents data=redcap;
proc print data=redcap;
run;