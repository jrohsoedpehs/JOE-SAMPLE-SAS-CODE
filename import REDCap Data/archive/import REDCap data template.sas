libname raw "Q:\George Demiris\PISCES\data\Raw";

%macro removeOldFile(bye); %if %sysfunc(exist(&bye.)) %then %do; proc delete data=&bye.; run; %end; %mend removeOldFile;
 
libname redcap 'Q:\George Demiris\PISCES\REDCap Downloads\archive20200213 weekly Report\'; 

%removeOldFile(redcap.redcap); 

data REDCAP; %let _EFIERR_ = 0; 
infile 'Q:\George Demiris\PISCES\REDCap Downloads\archive20200213 weekly Report\PISCES_DATA_NOHDRS_2020-02-13_0918.CSV' delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=1 ; 
	informat caregiver_id $500. ;
	informat redcap_event_name $500. ;
	informat interventionist best32. ;
	informat caregiver_id_complete best32. ;
	informat datetime_seconds $500. ;
	informat date_caregiver_status yymmdd10. ;
	informat group_assignment best32. ;
	informat caregiver_status best32. ;
	informat caregiver_comments best32. ;
	informat caregiver_comments_details $5000. ;
	informat date_of_death yymmdd10. ;
	informat date_of_exit_interview yymmdd10. ;
	informat caregiver_status_complete best32. ;
	informat survey_timestamp $500. ;
	informat pisces_email_trigger $500. ;
	informat demog_date yymmdd10. ;
	informat demog_dob best32. ;
	informat demog_gender best32. ;
	informat demog_ethnic best32. ;
	informat demog_race___0 best32. ;
	informat demog_race___1 best32. ;
	informat demog_race___2 best32. ;
	informat demog_race___3 best32. ;
	informat demog_race___4 best32. ;
	informat demog_race___5 best32. ;
	informat demog_race___6 best32. ;
	informat demog_race___99 best32. ;
	informat demog_race_text $500. ;
	informat demog_marital best32. ;
	informat demog_edu best32. ;
	informat demog_relation best32. ;
	informat demog_relation_text $500. ;
	informat demog_occupation $500. ;
	informat demog_patient_dob best32. ;
	informat demog_patient_hospice yymmdd10. ;
	informat demog_patient_gender best32. ;
	informat demog_patient_ethnic best32. ;
	informat demog_patient_race___0 best32. ;
	informat demog_patient_race___1 best32. ;
	informat demog_patient_race___2 best32. ;
	informat demog_patient_race___3 best32. ;
	informat demog_patient_race___4 best32. ;
	informat demog_patient_race___5 best32. ;
	informat demog_patient_race___6 best32. ;
	informat demog_patient_race___99 best32. ;
	informat demog_patient_race_text $500. ;
	informat demog_patient_marital best32. ;
	informat demog_patient_residence best32. ;
	informat demog_patient_reside_text $500. ;
	informat demog_distance best32. ;
	informat demog_care best32. ;
	informat demog_hours_care best32. ;
	informat demog_add_expense best32. ;
	informat demog_work best32. ;
	informat demog_work_support___0 best32. ;
	informat demog_work_support___1 best32. ;
	informat demog_work_support___2 best32. ;
	informat demog_work_support___3 best32. ;
	informat demog_work_support___4 best32. ;
	informat demog_work_support___99 best32. ;
	informat psi1 best32. ;
	informat psi2 best32. ;
	informat psi3 best32. ;
	informat psi4 best32. ;
	informat psi5 best32. ;
	informat psi6 best32. ;
	informat psi7 best32. ;
	informat psi8 best32. ;
	informat psi9 best32. ;
	informat psi10 best32. ;
	informat psi11 best32. ;
	informat psi12 best32. ;
	informat psi13 best32. ;
	informat psi14 best32. ;
	informat psi15 best32. ;
	informat psi16 best32. ;
	informat psi17 best32. ;
	informat psi18 best32. ;
	informat psi19 best32. ;
	informat psi20 best32. ;
	informat psi21 best32. ;
	informat psi22 best32. ;
	informat psi23 best32. ;
	informat psi24 best32. ;
	informat psi25 best32. ;
	informat psi_negative best32. ;
	informat psi_impulsivity best32. ;
	informat psi_avoidance best32. ;
	informat psi_rational best32. ;
	informat psi_positive best32. ;
	informat phq9_q01 best32. ;
	informat phq9_q02 best32. ;
	informat phq9_q03 best32. ;
	informat phq9_q04 best32. ;
	informat phq9_q05 best32. ;
	informat phq9_q06 best32. ;
	informat phq9_q07 best32. ;
	informat phq9_q08 best32. ;
	informat phq9_q09 best32. ;
	informat phq9_total best32. ;
	informat phq9_q10 best32. ;
	informat gad1 best32. ;
	informat gad2 best32. ;
	informat gad3 best32. ;
	informat gad4 best32. ;
	informat gad5 best32. ;
	informat gad6 best32. ;
	informat gad7 best32. ;
	informat gad_7_total best32. ;
	informat qolemot best32. ;
	informat qolsocial best32. ;
	informat qolfin best32. ;
	informat qolphy best32. ;
	informat qol_total best32. ;
	informat cccq_01 best32. ;
	informat cccq_02 best32. ;
	informat cccq_03 best32. ;
	informat cccq_04 best32. ;
	informat cccq_05 best32. ;
	informat cccq_06 best32. ;
	informat cccq_07 best32. ;
	informat cccq_08 best32. ;
	informat cccq_09 best32. ;
	informat cccq_10 best32. ;
	informat cccq_11 best32. ;
	informat cccq_12 best32. ;
	informat cccq_13 best32. ;
	informat cccq_14 best32. ;
	informat cccq_15 best32. ;
	informat cccq_16 best32. ;
	informat cccq_17 best32. ;
	informat cccq_18 best32. ;
	informat cccq_19 best32. ;
	informat cccq_20 best32. ;
	informat cccq_21 best32. ;
	informat cccq_22 best32. ;
	informat cccq_23 best32. ;
	informat cccq_24 best32. ;
	informat cccq_25 best32. ;
	informat cccq_26 best32. ;
	informat cccq_27 best32. ;
	informat cccq_28 best32. ;
	informat cccq_29 best32. ;
	informat cccq_30 best32. ;
	informat survey_complete best32. ;
	informat problm_clist_family best32. ;
	informat problm_clist_family_r best32. ;
	informat problm_clist_finance best32. ;
	informat problm_clist_finance_r best32. ;
	informat problm_clist_pain best32. ;
	informat problm_clist_pain_r best32. ;
	informat problm_clist_breath best32. ;
	informat problm_clist_breath_r best32. ;
	informat problm_clist_constipate best32. ;
	informat problm_clist_constipate_r best32. ;
	informat problm_clist_communicate best32. ;
	informat problm_clist_communicate_r best32. ;
	informat problm_clist_hcomm best32. ;
	informat problm_clist_hcomm_rank best32. ;
	informat problm_clist_confuse best32. ;
	informat problm_clist_confuse_r best32. ;
	informat problm_clist_grief best32. ;
	informat problm_clist_grief_r best32. ;
	informat problm_clist_anxiety best32. ;
	informat problm_clist_anxiety_r best32. ;
	informat problm_clist_fatigue best32. ;
	informat problm_clist_fatigue_r best32. ;
	informat problm_clist_depress best32. ;
	informat problm_clist_depress_r best32. ;
	informat problm_clist_need best32. ;
	informat problm_clist_need_r best32. ;
	informat problm_clist_final_wks best32. ;
	informat problm_clist_final_wks_r best32. ;
	informat problm_clist_death best32. ;
	informat problm_clist_death_r best32. ;
	informat problm_clist_other best32. ;
	informat problm_clist_other_text $5000. ;
	informat problemconcern_check_v_0 best32. ;
	informat vid_call_occur_yn best32. ;
	informat vid_call_date yymmdd10. ;
	informat vid_call_start_time time5. ;
	informat vid_call_end_time time5. ;
	informat vid_call_type best32. ;
	informat vid_call_occur_text $500. ;
	informat vid_call_missed best32. ;
	informat vid_call_missed_text $500. ;
	informat vid_call_q01_sound_yn best32. ;
	informat vid_call_q01_sound_freq best32. ;
	informat vid_call_q01_pic_yn best32. ;
	informat vid_call_q01_pic_freq best32. ;
	informat vid_call_q01_oth_yn best32. ;
	informat vid_call_q01_oth_text $500. ;
	informat vid_call_q02_sound_yn best32. ;
	informat vid_call_q02_sound_freq best32. ;
	informat vid_call_q02_pic_yn best32. ;
	informat vid_call_q02_pic_freq best32. ;
	informat vid_call_q02_oth_yn best32. ;
	informat vid_call_q02_oth_text $500. ;
	informat vid_call_connect_yn best32. ;
	informat vid_call_connect_text $500. ;
	informat vid_call_converse_yn best32. ;
	informat vid_call_ask_yn best32. ;
	informat vid_call_ask_text $500. ;
	informat vid_call_mood_yn best32. ;
	informat vid_call_quality best32. ;
	informat vid_call_useful best32. ;
	informat vid_call_notes $5000. ;
	informat technical_quality_complete best32. ;
	informat pisces_email_trigger_timestamp $500. ;
	informat phq9_gad7_follow_up best32. ;
	informat phq9_gad7_follow_up_v3 best32. ;
	informat pisces_email_trigger_complete best32. ;
	informat complete_et best32. ;
	informat date_term_et yymmdd10. ;
	informat reason_et best32. ;
	informat withdrawal_by_pi_reason___1 best32. ;
	informat withdrawal_by_pi_reason___2 best32. ;
	informat withdrawal_by_pi_reason___3 best32. ;
	informat updated_et best32. ;
	informat notes_et $5000. ;
	informat date_entry_et yymmdd10. ;
	informat lab_et best32. ;
	informat new_ae_et best32. ;
	informat change_et best32. ;
	informat ongoing_et best32. ;
	informat early_termination_fo_v_1 best32. ;

	format caregiver_id $500. ;
	format redcap_event_name $500. ;
	format interventionist best12. ;
	format caregiver_id_complete best12. ;
	format datetime_seconds $500. ;
	format date_caregiver_status yymmdd10. ;
	format group_assignment best12. ;
	format caregiver_status best12. ;
	format caregiver_comments best12. ;
	format caregiver_comments_details $5000. ;
	format date_of_death yymmdd10. ;
	format date_of_exit_interview yymmdd10. ;
	format caregiver_status_complete best12. ;
	format survey_timestamp $500. ;
	format pisces_email_trigger $500. ;
	format demog_date yymmdd10. ;
	format demog_dob best12. ;
	format demog_gender best12. ;
	format demog_ethnic best12. ;
	format demog_race___0 best12. ;
	format demog_race___1 best12. ;
	format demog_race___2 best12. ;
	format demog_race___3 best12. ;
	format demog_race___4 best12. ;
	format demog_race___5 best12. ;
	format demog_race___6 best12. ;
	format demog_race___99 best12. ;
	format demog_race_text $500. ;
	format demog_marital best12. ;
	format demog_edu best12. ;
	format demog_relation best12. ;
	format demog_relation_text $500. ;
	format demog_occupation $500. ;
	format demog_patient_dob best12. ;
	format demog_patient_hospice yymmdd10. ;
	format demog_patient_gender best12. ;
	format demog_patient_ethnic best12. ;
	format demog_patient_race___0 best12. ;
	format demog_patient_race___1 best12. ;
	format demog_patient_race___2 best12. ;
	format demog_patient_race___3 best12. ;
	format demog_patient_race___4 best12. ;
	format demog_patient_race___5 best12. ;
	format demog_patient_race___6 best12. ;
	format demog_patient_race___99 best12. ;
	format demog_patient_race_text $500. ;
	format demog_patient_marital best12. ;
	format demog_patient_residence best12. ;
	format demog_patient_reside_text $500. ;
	format demog_distance best12. ;
	format demog_care best12. ;
	format demog_hours_care best12. ;
	format demog_add_expense best12. ;
	format demog_work best12. ;
	format demog_work_support___0 best12. ;
	format demog_work_support___1 best12. ;
	format demog_work_support___2 best12. ;
	format demog_work_support___3 best12. ;
	format demog_work_support___4 best12. ;
	format demog_work_support___99 best12. ;
	format psi1 best12. ;
	format psi2 best12. ;
	format psi3 best12. ;
	format psi4 best12. ;
	format psi5 best12. ;
	format psi6 best12. ;
	format psi7 best12. ;
	format psi8 best12. ;
	format psi9 best12. ;
	format psi10 best12. ;
	format psi11 best12. ;
	format psi12 best12. ;
	format psi13 best12. ;
	format psi14 best12. ;
	format psi15 best12. ;
	format psi16 best12. ;
	format psi17 best12. ;
	format psi18 best12. ;
	format psi19 best12. ;
	format psi20 best12. ;
	format psi21 best12. ;
	format psi22 best12. ;
	format psi23 best12. ;
	format psi24 best12. ;
	format psi25 best12. ;
	format psi_negative best12. ;
	format psi_impulsivity best12. ;
	format psi_avoidance best12. ;
	format psi_rational best12. ;
	format psi_positive best12. ;
	format phq9_q01 best12. ;
	format phq9_q02 best12. ;
	format phq9_q03 best12. ;
	format phq9_q04 best12. ;
	format phq9_q05 best12. ;
	format phq9_q06 best12. ;
	format phq9_q07 best12. ;
	format phq9_q08 best12. ;
	format phq9_q09 best12. ;
	format phq9_total best12. ;
	format phq9_q10 best12. ;
	format gad1 best12. ;
	format gad2 best12. ;
	format gad3 best12. ;
	format gad4 best12. ;
	format gad5 best12. ;
	format gad6 best12. ;
	format gad7 best12. ;
	format gad_7_total best12. ;
	format qolemot best12. ;
	format qolsocial best12. ;
	format qolfin best12. ;
	format qolphy best12. ;
	format qol_total best12. ;
	format cccq_01 best12. ;
	format cccq_02 best12. ;
	format cccq_03 best12. ;
	format cccq_04 best12. ;
	format cccq_05 best12. ;
	format cccq_06 best12. ;
	format cccq_07 best12. ;
	format cccq_08 best12. ;
	format cccq_09 best12. ;
	format cccq_10 best12. ;
	format cccq_11 best12. ;
	format cccq_12 best12. ;
	format cccq_13 best12. ;
	format cccq_14 best12. ;
	format cccq_15 best12. ;
	format cccq_16 best12. ;
	format cccq_17 best12. ;
	format cccq_18 best12. ;
	format cccq_19 best12. ;
	format cccq_20 best12. ;
	format cccq_21 best12. ;
	format cccq_22 best12. ;
	format cccq_23 best12. ;
	format cccq_24 best12. ;
	format cccq_25 best12. ;
	format cccq_26 best12. ;
	format cccq_27 best12. ;
	format cccq_28 best12. ;
	format cccq_29 best12. ;
	format cccq_30 best12. ;
	format survey_complete best12. ;
	format problm_clist_family best12. ;
	format problm_clist_family_r best12. ;
	format problm_clist_finance best12. ;
	format problm_clist_finance_r best12. ;
	format problm_clist_pain best12. ;
	format problm_clist_pain_r best12. ;
	format problm_clist_breath best12. ;
	format problm_clist_breath_r best12. ;
	format problm_clist_constipate best12. ;
	format problm_clist_constipate_r best12. ;
	format problm_clist_communicate best12. ;
	format problm_clist_communicate_r best12. ;
	format problm_clist_hcomm best12. ;
	format problm_clist_hcomm_rank best12. ;
	format problm_clist_confuse best12. ;
	format problm_clist_confuse_r best12. ;
	format problm_clist_grief best12. ;
	format problm_clist_grief_r best12. ;
	format problm_clist_anxiety best12. ;
	format problm_clist_anxiety_r best12. ;
	format problm_clist_fatigue best12. ;
	format problm_clist_fatigue_r best12. ;
	format problm_clist_depress best12. ;
	format problm_clist_depress_r best12. ;
	format problm_clist_need best12. ;
	format problm_clist_need_r best12. ;
	format problm_clist_final_wks best12. ;
	format problm_clist_final_wks_r best12. ;
	format problm_clist_death best12. ;
	format problm_clist_death_r best12. ;
	format problm_clist_other best12. ;
	format problm_clist_other_text $5000. ;
	format problemconcern_check_v_0 best12. ;
	format vid_call_occur_yn best12. ;
	format vid_call_date yymmdd10. ;
	format vid_call_start_time time5. ;
	format vid_call_end_time time5. ;
	format vid_call_type best12. ;
	format vid_call_occur_text $500. ;
	format vid_call_missed best12. ;
	format vid_call_missed_text $500. ;
	format vid_call_q01_sound_yn best12. ;
	format vid_call_q01_sound_freq best12. ;
	format vid_call_q01_pic_yn best12. ;
	format vid_call_q01_pic_freq best12. ;
	format vid_call_q01_oth_yn best12. ;
	format vid_call_q01_oth_text $500. ;
	format vid_call_q02_sound_yn best12. ;
	format vid_call_q02_sound_freq best12. ;
	format vid_call_q02_pic_yn best12. ;
	format vid_call_q02_pic_freq best12. ;
	format vid_call_q02_oth_yn best12. ;
	format vid_call_q02_oth_text $500. ;
	format vid_call_connect_yn best12. ;
	format vid_call_connect_text $500. ;
	format vid_call_converse_yn best12. ;
	format vid_call_ask_yn best12. ;
	format vid_call_ask_text $500. ;
	format vid_call_mood_yn best12. ;
	format vid_call_quality best12. ;
	format vid_call_useful best12. ;
	format vid_call_notes $5000. ;
	format technical_quality_complete best12. ;
	format pisces_email_trigger_timestamp $500. ;
	format phq9_gad7_follow_up best12. ;
	format phq9_gad7_follow_up_v3 best12. ;
	format pisces_email_trigger_complete best12. ;
	format complete_et best12. ;
	format date_term_et yymmdd10. ;
	format reason_et best12. ;
	format withdrawal_by_pi_reason___1 best12. ;
	format withdrawal_by_pi_reason___2 best12. ;
	format withdrawal_by_pi_reason___3 best12. ;
	format updated_et best12. ;
	format notes_et $5000. ;
	format date_entry_et yymmdd10. ;
	format lab_et best12. ;
	format new_ae_et best12. ;
	format change_et best12. ;
	format ongoing_et best12. ;
	format early_termination_fo_v_1 best12. ;

