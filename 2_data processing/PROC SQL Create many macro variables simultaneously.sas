/*PROC SQL Create many macro variables simultaneously*/
proc sql noprint;
        select Col1,Col12
        into :vars1, :logic1
        separated by ' '
        from raw.ReferralTracking_Dictionary
        where Col2 in("referral_tracking");
/*		where Col2 in("referral_tracking") and Col11 ne "y" and (Col4 notin("descriptive", "notes") and (Col4 = "text" and Col8 ne "") or */
/*		    Col4 in("yesno","radio","checkbox","file","dropdown"));*/

    quit;

	%put &vars1;
	%put &logic1;
