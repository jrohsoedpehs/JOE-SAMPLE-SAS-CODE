/*AGGREGATE*/
proc freq data = derived.recruitment /*noprint*/;
    table month_inclusion_date / outcum out = work.total_enrolled_per_month;
    title "Cumulative patients enrolled per month";
run;