input
		caregiver_id $
		redcap_event_name $
		interventionist
		caregiver_id_complete
		datetime_seconds $
		date_caregiver_status
		group_assignment
		caregiver_status
		caregiver_comments
		caregiver_comments_details $
		date_of_death
		date_of_exit_interview
		caregiver_status_complete
		survey_timestamp $
		pisces_email_trigger $
		demog_date
		demog_dob
		demog_gender
		demog_ethnic
		demog_race___0
		demog_race___1
		demog_race___2
		demog_race___3
		demog_race___4
		demog_race___5
		demog_race___6
		demog_race___99
		demog_race_text $
		demog_marital
		demog_edu
		demog_relation
		demog_relation_text $
		demog_occupation $
		demog_patient_dob
		demog_patient_hospice
		demog_patient_gender
		demog_patient_ethnic
		demog_patient_race___0
		demog_patient_race___1
		demog_patient_race___2
		demog_patient_race___3
		demog_patient_race___4
		demog_patient_race___5
		demog_patient_race___6
		demog_patient_race___99
		demog_patient_race_text $
		demog_patient_marital
		demog_patient_residence
		demog_patient_reside_text $
		demog_distance
		demog_care
		demog_hours_care
		demog_add_expense
		demog_work
		demog_work_support___0
		demog_work_support___1
		demog_work_support___2
		demog_work_support___3
		demog_work_support___4
		demog_work_support___99
		psi1
		psi2
		psi3
		psi4
		psi5
		psi6
		psi7
		psi8
		psi9
		psi10
		psi11
		psi12
		psi13
		psi14
		psi15
		psi16
		psi17
		psi18
		psi19
		psi20
		psi21
		psi22
		psi23
		psi24
		psi25
		psi_negative
		psi_impulsivity
		psi_avoidance
		psi_rational
		psi_positive
		phq9_q01
		phq9_q02
		phq9_q03
		phq9_q04
		phq9_q05
		phq9_q06
		phq9_q07
		phq9_q08
		phq9_q09
		phq9_total
		phq9_q10
		gad1
		gad2
		gad3
		gad4
		gad5
		gad6
		gad7
		gad_7_total
		qolemot
		qolsocial
		qolfin
		qolphy
		qol_total
		cccq_01
		cccq_02
		cccq_03
		cccq_04
		cccq_05
		cccq_06
		cccq_07
		cccq_08
		cccq_09
		cccq_10
		cccq_11
		cccq_12
		cccq_13
		cccq_14
		cccq_15
		cccq_16
		cccq_17
		cccq_18
		cccq_19
		cccq_20
		cccq_21
		cccq_22
		cccq_23
		cccq_24
		cccq_25
		cccq_26
		cccq_27
		cccq_28
		cccq_29
		cccq_30
		survey_complete
		problm_clist_family
		problm_clist_family_r
		problm_clist_finance
		problm_clist_finance_r
		problm_clist_pain
		problm_clist_pain_r
		problm_clist_breath
		problm_clist_breath_r
		problm_clist_constipate
		problm_clist_constipate_r
		problm_clist_communicate
		problm_clist_communicate_r
		problm_clist_hcomm
		problm_clist_hcomm_rank
		problm_clist_confuse
		problm_clist_confuse_r
		problm_clist_grief
		problm_clist_grief_r
		problm_clist_anxiety
		problm_clist_anxiety_r
		problm_clist_fatigue
		problm_clist_fatigue_r
		problm_clist_depress
		problm_clist_depress_r
		problm_clist_need
		problm_clist_need_r
		problm_clist_final_wks
		problm_clist_final_wks_r
		problm_clist_death
		problm_clist_death_r
		problm_clist_other
		problm_clist_other_text $
		problemconcern_check_v_0
		vid_call_occur_yn
		vid_call_date
		vid_call_start_time
		vid_call_end_time
		vid_call_type
		vid_call_occur_text $
		vid_call_missed
		vid_call_missed_text $
		vid_call_q01_sound_yn
		vid_call_q01_sound_freq
		vid_call_q01_pic_yn
		vid_call_q01_pic_freq
		vid_call_q01_oth_yn
		vid_call_q01_oth_text $
		vid_call_q02_sound_yn
		vid_call_q02_sound_freq
		vid_call_q02_pic_yn
		vid_call_q02_pic_freq
		vid_call_q02_oth_yn
		vid_call_q02_oth_text $
		vid_call_connect_yn
		vid_call_connect_text $
		vid_call_converse_yn
		vid_call_ask_yn
		vid_call_ask_text $
		vid_call_mood_yn
		vid_call_quality
		vid_call_useful
		vid_call_notes $
		technical_quality_complete
		pisces_email_trigger_timestamp $
		phq9_gad7_follow_up
		phq9_gad7_follow_up_v3
		pisces_email_trigger_complete
		complete_et
		date_term_et
		reason_et
		withdrawal_by_pi_reason___1
		withdrawal_by_pi_reason___2
		withdrawal_by_pi_reason___3
		updated_et
		notes_et $
		date_entry_et
		lab_et
		new_ae_et
		change_et
		ongoing_et
		early_termination_fo_v_1
