/*I do not like PROC SQL. I don’t like the fact that it is neither pure SQL nor is it SAS, and that SAS programmers */
/*need to jump between SAS datasteps and PROC SQL, depending on which will perform a particular operation in the most */
/*efficient manner. Most of all, I do not like the fact that as SAS programmers we cannot live without it.*/

/*In the SAS documentation PROC SQL is described as a procedure that:*/

/*“. . . can perform some of the operations that are provided by the DATA step and the PRINT, SORT, and SUMMARY procedures.”*/

/*What the documentation does not tell you is that PROC SQL can do some of these operations more elegantly than SAS. There */
/*are even operations the SQL procedure performs that would take vast amounts of complicated code to implement in SAS.*/

/*One such operation is performed using the INTO statement. The INTO statement in PROC SQL is used to put values from datasets */
/*into macro variables. There is nothing special about this on its own, but the INTO statement also has the ability to populate */
/*the macro variable with a delimited list of multiple values. The code below extracts names from a dataset that begin with the*/
/*letter “P”. These names are then put into a macro variable using the INTO statement. This macro variable is then used as the */
/*criteria to make an extraction from another dataset.*/

data name_list;
      length name $10;
      input name $;
datalines;
Peter
John
Paul
David
;
run;

proc print data= name_list;run;


data likes;
      length name $10 likes $10;
      input name $ likes $;
datalines;
Peter Cakes
Simon Basketball
Philip Apples
Sam Oranges
Paul Bananas
John Cricket
Frank Cats
;
run;

proc print data= likes;run;


%macro example1;

      proc sql noprint;
            select name
            into :names separated by '" "' 
            from name_list
            where substr(name,1,1) = 'P';
      quit;
      %put &names;
      data output;
            set likes;
            where name in ("&names");
      run;

%mend;
%example1;



/*Although this example does not offer much over the alternative of sorting and merging the two datasets together, */
/*when the datasets in use are very large, this method becomes hugely attractive because of its efficiency over the merging method.*/

/*Another example where the INTO statement can prove useful is creating a macro variable containing the number of observations */
/*within a dataset. The code below counts the observations in a dataset before taking each value in turn and using it to create a new dataset.*/

%macro example2;

      proc sql noprint;
            select count(*)
            into :obs
            from name_list;
      quit;
      %put obs;
      %do i = 1 %to &obs;
  
            proc sql noprint;
                  select name
                  into :name
                  from name_list (firstobs = &i obs = &i);
            quit;
            %put name;
            data &name;
                  set likes;
                  where name = "&name";
            run;

 %end;

%mend;

%example2;

/*These are just a couple of ways the INTO statement can solve problems that, although solvable in SAS, */
/*the solutions are not quite as concise and elegant. The examples given here are very simple because they */
/*are intended as a starting point to demonstrate the ease with which the INTO statement can be used. */

/*The examples above are an excellent introduction to using SQL to create macro variables, but with some */
/*minor changes to example 2, we can show off an additional facet of the INTO statement - the ability to create */
/*multiple macro variables at once.*/

/*Let's take a slightly different situation, where we only have the 'likes' dataset and we want to create */
/*subsets for all the names contained in it. This is straightforward enough to begin with - we simply run our */
/*Proc SQL steps on the 'likes' dataset, rather than the 'name_list' dataset, and everything else follows through */
/*as before. However, what if Peter is not a one-dimensional character, who can be summed up by a single observation */
/*in a SAS dataset? What if Peter likes cakes *and* chocolate?*/

/*Technically the code will still function in this case too. On the first run through the do loop, with &i = 1, */
/*it will pull the name "Peter" from the first observation, set it as the value for &name and then use that to */
/*create the data subset. Then on the second run through the loop, with &i = 2, it will pull out the name "Peter" */
/*again and recreate the exact same dataset. The resulting output will be correct, but there is unnecessary repeat */
/*processing, which will only get worse if Peter also like cookies, pizza, beer, etc.*/

/*So, in a slight variation (which we will imaginatively call Example 2a), let's have a look at what happens if we */
/*use INTO to create all the macro variables up front. Instead of the do loop creating the &name macro variable each */
/*time, we can first create multiple macro variables - &name1, &name2, &name3, etc.. - containing the unique names, */
/*so that we don't re-run on any duplicates. These can then be run through the loop, pretty much as before, making use */
/*of double ampersands to let the macro variables resolve correctly.*/

data likes;
    length name $10 likes $10;
    input name $ likes $;
    datalines;
        Peter Cakes
        Peter Chocolate
        Simon Basketball
        Philip Apples
        Sam Oranges
        Paul Bananas
        John Cricket
        Frank Cats
        Frank Evita
        ;

run;
proc print data= likes;run;

%macro example2a;

     proc sql noprint;
        select count(distinct name)
        into :obs
        from likes;
    quit;

    proc sql noprint;
        select distinct name
        into :name1-
        from likes;
    quit;

     %do i = 1 %to &obs;
        data &&name&i;
            set likes;
            where name = "&&name&i";
        run;
    %end;

%mend;

%example2a;
proc print data= Peter;run;
