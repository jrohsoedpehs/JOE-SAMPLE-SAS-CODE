/*CATX Function in SAS concatenates the two or more character strings and adds a delimiter after each string's value. */
/*It also removes leading and trailing spaces from the resultant string or variable. */
/*The Resultant concatenated string would be a character string. We can say that CATX is the same as CATS */
/*just that it adds a delimited between values being concatenated.*/

/*Syntax*/
/*result_catx = CATX('Delimiter'm, string1, string2, ..., stringN*/



/*Concatenation Functions In SAS : CAT, CATT, CATS, CATX, CATQ */
/*Hi All,*/
/*Today i am explaining something about to add two or more character strings in SAS. Adding two or more */
/*character or string which simply notify towards the CONCATENATION.*/
/*We can simply define concatenation as to put two or more strings together is concatenation. Here we */
/*would not discuss about the concatenation operators which are || (vertical bar) and !!  (Exclamation mark ) */
/*but we would discuss on some concatenation functions in SAS which are CAT, CATT, CATQ, CATS and CATX.*/
/*All the Concatenation functions takes two or more arguments and concatenate the strings or variables. */
/*For all concatenation functions (if applies) removes the leading or trailing blanks from resultant */
/*concatenated string before the concatenating of strings.*/
/*Note : Whenever we use concatenation operator || or !!, The Length of the resultant string would be */
/*the sum of the lengths of all individual strings we are adding or concatenating.*/
/*CAT Function in SAS : It concatenates the two or more character strings and does not remove leading */
/*or trailing blanks. The resultant concatenated string would be a character string.*/
/*Syntax : Result_cat =CAT (String1, String2,.....StringN);*/
/*CATT Function in SAS : It concatenates the two or more character strings and removes trailing blanks */
/*from the resultant string or variable. The resultant concatenated string would be a character string.*/
/*Syntax : Result_catt =CATT(String1, String2,.....StringN);*/
/*CATS Function in SAS : It concatenates the two or more character strings and removes all leading and */
/*trailing blanks from the resultant string or variable. The resultant concatenated string would be a character string.*/
/*Synatax : Result_cats =CATS(String1, String2,.......StringN);*/
/*CATX Function in SAS : it concatenates the two or more character strings and adds a delimiters after*/
/*each string's value. It also removes leading and trailing from resultant string or variable. The resultant */
/*concatenated string would be a character string. We can say that CATX is same as CATS just it adds a */
/*delimiter between values being concatenated.*/
/*Syntax: Result_catx=CATX('Delimiter', String1, String2,,..... , StringN);*/
/*CATQ Function in SAS : It concatenates the two or more character or numeric strings by adding a delimiter */
/*and quotation mark to that string which contain the delimiter. CATQ function is similar to the CATX function */
/*excepts it also adds quotation marks.*/
/*Syntax: Result_catQ=CATQ(Modifier,'Delimiter',String1, String2,.....StringN);*/
/*Modifiers for CATQ function:*/
/*1. 1 or ' : For single quotation mark*/
/*2. 2 or " : For double quotation mark*/
/*3. a or A : For adding quotation mark to all of the arguments*/
/*4. c or C : For comma as a delimiter*/
/*5. d or D : Tells that we have specified delimiter argument*/
/*6. h or H : For horizontal tab as a delimiter*/
/*For all concatenate functions:*/
/*• The Default LENGTH of returned variable from any CAT* function would be 200 bytes, if Length is not previously specified to the assigned variable of CAT function*/
/*• CAT* function always returns a value to a variable*/
/*• For numeric variables / arguments, CAT* function removes trailing and leading after formatting numeric arguments to the BESTw. format*/
/*• The returned values from CAT, CATS, CATT and CATX are normally equivalent with the resultant values of concatenation operator (with certain combination like : Trim, Left, Strip) except in length*/
/*• CAT, CATS,CATT and CATX functions are faster than using TRIM and LEFT functions*/
/*• In CATQ, if we do not use C,D or H as modifiers, then CATQ would use blank as delimiter*/