;
if _ERROR_ then call symput('_EFIERR_',"1");
run;

proc contents;run;


data redcap;
	set redcap;
	label caregiver_id='Caregiver ID';
	label redcap_event_name='Event Name';
	label interventionist=' Interventionist ';
	label caregiver_id_complete='Complete?';
	label datetime_seconds='This field is used for branching logic and  allows PSI to appear in consent only and CCCQ to appear in session 3 only.';
	label date_caregiver_status='Date';
	label group_assignment='Group Assignment';
	label caregiver_status='Caregiver Status';
	label caregiver_comments='Caregiver Comments';
	label caregiver_comments_details='Comments';
	label date_of_death='Date of Death (If Available)';
	label date_of_exit_interview='Date of exit interview (If Applicable)';
	label caregiver_status_complete='Complete?';
	label survey_timestamp='Survey Timestamp';
	label pisces_email_trigger='PISCES Email Trigger';
	label demog_date='Date';
	label demog_dob='Year of Birth';
	label demog_gender='Gender';
	label demog_ethnic='Ethnicity ';
	label demog_race___0='Race (choice=American Indian or Alaska Native)';
	label demog_race___1='Race (choice=Black/African American)';
	label demog_race___2='Race (choice=White/Caucasian)';
	label demog_race___3='Race (choice=Asian American)';
	label demog_race___4='Race (choice=Native Hawaiian or Other Pacific Islander)';
	label demog_race___5='Race (choice=Multi-Racial)';
	label demog_race___6='Race (choice=Other)';
	label demog_race___99='Race (choice=Decline to answer)';
	label demog_race_text='Please Specify';
	label demog_marital='Marital Status';
	label demog_edu='Education Level';
	label demog_relation='Relationship to Patient';
	label demog_relation_text='Please Specify';
	label demog_occupation='Caregiver Occupation';
	label demog_patient_dob='Year of Birth';
	label demog_patient_hospice='Date of Hospice Admission';
	label demog_patient_gender='Gender';
	label demog_patient_ethnic='Ethnicity';
	label demog_patient_race___0='Race (choice=American Indian or Alaska Native)';
	label demog_patient_race___1='Race (choice=Black/African American)';
	label demog_patient_race___2='Race (choice=White/Caucasian)';
	label demog_patient_race___3='Race (choice=Asian American)';
	label demog_patient_race___4='Race (choice=Native Hawaiian or Other Pacific Islander)';
	label demog_patient_race___5='Race (choice=Multi-Racial)';
	label demog_patient_race___6='Race (choice=Other)';
	label demog_patient_race___99='Race (choice=Decline to answer)';
	label demog_patient_race_text='Please Specify';
	label demog_patient_marital='Marital Status';
	label demog_patient_residence='Residence';
	label demog_patient_reside_text='Please Specify';
	label demog_distance='Does your [patient] live with you, less than one hour away by car, or more than one hour away by car?';
	label demog_care='For how long have you been giving care to your [patient]?';
	label demog_hours_care='In average, how many hours per week do you spend taking care of your [patient]?';
	label demog_add_expense='In the past 12 months, have you had any out-of-pocket expenses for the services or material related to taking care of [patient]?';
	label demog_work='Do you currently work?';
	label demog_work_support___0='As a result of providing care to your [patient], have you made any of the following work-related changes?  (choice=Cut back on your work hours or quit work entirely)';
	label demog_work_support___1='As a result of providing care to your [patient], have you made any of the following work-related changes?  (choice=Taken an unpaid leave or any leave under the Family Medical Leave Act?)';
	label demog_work_support___2='As a result of providing care to your [patient], have you made any of the following work-related changes?  (choice=Left one job for a different one)';
	label demog_work_support___3='As a result of providing care to your [patient], have you made any of the following work-related changes?  (choice=Used your own sick leave or vacation time)';
	label demog_work_support___4='As a result of providing care to your [patient], have you made any of the following work-related changes?  (choice=Taken a job or worked additional hours to earn more money)';
	label demog_work_support___99='As a result of providing care to your [patient], have you made any of the following work-related changes?  (choice=Decline to answer)';
	label psi1='1. I feel afraid when I have an important problem to solve';
	label psi2='2. When making decisions, I think carefully about my many options';
	label psi3='3. I get nervous and unsure of myself when I have to make an important decision';
	label psi4='4. When my first efforts to solve a problem fail, I give up quickly, because finding a solution is too difficult';
	label psi5='5. Sometimes even difficult problems can have a way of moving my life forward in positive ways';
	label psi6='6. If I avoid problems, they will generally take care of themselves';
	label psi7='7. When I am unsuccessful at solving a problem, I get very frustrated';
	label psi8='8. If I work at it, I can learn to solve difficult problems effectively';
	label psi9='9. When faced with a problem, before deciding what to do, I carefully try to understand why it is a problem by sorting it out, breaking it down, and defining it';
	label psi10='10. I try to do anything I can in order to avoid problems in my life';
	label psi11='11. Difficult problems make me very emotional';
	label psi12='12. When I have a decision to make, I take the time to try and predict the positive and negative consequences of each possible option before I act';
	label psi13='13. When I am trying to solve a problem, I often rely on instinct with the first good idea that comes to mind';
	label psi14='14. When I am upset, I just want to run away and be left alone';
	label psi15='15. I can make important decisions on my own';
	label psi16='16. I frequently react before I have all the facts about a problem';
	label psi17='17. After coming up with an idea of how to solve a problem, I work out a plan to carry it out successfully';
	label psi18='18. I am very creative about coming up with ideas when solving problems';
	label psi19='19. I spend more time worrying about problems than actually solving them';
	label psi20='20. My goal for solving problems is to stop negative feelings as quickly as I can';
	label psi21='21. I try to avoid any trouble with others in order to keep problems to a minimum';
	label psi22='22. When someone upsets me or hurts my feelings, I always react the same way';
	label psi23='23. When I am trying to figure out a problem, it helps me to stick to the facts of the situation';
	label psi24='24. In my opinion, being systematic and planful with personal problems seems too cold';
	label psi25='25. I understand that emotions, even bad ones, can actually be helpful to my efforts at problem solving';
	label psi_negative='PSI negative attitude';
	label psi_impulsivity='PSI impulsivity/carelessness';
	label psi_avoidance='PSI avoidance';
	label psi_rational='PSI rational problem-solving skills';
	label psi_positive='PSI positive attitude';
	label phq9_q01='1. Little interest or pleasure in doing things';
	label phq9_q02='2. Feeling down, depressed, or hopeless';
	label phq9_q03='3. Trouble falling asleep, staying asleep, or  sleeping too much';
	label phq9_q04='4. Feeling tired or having little energy';
	label phq9_q05='5. Poor appetite or overeating';
	label phq9_q06='6. Feeling bad about yourself, or that you are a failure, or have let yourself or your family down';
	label phq9_q07='7. Trouble concentrating on things, such as reading the newspaper or watching television';
	label phq9_q08='8. Moving or speaking so slowly that other people could have noticed. Or, the opposite - being so fidgety or restless that you have been moving around a lot more than usual';
	label phq9_q09='9. Thoughts that you would be better off dead or of hurting yourself in some way';
	label phq9_total='PHQ9 Total';
	label phq9_q10='10. If you checked off any problems, how difficult have those problems been for you to do your work, take care of things at home, or get along with other people?';
	label gad1='1.  Feeling nervous, anxious, or on edge ?';
	label gad2='2.  Not being able to stop or control worrying ?';
	label gad3='3.  Worrying too much about different things ?';
	label gad4='4.  Trouble relaxing ?';
	label gad5='5.  Being so restless that it''s hard to sit still ?';
	label gad6='6.  Becoming easily annoyed or irritable ?';
	label gad7='7.  Feeling afraid as if something awful might happen ?';
	label gad_7_total='GAD 7 Total';
	label qolemot='Emotional Quality of Life 1. Lowest quality applies to someone who is depressed, anxious, insecure, alienated, and lonely. Highest quality applies to someone who is emotionally comfortable with self, others, and environment.';
	label qolsocial='Social Quality of Life2. Lowest quality of life applies to someone whose social relationships are unsatisfactory, of poor quality, or few; help from family and friends is not even available occasionally. Highest quality applies to someone whose social relationships are very satisfactory and extensive; at least one person would assist him or her indefinitely.';
	label qolfin='Financial Quality of Life3. Lowest quality describes someone who constantly is worried about medical costs and present and future living expenses. Highest quality describes someone who feels confident of his or her financial status now and in the future.';
	label qolphy='Physical Quality of Life4. Lowest quality describes someone who has no energy or is physically ill and feels unable to maintain normal activities. Highest quality describes someone who is energetic, in good physical health, and is maintaining normal activity levels.';
	label qol_total='CQLI-R Total';
	label cccq_01='1. My hospice team tries to explore my beliefs, needs and preferences as a caregiver.';
	label cccq_02='2. My hospice team shares sources of medical information.';
	label cccq_03='3. My hospice team helps me use and understand medical information.';
	label cccq_04='4. I feel comfortable sharing information with my hospice team.';
	label cccq_05='5. My hospice team knows how to deliver news whether good or bad.';
	label cccq_06='6. My hospice team is honest and open in disclosing information.';
	label cccq_07='7. I trust my hospice team''s skills and knowledge.';
	label cccq_08='8. My hospice team shows that they are committed to my loved one''s care.';
	label cccq_09='9. My hospice team cares about me.';
	label cccq_10='10. I feel that I have a connection with my hospice team.';
	label cccq_11='11. My hospice team helps me understand my loved one''s illness.';
	label cccq_12='12. My hospice team lets me be actively involved in my loved one''s care if I want to.';
	label cccq_13='13. My hospice team helps me deal emotionally with the uncertainty of my loved one''s illness.';
	label cccq_14='14. My hospice team helps me manage and solve problems that I face as a caregiver.';
	label cccq_15='15. My hospice team tries to determine whether I am anxious, depressed or stressed.';
	label cccq_16='16. My hospice team makes me feel that it is ok to feel the way I do.';
	label cccq_17='17. My hospice team reassures me and sympathizes with me.';
	label cccq_18='18. My hospice team helps me deal with my emotions.';
	label cccq_19='19. My hospice team supports me when making decisions about my loved one''s care.';
	label cccq_20='20. My hospice team helps me make choices and carry out a plan.';
	label cccq_21='21. My hospice team helps me evaluate my decisions.';
	label cccq_22='22. My hospice team discusses my choices with me.';
	label cccq_23='23. My hospice team helps me set my priorities.';
	label cccq_24='24. My hospice team helps me navigate the complex healthcare system.';
	label cccq_25='25. My hospice team helps me arrange the next step in my loved one''s care.';
	label cccq_26='26. My hospice team discusses with me when and where we will talk next.';
	label cccq_27='27. My hospice team discusses with me the roles of the team.';
	label cccq_28='28. I feel like I am building a partnership with my hospice team.';
	label cccq_29='29. My hospice team respects my background and culture.';
	label cccq_30='30. My hospice team discusses different possible options for care.';
	label survey_complete='Complete?';
	label problm_clist_family='Family concerns';
	label problm_clist_family_r='Ranking of Family Concerns';
	label problm_clist_finance='Financial concerns';
	label problm_clist_finance_r='Ranking of Financial concerns';
	label problm_clist_pain='Concern about Pain';
	label problm_clist_pain_r='Ranking of concern about Pain';
	label problm_clist_breath='Concern about Shortness of Breath';
	label problm_clist_breath_r='Ranking of Concern about Shortness of Breath';
	label problm_clist_constipate='Concern about Constipation';
	label problm_clist_constipate_r='Ranking of concern about Constipation';
	label problm_clist_communicate='Communication with Patient';
	label problm_clist_communicate_r='Ranking of communication with Patient';
	label problm_clist_hcomm='Communication with Health Care Providers';
	label problm_clist_hcomm_rank='Ranking of communication with Health Care Providers';
	label problm_clist_confuse='Concern about Mental Confusion';
	label problm_clist_confuse_r='Ranking of concern about Mental Confusion';
	label problm_clist_grief='Grief';
	label problm_clist_grief_r='Ranking of grief';
	label problm_clist_anxiety='Anxiety';
	label problm_clist_anxiety_r='Ranking of anxiety';
	label problm_clist_fatigue='Fatigue';
	label problm_clist_fatigue_r='Ranking of fatigue';
	label problm_clist_depress='Depression';
	label problm_clist_depress_r='Ranking of depression';
	label problm_clist_need='Need for Respite Care or extra help';
	label problm_clist_need_r='Ranking of need for Respite Care or extra help';
	label problm_clist_final_wks='Help during Final Weeks';
	label problm_clist_final_wks_r='Ranking of help during Final Weeks';
	label problm_clist_death='Concern about what to do before and after Death';
	label problm_clist_death_r='Ranking of concern about what to do before and after Death';
	label problm_clist_other='Other concerns or problems you or your loved one are currently experiencing or worrying about? ';
	label problm_clist_other_text='Please specify:';
	label problemconcern_check_v_0='Complete?';
	label vid_call_occur_yn='Did the video call take place?';
	label vid_call_date='Date';
	label vid_call_start_time='Start time:';
	label vid_call_end_time='End time ';
	label vid_call_type='Type of Call ';
	label vid_call_occur_text='Please specify';
	label vid_call_missed='If the video call did not take place, please indicate the reason:  ';
	label vid_call_missed_text='please indicate:';
	label vid_call_q01_sound_yn='Sound?';
	label vid_call_q01_sound_freq='Please check one of the following in regard to the frequency of the experienced difficulty';
	label vid_call_q01_pic_yn='Picture?';
	label vid_call_q01_pic_freq='Please check one of the following in regard to the frequency of the experienced difficulty';
	label vid_call_q01_oth_yn='Other?';
	label vid_call_q01_oth_text='Please specify';
	label vid_call_q02_sound_yn='Sound?';
	label vid_call_q02_sound_freq='Please check one of the following in regard to the frequency of the experienced difficulty';
	label vid_call_q02_pic_yn='Picture?';
	label vid_call_q02_pic_freq='Please check one of the following in regard to the frequency of the experienced difficulty';
	label vid_call_q02_oth_yn='Other?';
	label vid_call_q02_oth_text='Please specify';
	label vid_call_connect_yn='3) Did you lose the connection anytime during the visit? ';
	label vid_call_connect_text='How often';
	label vid_call_converse_yn='4) Would the conversation have been significantly better if it had been performed in person?';
	label vid_call_ask_yn='5) Were there questions that you didn''t ask today because of the video that you would have asked in person?';
	label vid_call_ask_text='Please specify';
	label vid_call_mood_yn='6) Did the caregiver seem worried, concerned or generally in a bad mood today at the beginning of the video call?';
	label vid_call_quality='7) Overall, how would you rate the technical quality of today''s video call?';
	label vid_call_useful='8) Overall, how useful would you rate today''s video call for delivering the problem-solving intervention? ';
	label vid_call_notes='Please record any other thoughts or observations:';
	label technical_quality_complete='Complete?';
	label pisces_email_trigger_timestamp='Survey Timestamp';
	label phq9_gad7_follow_up='Participant with PHQ-9 higher than 20 or GAD-7 higher than 15 received a follow-up.  Caregiver [caregiver_id] has a PHQ-9 Score of [consent_visit_arm_1][phq9_total] at the Consent Visit GAD7 score of [consent_visit_arm_1][gad_7_total]   at the Consent Visit';
	label phq9_gad7_follow_up_v3='Participant with PHQ-9 higher than 20 or GAD-7 higher than 15 received a follow-up.  Caregiver [caregiver_id] has a PHQ-9 Score of [session_3_arm_1][phq9_total] at the Consent Visit GAD7 score of [session_3_arm_1][gad_7_total]  at the Consent Visit';
	label pisces_email_trigger_complete='Complete?';
	label complete_et='Did the subject complete the study?  ';
	label date_term_et='Date of completion/termination from study';
	label reason_et='Study Exit Reason';
	label withdrawal_by_pi_reason___1='Early Withdrawal by PI Reason (choice=Adverse Event or Serious Adverse Event)';
	label withdrawal_by_pi_reason___2='Early Withdrawal by PI Reason (choice=Subject Safety concern)';
	label withdrawal_by_pi_reason___3='Early Withdrawal by PI Reason (choice=Noncompliance with Protocol)';
	label updated_et='Was Redcap database updated with the visit information?';
	label notes_et='Notes';
	label date_entry_et='Date of Entry';
	label lab_et='Lab results from the previous visit reviewed by the Investigator and lab AE''s noted, if applicable.   ';
	label new_ae_et='Any NEW adverse events since last visit?';
	label change_et='Any CHANGES to ONGOING adverse events since last visit?';
	label ongoing_et='Previous ONGOING or NEW AEs to be followed.';
	label early_termination_fo_v_1='Complete?';
	run;

