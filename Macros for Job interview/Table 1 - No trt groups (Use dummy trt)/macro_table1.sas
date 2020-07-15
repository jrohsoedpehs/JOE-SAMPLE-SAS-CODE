
%macro cont(invar,label,order,datain);
*proc printto print= "g&order..dat";
proc means data=&datain noprint;
	by trt;
	var &invar;
	output out=&invar n=nn mean=nmean
	std=nstd min=nmin max=nmax;
run;    
proc means data=demo noprint; 
	var &invar;
	output out=tot&invar n=nn mean=nmean
	std=nstd min=nmin max=nmax;
run;   
data tot&invar(drop=nn nmean nstd nmin nmax);
	length n mean std min max $12  ;
	set tot&invar;
	order=&order; 
	mean=put(nmean,5.1);
	std=put(nstd,6.2); 
	meanstd  = put(mean,5.2)||' ('||trim(left(std))||')'; 
	array v{ 3 } nn nmin nmax;
	array c{3} $ n min max;
	do i=1 to 3;
	c{i}=put(round(v{i},.1),3.);
	end;
run;      
proc transpose data=tot&invar prefix = _ out=tot&invar.t; 
	by order  ;
	var  n mean std min max;
run;      
data tot&invar.t(keep=totstats catn order);
	length _1 $12 cat $33;
	set tot&invar.t ;
	totstats=_1 ;
	select (_name_);
	when ('n') do; cat='N'; catn= 1; end;
	when ('mean') do; cat='Mean'; catn=2;end;
	when ('std') do; cat= 'STD'; catn=3; end;
	when ('min') do; cat='Min'; catn=4; end;
	when ('max') do; cat= 'Max'; catn=5; end;
	otherwise;
	end;
run;

proc sort data=tot&invar.t; by order catn; run; 
      

data &invar(drop=nn nmean nstd nmin nmax);
	length n mean std min max $12 varlab $150;
	set &invar;
	order=&order;
	varlab="&label";
	mean=put(nmean,5.1);
	std=put(nstd,6.2); 
	meanstd  = put(mean,5.2)||' ('||trim(left(std))||')'; 
	array v{ 3 } nn nmin nmax;
	array c{3} $ n min max;
	do i=1 to 3;
	c{i}=put(round(v{i},.1),3.);
	end;
run;
proc transpose data=&invar prefix = _ out=&invar.t;	 
	id trt;
	by order varlab;
	var  n mean std min max;
run;
 
 
data &invar.t(drop=a b  _name_ );
	length _1 $12 cat $33;
	set &invar.t(rename=(_1=a _2=b ));
	_1=a;  _2=b;  *_3=c;
	select (_name_);
	when ('n') do; cat='N'; catn= 1; end;
	when ('mean') do; cat='Mean'; catn=2;end;
	when ('std') do; cat= 'STD'; catn=3; end;
	when ('min') do; cat='Min'; catn=4; end;
	when ('max') do; cat= 'Max'; catn=5; end;
	otherwise;
	end;
run;

proc sort data=&invar.t; by order catn; run;

*proc printto print= "g&order..dat" new;
proc glm data=demo outstat=&invar.p noprint;
	class trt;
	model &invar=trt/ss3;
run;
/*proc printto; run;*/

data &invar.p (keep=order pvalue );
	length pvalue $8;
	set &invar.p;
	if _type_='SS3' and _source_='trt';
	order=&order;
	pvalue=put(round(prob, .001 ),8.3);
run;

data &invar;
	merge tot&invar.t &invar.t &invar.p;
	by order;
	if not first.order then pvalue=' ';
run;
 
proc append base=new data= &invar force; run;
                  
%mend cont;

 
* Part 3: Macro for categorical variables;

* The meaning of the Macro variables: 
1. invar: the variable that you want to analyse.
2. label: The label that you want to add for the variable.
3. fmt:   The format of the variable.
4. method: The model that you want to use.
3. order: Position the variable should be;
%macro catg(invar,label,fmt,method,order,where,datain );
*proc printto print= "g&order..dat";
proc freq data=&datain  noprint;
&where;
tables trt/out=trt; 
tables &invar/out=tot&invar;
tables trt*&invar/out=&invar;
*proc printto;* run;

data _null_;
set trt;
select (trt);
when (1) call symput("tot1", count);
when (2) call symput("tot2", count);
*when (3) call symput("tot3", count);
otherwise;
end;
run;

data tot&invar
(keep=order totstats);
length  totstats $12 ;
set tot&invar; 
order=&order;
percent=(count/(&tot1+&tot2))*100;  
pct=put(round(percent,.1),5.1);
totstats=put(count,3.)||' ('||right(pct)||'%)';
run;
proc sort data=tot&invar;
by order ;
run;

data &invar;
set &invar;
order=&order;
run; 
proc sort data=&invar; by order trt; run;
data &invar(keep=cat order catn &invar stats varlab trt);
length cat $33 pct $5 stats $12 varlab $150;
set &invar;
by order;
varlab="&label";
catn=&invar;
cat=put(&invar, &fmt.);
select (trt);
when (1) percent=(count/&tot1)*100;
when (2) percent=(count/&tot2)* 100;
*when (3) percent=(count/&tot3)* 100;
otherwise;
end;
pct=put(round(percent,.1),5.1);
stats=put(count,3.)||' ('||right(pct)||'%)';
run;

proc sort data=&invar;
by order varlab &invar cat catn;
run;

proc transpose data=&invar out=&invar.t;
id trt;
by order varlab &invar cat catn;
var stats;
run;
 

%if %upcase(&method) =CHISQ %then %do;

*proc printto print= "g&order..dat";
proc freq data=demo1 noprint;
	tables trt*&invar/chisq;
	output out=&invar.p chisq;
	format &invar &fmt;
run;

data &invar.p(keep=order pvalue);
	set &invar.p;
	length pvalue $8;
	order=&order;
	pvalue=put(p_pchi,8.3);
run;

data &invar(drop=&invar);
	merge &invar.t(drop=_name_) &invar.p tot&invar;
	by order;
	if not first.order then pvalue=' ';
run;

%end; 

%else %if %upcase(&method) =FISHER %then %do;

*proc printto print= "g&order..dat";
proc freq data=demo1 noprint;
	tables trt*&invar/fisher;
	output out=&invar.p fisher;
	format &invar &fmt;
run;

data &invar.p(keep=order pvalue);
	set &invar.p;
	length pvalue $8;
	order=&order;
	pvalue=put(xp2_fish,8.3);
run;

data &invar(drop=&invar);
	merge &invar.t(drop=_name_) &invar.p  tot&invar;
	by order;
	if not first.order then pvalue=' ';
run;

%end;
%else %if %upcase(&method)= %then %do;

data &invar.p(keep=order pvalue);
	length pvalue $8;
	set &invar.t(drop=_name_);
	by order;
	pvalue=' ';
	output;
	if last.order then do;
	cat=' '; _1=' '; _2=' ';  *_3=' ';pvalue=' ';
	output ;
	end;
run;
%end;

proc append base=new data=&invar force; run;
 
%mend catg;
