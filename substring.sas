/*
SYNTAX

The SUBSTR function has three arguments:

SUBSTR(SOURCE, POSITION, N)

The function returns N characters, beginning at character number
POSITION from the string SOURCE.

? SOURCE—This is the larger or reference string. It can be a
variable or a string of characters.
? POSITION—This value is a positive integer and references the
starting point to begin reading the internal group of characters.
? N—This value is a positive integer and references the number
of characters to read from the starting point POSITION in the
field SOURCE.

The second and third arguments POSITION and N must be positive
integers.
*/

/*RIGHT SIDE APPLICATION*/
%let phone = (312) 555-1212 ;
data _null_ ;
phone = ‘(312) 555-1212’ ;
area_cd = substr(phone, 2, 3) ;
area_cd = substr(‘(312) 555-1212’, 2, 3) ;
area_cd = substr(“&phone”, 2, 3) ;
run ;

/*
Each time the function is applied, the SOURCE is a different type,
but the end result is the same.
1. The first use pulls from the variable PHONE
2. The second pulls from hard-coded string
3. The third pulls from the quoted macro variable &PHONE.
Result: ‘312’ assigned to the variable AREA_CD each time.
*/

/*LEFT SIDE APPLICATION*/
data _null_ ;
phone = ‘(312) 555-1212’ ;
substr(phone, 2, 3) = ‘773’ ;
run;

/*
In this example, the area code of the variable PHONE was changed
from ‘312’ to ‘773’.
*/