proc format;
	value $redcap_event_name_ reportable_events_arm_1='Reportable Events' consent_visit_arm_1='Consent Visit' 
		session_1_arm_1='Session 1' session_2_arm_1='Session 2' 
		session_3_arm_1='Session 3' exit_interview_arm_1='Exit Interview';
	value interventionist_ 1='Rachael' 2='Cathryn';
	value caregiver_id_complete_ 0='Incomplete' 1='Unverified' 
		2='Complete';
	value group_assignment_ 1='Group 1' 2='Group 2' 
		3='Group 3';
	value caregiver_status_ 1='Active Caregiver' 0='Bereaved';
	value caregiver_comments_ 1='Yes' 0='No';
	value caregiver_status_complete_ 0='Incomplete' 1='Unverified' 
		2='Complete';
	value demog_gender_ 0='Male' 1='Female' 
		99='Decline to answer';
	value demog_ethnic_ 0='Hispanic' 1='Non-Hispanic' 
		99='Decline to answer';
	value demog_race___0_ 0='Unchecked' 1='Checked';
	value demog_race___1_ 0='Unchecked' 1='Checked';
	value demog_race___2_ 0='Unchecked' 1='Checked';
	value demog_race___3_ 0='Unchecked' 1='Checked';
	value demog_race___4_ 0='Unchecked' 1='Checked';
	value demog_race___5_ 0='Unchecked' 1='Checked';
	value demog_race___6_ 0='Unchecked' 1='Checked';
	value demog_race___99_ 0='Unchecked' 1='Checked';
	value demog_marital_ 0='Single, Never Married/Partnered' 1='Married/Partnered' 
		2='Widowed' 3='Separated' 
		4='Divorced' 99='Decline to answer';
	value demog_edu_ 0='Less than High School' 1='High School/GED' 
		2='Some College' 3='Associates Degree' 
		4='Bachelors Degree' 5='Masters Degree' 
		6='Professional Degree (MD, JD)' 7='Doctorial Degree (PhD)' 
		99='Decline to answer';
	value demog_relation_ 0='Spouse/Partner' 1='Adult Child' 
		2='Grandchild' 3='Parent' 
		4='Sibling' 5='Friend' 
		6='Other' 99='Decline to answer';
	value demog_patient_gender_ 0='Male' 1='Female' 
		2='Decline to answer';
	value demog_patient_ethnic_ 0='Hispanic' 1='Non-Hispanic' 
		2='Decline to answer';
	value demog_patient_race___0_ 0='Unchecked' 1='Checked';
	value demog_patient_race___1_ 0='Unchecked' 1='Checked';
	value demog_patient_race___2_ 0='Unchecked' 1='Checked';
	value demog_patient_race___3_ 0='Unchecked' 1='Checked';
	value demog_patient_race___4_ 0='Unchecked' 1='Checked';
	value demog_patient_race___5_ 0='Unchecked' 1='Checked';
	value demog_patient_race___6_ 0='Unchecked' 1='Checked';
	value demog_patient_race___99_ 0='Unchecked' 1='Checked';
	value demog_patient_marital_ 0='Single, Never Married/ Partnered' 1='Married/Partnered' 
		2='Widowed' 3='Seperated' 
		4='Divorced' 99='Decline to answer';
	value demog_patient_residence_ 0='Private Residence' 1='Adult Family House/Group Home' 
		2='Assisted Living Facility' 3='Nursing Home/Skilled Nursing Facility' 
		4='Other' 99='Decline to answer';
	value demog_distance_ 0='With you' 1='Less than one hour away' 
		2='More than one hour away' 99='Decline to answer';
	value demog_care_ 0='Less than 1 month' 1='2-6 months' 
		2='6 months to less than a year' 3='1 year to less than 2 years' 
		4='2 years to less than 3 years' 5='3 years or more' 
		99='Decline to answer';
	value demog_hours_care_ 0='Less than 5 hours a week' 1='5-10 hours a week' 
		2='11-20 hours a week' 3='More than 20 hours a week' 
		99='Decline to answer';
	value demog_add_expense_ 0='Yes' 1='No' 
		99='Decline to answer';
	value demog_work_ 1='Yes' 0='No' 
		99='Decline to answer';
	value demog_work_support___0_ 0='Unchecked' 1='Checked';
	value demog_work_support___1_ 0='Unchecked' 1='Checked';
	value demog_work_support___2_ 0='Unchecked' 1='Checked';
	value demog_work_support___3_ 0='Unchecked' 1='Checked';
	value demog_work_support___4_ 0='Unchecked' 1='Checked';
	value demog_work_support___99_ 0='Unchecked' 1='Checked';
	value psi1_ 1='Notat all true of me1' 2='Somewhattrue of me2' 
		3='Moderately true of me3' 4='True of me  4' 
		5='Very true of me5';
	value psi2_ 1='Notat all true of me1' 2='Somewhattrue of me2' 
		3='Moderately true of me3' 4='True of me  4' 
		5='Very true of me5';
	value psi3_ 1='Notat all true of me1' 2='Somewhattrue of me2' 
		3='Moderately true of me3' 4='True of me  4' 
		5='Very true of me5';
	value psi4_ 1='Notat all true of me1' 2='Somewhattrue of me2' 
		3='Moderately true of me3' 4='True of me  4' 
		5='Very true of me5';
	value psi5_ 1='Notat all true of me1' 2='Somewhattrue of me2' 
		3='Moderately true of me3' 4='True of me  4' 
		5='Very true of me5';
	value psi6_ 1='Notat all true of me1' 2='Somewhattrue of me2' 
		3='Moderately true of me3' 4='True of me  4' 
		5='Very true of me5';
	value psi7_ 1='Notat all true of me1' 2='Somewhattrue of me2' 
		3='Moderately true of me3' 4='True of me  4' 
		5='Very true of me5';
	value psi8_ 1='Notat all true of me1' 2='Somewhattrue of me2' 
		3='Moderately true of me3' 4='True of me  4' 
		5='Very true of me5';
	value psi9_ 1='Notat all true of me1' 2='Somewhattrue of me2' 
		3='Moderately true of me3' 4='True of me  4' 
		5='Very true of me5';
	value psi10_ 1='Notat all true of me1' 2='Somewhattrue of me2' 
		3='Moderately true of me3' 4='True of me  4' 
		5='Very true of me5';
	value psi11_ 1='Notat all true of me1' 2='Somewhattrue of me2' 
		3='Moderately true of me3' 4='True of me  4' 
		5='Very true of me5';
	value psi12_ 1='Notat all true of me1' 2='Somewhattrue of me2' 
		3='Moderately true of me3' 4='True of me  4' 
		5='Very true of me5';
	value psi13_ 1='Notat all true of me1' 2='Somewhattrue of me2' 
		3='Moderately true of me3' 4='True of me  4' 
		5='Very true of me5';
	value psi14_ 1='Notat all true of me1' 2='Somewhattrue of me2' 
		3='Moderately true of me3' 4='True of me  4' 
		5='Very true of me5';
	value psi15_ 1='Notat all true of me1' 2='Somewhattrue of me2' 
		3='Moderately true of me3' 4='True of me  4' 
		5='Very true of me5';
	value psi16_ 1='Notat all true of me1' 2='Somewhattrue of me2' 
		3='Moderately true of me3' 4='True of me  4' 
		5='Very true of me5';
	value psi17_ 1='Notat all true of me1' 2='Somewhattrue of me2' 
		3='Moderately true of me3' 4='True of me  4' 
		5='Very true of me5';
	value psi18_ 1='Notat all true of me1' 2='Somewhattrue of me2' 
		3='Moderately true of me3' 4='True of me  4' 
		5='Very true of me5';
	value psi19_ 1='Notat all true of me1' 2='Somewhattrue of me2' 
		3='Moderately true of me3' 4='True of me  4' 
		5='Very true of me5';
	value psi20_ 1='Notat all true of me1' 2='Somewhattrue of me2' 
		3='Moderately true of me3' 4='True of me  4' 
		5='Very true of me5';
	value psi21_ 1='Notat all true of me1' 2='Somewhattrue of me2' 
		3='Moderately true of me3' 4='True of me  4' 
		5='Very true of me5';
	value psi22_ 1='Notat all true of me1' 2='Somewhattrue of me2' 
		3='Moderately true of me3' 4='True of me  4' 
		5='Very true of me5';
	value psi23_ 1='Notat all true of me1' 2='Somewhattrue of me2' 
		3='Moderately true of me3' 4='True of me  4' 
		5='Very true of me5';
	value psi24_ 1='Notat all true of me1' 2='Somewhattrue of me2' 
		3='Moderately true of me3' 4='True of me  4' 
		5='Very true of me5';
	value psi25_ 1='Notat all true of me1' 2='Somewhattrue of me2' 
		3='Moderately true of me3' 4='True of me  4' 
		5='Very true of me5';
	value phq9_q01_ 0='Notat all0' 1='Severaldays1' 
		2='More thanhalfthe days2' 3='Nearlyevery day3';
	value phq9_q02_ 0='Notat all0' 1='Severaldays1' 
		2='More thanhalfthe days2' 3='Nearlyevery day3';
	value phq9_q03_ 0='Notat all0' 1='Severaldays1' 
		2='More thanhalfthe days2' 3='Nearlyevery day3';
	value phq9_q04_ 0='Notat all0' 1='Severaldays1' 
		2='More thanhalfthe days2' 3='Nearlyevery day3';
	value phq9_q05_ 0='Notat all0' 1='Severaldays1' 
		2='More thanhalfthe days2' 3='Nearlyevery day3';
	value phq9_q06_ 0='Notat all0' 1='Severaldays1' 
		2='More thanhalfthe days2' 3='Nearlyevery day3';
	value phq9_q07_ 0='Notat all0' 1='Severaldays1' 
		2='More thanhalfthe days2' 3='Nearlyevery day3';
	value phq9_q08_ 0='Notat all0' 1='Severaldays1' 
		2='More thanhalfthe days2' 3='Nearlyevery day3';
	value phq9_q09_ 0='Notat all0' 1='Severaldays1' 
		2='More thanhalfthe days2' 3='Nearlyevery day3';
	value phq9_q10_ 1='Not difficult at all' 2='Somewhat difficult' 
		3='Very difficult' 4='Extremely difficult' 
		99='Decline to answer';
	value gad1_ 0='Not at all' 1='Several days' 
		2='Over half the days' 3='Nearly every day';
	value gad2_ 0='Not at all' 1='Several days' 
		2='Over half the days' 3='Nearly every day';
	value gad3_ 0='Not at all' 1='Several days' 
		2='Over half the days' 3='Nearly every day';
	value gad4_ 0='Not at all' 1='Several days' 
		2='Over half the days' 3='Nearly every day';
	value gad5_ 0='Not at all' 1='Several days' 
		2='Over half the days' 3='Nearly every day';
	value gad6_ 0='Not at all' 1='Several days' 
		2='Over half the days' 3='Nearly every day';
	value gad7_ 0='Not at all' 1='Several days' 
		2='Over half the days' 3='Nearly every day';
	value qolemot_ 0='Lowest Quality' 1='1' 
		2='2' 3='3' 
		4='4' 5='5' 
		6='6' 7='7' 
		8='8' 9='9' 
		10='Highest Quality';
	value qolsocial_ 0='Lowest Quality' 1='1' 
		2='2' 3='3' 
		4='4' 5='5' 
		6='6' 7='7' 
		8='8' 9='9' 
		10='Highest Quality';
	value qolfin_ 0='Lowest Quality' 1='1' 
		2='2' 3='3' 
		4='4' 5='5' 
		6='6' 7='7' 
		8='8' 9='9' 
		10='Highest Quality';
	value qolphy_ 0='Lowest Quality' 1='1' 
		2='2' 3='3' 
		4='4' 5='5' 
		6='6' 7='7' 
		8='8' 9='9' 
		10='Highest Quality';
	value cccq_01_ 1='Strongly disagree' 2='Disagree' 
		3='Neutral' 4='Agree' 
		5='Strongly agree';
	value cccq_02_ 1='Strongly disagree' 2='Disagree' 
		3='Neutral' 4='Agree' 
		5='Strongly agree';
	value cccq_03_ 1='Strongly disagree' 2='Disagree' 
		3='Neutral' 4='Agree' 
		5='Strongly agree';
	value cccq_04_ 1='Strongly disagree' 2='Disagree' 
		3='Neutral' 4='Agree' 
		5='Strongly agree';
	value cccq_05_ 1='Strongly disagree' 2='Disagree' 
		3='Neutral' 4='Agree' 
		5='Strongly agree';
	value cccq_06_ 1='Strongly disagree' 2='Disagree' 
		3='Neutral' 4='Agree' 
		5='Strongly agree';
	value cccq_07_ 1='Strongly disagree' 2='Disagree' 
		3='Neutral' 4='Agree' 
		5='Strongly agree';
	value cccq_08_ 1='Strongly disagree' 2='Disagree' 
		3='Neutral' 4='Agree' 
		5='Strongly agree';
	value cccq_09_ 1='Strongly disagree' 2='Disagree' 
		3='Neutral' 4='Agree' 
		5='Strongly agree';
	value cccq_10_ 1='Strongly disagree' 2='Disagree' 
		3='Neutral' 4='Agree' 
		5='Strongly agree';
	value cccq_11_ 1='Strongly disagree' 2='Disagree' 
		3='Neutral' 4='Agree' 
		5='Strongly agree';
	value cccq_12_ 1='Strongly disagree' 2='Disagree' 
		3='Neutral' 4='Agree' 
		5='Strongly agree';
	value cccq_13_ 1='Strongly disagree' 2='Disagree' 
		3='Neutral' 4='Agree' 
		5='Strongly agree';
	value cccq_14_ 1='Strongly disagree' 2='Disagree' 
		3='Neutral' 4='Agree' 
		5='Strongly agree';
	value cccq_15_ 1='Strongly disagree' 2='Disagree' 
		3='Neutral' 4='Agree' 
		5='Strongly agree';
	value cccq_16_ 1='Strongly disagree' 2='Disagree' 
		3='Neutral' 4='Agree' 
		5='Strongly agree';
	value cccq_17_ 1='Strongly disagree' 2='Disagree' 
		3='Neutral' 4='Agree' 
		5='Strongly agree';
	value cccq_18_ 1='Strongly disagree' 2='Disagree' 
		3='Neutral' 4='Agree' 
		5='Strongly agree';
	value cccq_19_ 1='Strongly disagree' 2='Disagree' 
		3='Neutral' 4='Agree' 
		5='Strongly agree';
	value cccq_20_ 1='Strongly disagree' 2='Disagree' 
		3='Neutral' 4='Agree' 
		5='Strongly agree';
	value cccq_21_ 1='Strongly disagree' 2='Disagree' 
		3='Neutral' 4='Agree' 
		5='Strongly agree';
	value cccq_22_ 1='Strongly disagree' 2='Disagree' 
		3='Neutral' 4='Agree' 
		5='Strongly agree';
	value cccq_23_ 1='Strongly disagree' 2='Disagree' 
		3='Neutral' 4='Agree' 
		5='Strongly agree';
	value cccq_24_ 1='Strongly disagree' 2='Disagree' 
		3='Neutral' 4='Agree' 
		5='Strongly agree';
	value cccq_25_ 1='Strongly disagree' 2='Disagree' 
		3='Neutral' 4='Agree' 
		5='Strongly agree';
	value cccq_26_ 1='Strongly disagree' 2='Disagree' 
		3='Neutral' 4='Agree' 
		5='Strongly agree';
	value cccq_27_ 1='Strongly disagree' 2='Disagree' 
		3='Neutral' 4='Agree' 
		5='Strongly agree';
	value cccq_28_ 1='Strongly disagree' 2='Disagree' 
		3='Neutral' 4='Agree' 
		5='Strongly agree';
	value cccq_29_ 1='Strongly disagree' 2='Disagree' 
		3='Neutral' 4='Agree' 
		5='Strongly agree';
	value cccq_30_ 1='Strongly disagree' 2='Disagree' 
		3='Neutral' 4='Agree' 
		5='Strongly agree';
	value survey_complete_ 0='Incomplete' 1='Unverified' 
		2='Complete';
	value problm_clist_family_ 1='Yes' 0='No';
	value problm_clist_finance_ 1='Yes' 0='No';
	value problm_clist_pain_ 1='Yes' 0='No';
	value problm_clist_breath_ 1='Yes' 0='No';
	value problm_clist_constipate_ 1='Yes' 0='No';
	value problm_clist_communicate_ 1='Yes' 0='No';
	value problm_clist_hcomm_ 1='Yes' 0='No';
	value problm_clist_confuse_ 1='Yes' 0='No';
	value problm_clist_grief_ 1='Yes' 0='No';
	value problm_clist_anxiety_ 1='Yes' 0='No';
	value problm_clist_fatigue_ 1='Yes' 0='No';
	value problm_clist_depress_ 1='Yes' 0='No';
	value problm_clist_need_ 1='Yes' 0='No';
	value problm_clist_final_wks_ 1='Yes' 0='No';
	value problm_clist_death_ 1='Yes' 0='No';
	value problm_clist_other_ 1='Yes' 0='No';
	value problemconcern_check_v_0_ 0='Incomplete' 1='Unverified' 
		2='Complete';
	value vid_call_occur_yn_ 1='Yes' 0='No';
	value vid_call_type_ 1='VSee' 2='Skype' 
		3='FaceTime' 4='Phone' 
		5='Other';
	value vid_call_missed_ 1='subject didn''t answer the call' 2='connection could not be established' 
		3='other';
	value vid_call_q01_sound_yn_ 1='Yes' 2='No';
	value vid_call_q01_sound_freq_ 1='Once' 2='A few times (2-3)' 
		3='A lot (more than 3 times)' 4='Visit was terminated due to this';
	value vid_call_q01_pic_yn_ 1='Yes' 2='No';
	value vid_call_q01_pic_freq_ 1='Once' 2='A few times (2-3)' 
		3='A lot (more than 3 times)' 4='Visit was terminated due to this';
	value vid_call_q01_oth_yn_ 1='Yes' 2='No';
	value vid_call_q02_sound_yn_ 1='Yes' 2='No';
	value vid_call_q02_sound_freq_ 1='Once' 2='A few times (2-3)' 
		3='A lot (more than 3 times)' 4='Visit was terminated due to this';
	value vid_call_q02_pic_yn_ 1='Yes' 2='No';
	value vid_call_q02_pic_freq_ 1='Once' 2='A few times (2-3)' 
		3='A lot (more than 3 times)' 4='Visit was terminated due to this';
	value vid_call_q02_oth_yn_ 1='Yes' 2='No';
	value vid_call_connect_yn_ 1='Yes' 0='No';
	value vid_call_converse_yn_ 1='Yes' 2='No' 
		3='Don''t know';
	value vid_call_ask_yn_ 1='Yes' 2='No' 
		3='Don''t know';
	value vid_call_mood_yn_ 1='Yes' 2='No' 
		3='Don''t know';
	value vid_call_quality_ 1='Excellent' 2='Good' 
		3='Acceptable' 4='Poor' 
		5='Unacceptable';
	value vid_call_useful_ 1='Very Useful' 2='Useful' 
		3='Neutral' 4='Not Useful' 
		5='Interferes with the intervention';
	value technical_quality_complete_ 0='Incomplete' 1='Unverified' 
		2='Complete';
	value phq9_gad7_follow_up_ 1='Yes' 0='No' 
		99='Not Applicable';
	value phq9_gad7_follow_up_v3_ 1='Yes' 0='No' 
		99='Not Applicable';
	value pisces_email_trigger_complete_ 0='Incomplete' 1='Unverified' 
		2='Complete';
	value complete_et_ 1='Yes' 0='No';
	value reason_et_ 1='Early Withdrawal On Own' 2='Early Withdrawal by PI' 
		3='Lost to follow up' 99='Other';
	value withdrawal_by_pi_reason___1_ 0='Unchecked' 1='Checked';
	value withdrawal_by_pi_reason___2_ 0='Unchecked' 1='Checked';
	value withdrawal_by_pi_reason___3_ 0='Unchecked' 1='Checked';
	value updated_et_ 1='Yes' 0='No';
	value lab_et_ 1='Yes' 0='N/A';
	value new_ae_et_ 1='Yes' 0='No';
	value change_et_ 1='Yes' 0='No' 
		3='N/A';
	value ongoing_et_ 1='Yes' 0='No' 
		3='N/A';
	value early_termination_fo_v_1_ 0='Incomplete' 1='Unverified' 
		2='Complete';
	run;

