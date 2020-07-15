data dup;
set prov;
by PROV1680;
if not (first.PROV1680 and last.PROV1680) then dup=1;
else dup=0;
run;
data dup_;
