
/*SCAN Function*/

/*Returns the nth word from a character string. */


/*Syntax */


/*SCAN(string, count,charlist ,modifiers)  */

/*
Arguments


string
specifies a character constant, variable, or expression.

count
is a nonzero numeric constant, variable, or expression that has an integer value that 
specifies the number of the word in the character string that you want SCAN to select. 
For example, a value of 1 indicates the first word, a value of 2 indicates the second word, and so on. 
The following rules apply: 

•If count is positive, SCAN counts words from left to right in the character string.


•If count is negative, SCAN counts words from right to left in the character string.

charlist
specifies an optional character expression that initializes a list of characters. 
This list determines which characters are used as the delimiters that separate words. 
The following rules apply: 

•By default, all characters in charlist are used as delimiters.


•If you specify the K modifier in the modifier argument, 
then all characters that are not in charlist are used as delimiters.

*/
