
data person;
   infile datalines delimiter=','; 
   input name $ dept $;
   datalines;                      
John,Sales
Mary,Acctng
;
run;
proc print data=person;run;



data dsn1;
infile datalines delimiter=','  ; 
input Col1 $ Col2 $ Col4 $ Col12 $;
datalines;
record_id,referral_tracking,text, 
staff_name,referral_tracking,text, 
interventionist_1,referral_tracking,radio,
interventionist,referral_tracking,text,
referral_date,referral_tracking,text,
referral_site,referral_tracking,radio,
admissions_staff,referral_tracking,text,
caregiver_name,referral_tracking,text,
caregiver_phone_number,referral_tracking,text,
caregiver_relation,referral_tracking,radio,
relation_specify,referral_tracking,text,[caregiver_relation] = '9'
best_time_to_contact,referral_tracking,notes,
pre_screen_interest,referral_tracking,yesno,
comments_site_log,referral_tracking,notes,
screener_status,referral_tracking,radio,
non_participation_reason,referral_tracking,radio,[screener_status] = '2'
other_reason_for_declining,referral_tracking,notes,[non_participation_reason] = '99'
eligibility_status,referral_tracking,radio,
reasons_for_ineligibility,referral_tracking,radio,[eligibility_status] = '2'
consent_visit_scheduled,referral_tracking,radio,
consent_visit_date,referral_tracking,text,
caregiver_address,referral_tracking,notes,
enrolled,referral_tracking,radio,
outcome_of_consent_visit,referral_tracking,radio,[enrolled]="2"
declined_text,referral_tracking,notes,[outcome_of_consent_visit] = '2'
participation_declined,referral_tracking,radio,[outcome_of_consent_visit]="2"
consent_visit_notes,referral_tracking,notes,
caregiver_id,referral_tracking,text,
group_number,referral_tracking,text,
non_participation_text,referral_tracking,notes,[non_participation_reason] = '99'
contact_date_1,contact_1,text,
contact_outcome_1,contact_1,radio,
contact_notes_1,contact_1,notes,
contact_date_2,contact_2,text,
contact_outcome_2,contact_2,radio,
contact_notes_2,contact_2,notes,
contact_date_3,contact_3,text,
contact_outcome_3,contact_3,radio,
contact_notes_3,contact_3,notes,
contact_date_4,contact_4,text,
contact_outcome_4,contact_4,radio,
contact_notes_4,contact_4,notes,
contact_date_5,contact_5,text,
contact_outcome_5,contact_5,radio,
contact_notes_5,contact_5,notes,
contact_date_6,contact_6,text,
contact_outcome_6,contact_6,radio,
contact_notes_6,contact_6,notes,
contact_date_7,contact_7,text,
contact_outcome_7,contact_7,radio,
contact_notes_7,contact_7,notes,

;
run;

proc print data=dsn1;run;