data redcap;
	set redcap;

	format redcap_event_name redcap_event_name_.;
	format interventionist interventionist_.;
	format caregiver_id_complete caregiver_id_complete_.;
	format group_assignment group_assignment_.;
	format caregiver_status caregiver_status_.;
	format caregiver_comments caregiver_comments_.;
	format caregiver_status_complete caregiver_status_complete_.;
	format demog_gender demog_gender_.;
	format demog_ethnic demog_ethnic_.;
	format demog_race___0 demog_race___0_.;
	format demog_race___1 demog_race___1_.;
	format demog_race___2 demog_race___2_.;
	format demog_race___3 demog_race___3_.;
	format demog_race___4 demog_race___4_.;
	format demog_race___5 demog_race___5_.;
	format demog_race___6 demog_race___6_.;
	format demog_race___99 demog_race___99_.;
	format demog_marital demog_marital_.;
	format demog_edu demog_edu_.;
	format demog_relation demog_relation_.;
	format demog_patient_gender demog_patient_gender_.;
	format demog_patient_ethnic demog_patient_ethnic_.;
	format demog_patient_race___0 demog_patient_race___0_.;
	format demog_patient_race___1 demog_patient_race___1_.;
	format demog_patient_race___2 demog_patient_race___2_.;
	format demog_patient_race___3 demog_patient_race___3_.;
	format demog_patient_race___4 demog_patient_race___4_.;
	format demog_patient_race___5 demog_patient_race___5_.;
	format demog_patient_race___6 demog_patient_race___6_.;
	format demog_patient_race___99 demog_patient_race___99_.;
	format demog_patient_marital demog_patient_marital_.;
	format demog_patient_residence demog_patient_residence_.;
	format demog_distance demog_distance_.;
	format demog_care demog_care_.;
	format demog_hours_care demog_hours_care_.;
	format demog_add_expense demog_add_expense_.;
	format demog_work demog_work_.;
	format demog_work_support___0 demog_work_support___0_.;
	format demog_work_support___1 demog_work_support___1_.;
	format demog_work_support___2 demog_work_support___2_.;
	format demog_work_support___3 demog_work_support___3_.;
	format demog_work_support___4 demog_work_support___4_.;
	format demog_work_support___99 demog_work_support___99_.;
	format psi1 psi1_.;
	format psi2 psi2_.;
	format psi3 psi3_.;
	format psi4 psi4_.;
	format psi5 psi5_.;
	format psi6 psi6_.;
	format psi7 psi7_.;
	format psi8 psi8_.;
	format psi9 psi9_.;
	format psi10 psi10_.;
	format psi11 psi11_.;
	format psi12 psi12_.;
	format psi13 psi13_.;
	format psi14 psi14_.;
	format psi15 psi15_.;
	format psi16 psi16_.;
	format psi17 psi17_.;
	format psi18 psi18_.;
	format psi19 psi19_.;
	format psi20 psi20_.;
	format psi21 psi21_.;
	format psi22 psi22_.;
	format psi23 psi23_.;
	format psi24 psi24_.;
	format psi25 psi25_.;
	format phq9_q01 phq9_q01_.;
	format phq9_q02 phq9_q02_.;
	format phq9_q03 phq9_q03_.;
	format phq9_q04 phq9_q04_.;
	format phq9_q05 phq9_q05_.;
	format phq9_q06 phq9_q06_.;
	format phq9_q07 phq9_q07_.;
	format phq9_q08 phq9_q08_.;
	format phq9_q09 phq9_q09_.;
	format phq9_q10 phq9_q10_.;
	format gad1 gad1_.;
	format gad2 gad2_.;
	format gad3 gad3_.;
	format gad4 gad4_.;
	format gad5 gad5_.;
	format gad6 gad6_.;
	format gad7 gad7_.;
	format qolemot qolemot_.;
	format qolsocial qolsocial_.;
	format qolfin qolfin_.;
	format qolphy qolphy_.;
	format cccq_01 cccq_01_.;
	format cccq_02 cccq_02_.;
	format cccq_03 cccq_03_.;
	format cccq_04 cccq_04_.;
	format cccq_05 cccq_05_.;
	format cccq_06 cccq_06_.;
	format cccq_07 cccq_07_.;
	format cccq_08 cccq_08_.;
	format cccq_09 cccq_09_.;
	format cccq_10 cccq_10_.;
	format cccq_11 cccq_11_.;
	format cccq_12 cccq_12_.;
	format cccq_13 cccq_13_.;
	format cccq_14 cccq_14_.;
	format cccq_15 cccq_15_.;
	format cccq_16 cccq_16_.;
	format cccq_17 cccq_17_.;
	format cccq_18 cccq_18_.;
	format cccq_19 cccq_19_.;
	format cccq_20 cccq_20_.;
	format cccq_21 cccq_21_.;
	format cccq_22 cccq_22_.;
	format cccq_23 cccq_23_.;
	format cccq_24 cccq_24_.;
	format cccq_25 cccq_25_.;
	format cccq_26 cccq_26_.;
	format cccq_27 cccq_27_.;
	format cccq_28 cccq_28_.;
	format cccq_29 cccq_29_.;
	format cccq_30 cccq_30_.;
	format survey_complete survey_complete_.;
	format problm_clist_family problm_clist_family_.;
	format problm_clist_finance problm_clist_finance_.;
	format problm_clist_pain problm_clist_pain_.;
	format problm_clist_breath problm_clist_breath_.;
	format problm_clist_constipate problm_clist_constipate_.;
	format problm_clist_communicate problm_clist_communicate_.;
	format problm_clist_hcomm problm_clist_hcomm_.;
	format problm_clist_confuse problm_clist_confuse_.;
	format problm_clist_grief problm_clist_grief_.;
	format problm_clist_anxiety problm_clist_anxiety_.;
	format problm_clist_fatigue problm_clist_fatigue_.;
	format problm_clist_depress problm_clist_depress_.;
	format problm_clist_need problm_clist_need_.;
	format problm_clist_final_wks problm_clist_final_wks_.;
	format problm_clist_death problm_clist_death_.;
	format problm_clist_other problm_clist_other_.;
	format problemconcern_check_v_0 problemconcern_check_v_0_.;
	format vid_call_occur_yn vid_call_occur_yn_.;
	format vid_call_type vid_call_type_.;
	format vid_call_missed vid_call_missed_.;
	format vid_call_q01_sound_yn vid_call_q01_sound_yn_.;
	format vid_call_q01_sound_freq vid_call_q01_sound_freq_.;
	format vid_call_q01_pic_yn vid_call_q01_pic_yn_.;
	format vid_call_q01_pic_freq vid_call_q01_pic_freq_.;
	format vid_call_q01_oth_yn vid_call_q01_oth_yn_.;
	format vid_call_q02_sound_yn vid_call_q02_sound_yn_.;
	format vid_call_q02_sound_freq vid_call_q02_sound_freq_.;
	format vid_call_q02_pic_yn vid_call_q02_pic_yn_.;
	format vid_call_q02_pic_freq vid_call_q02_pic_freq_.;
	format vid_call_q02_oth_yn vid_call_q02_oth_yn_.;
	format vid_call_connect_yn vid_call_connect_yn_.;
	format vid_call_converse_yn vid_call_converse_yn_.;
	format vid_call_ask_yn vid_call_ask_yn_.;
	format vid_call_mood_yn vid_call_mood_yn_.;
	format vid_call_quality vid_call_quality_.;
	format vid_call_useful vid_call_useful_.;
	format technical_quality_complete technical_quality_complete_.;
	format phq9_gad7_follow_up phq9_gad7_follow_up_.;
	format phq9_gad7_follow_up_v3 phq9_gad7_follow_up_v3_.;
	format pisces_email_trigger_complete pisces_email_trigger_complete_.;
	format complete_et complete_et_.;
	format reason_et reason_et_.;
	format withdrawal_by_pi_reason___1 withdrawal_by_pi_reason___1_.;
	format withdrawal_by_pi_reason___2 withdrawal_by_pi_reason___2_.;
	format withdrawal_by_pi_reason___3 withdrawal_by_pi_reason___3_.;
	format updated_et updated_et_.;
	format lab_et lab_et_.;
	format new_ae_et new_ae_et_.;
	format change_et change_et_.;
	format ongoing_et ongoing_et_.;
	format early_termination_fo_v_1 early_termination_fo_v_1_.;
	run;

proc contents data=redcap;
proc print data=redcap;
run;
quit;
data raw.pisces ; 
set REDCAP; 
run; 
proc format library=work.formats cntlout = redcap.pisces_formats; 
run; 
proc format library=raw.pisces_formats cntlin=redcap.pisces_formats; 
run; 
