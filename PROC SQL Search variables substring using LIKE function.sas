/*PROC SQL Search variables substring*/

proc contents data=raw.referral_tracking out=cont_out noprint;run;
proc sql ;
    select name
    into:complete separated by ' '
    from cont_out
	where lowcase(trim(name)) like "%^_complete" escape '^';
quit;
/*% IS A STRING CHARACTER WILD CARD OF ANY OR NO LENGTH*/
/*Like function is a boolean T/F on String matching*/
/*Because the % and _ characters have special meaning in */
/*the context of the LIKE condition, you must use the ESCAPE clause to search */
/*for these character literals in the input character string.*/

/*FIND ALL CHECKBOX VARIABLES*/
proc contents data=raw.referral_tracking out=cont_out noprint;run;
proc sql ;
    select name
    into :complete separated by ' '
    from cont_out
	where lowcase(trim(name)) like "%^___%" escape '^';
quit;
/*CHECKBOX FIELDS IN REDCap ARE ALWAYS OF THE FORMAT var___1, var___2, etc*/
/*look for "%___%" to find them*/
/*% IS A STRING CHARACTER WILD CARD OF ANY OR NO LENGTH*/

proc print
