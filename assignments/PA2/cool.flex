/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;


	/*
	*  Add Your own definitions here
	*/
char const_string[MAX_STR_CONST];


%}

	/*
	* Define names for regular expressions here.
	*/
%option noyywrap
%x LINE_COMMENT NESTED_COMMENT

DARROW          =>
ASSIGN          <-
LE				<=
DIGIT			[0-9]

%%

	/*
 	* update new line
 	*
 	*/

"\n"          { curr_lineno++; }
[ \f\r\t\v]+  {}

	/*
  	*  Nested comments
  	*/
"(*"       { BEGIN NESTED_COMMENT; }
"*)"       { strcpy(cool_yylval.error_msg, "Unmatched *)"); return (ERROR); }
"--"       { BEGIN LINE_COMMENT; }
	/*<LINE_COMMENT>.*            {}
	<NESTED_COMMENT>.*\*\)      {}
	<NESTED_COMMENT><<EOF>>   { strcpy(cool_yylval.error_msg, "EOF in comment"); return (ERROR); }
	*/

	/*
	*  The multiple-character operators.
	*/
{DARROW}	{ return (DARROW); }
{ASSIGN}    { return (ASSIGN); }
{LE}        { return (LE); }
"+"			{ return int('+'); }
"/"			{ return int('/'); }
"-"			{ return int('-'); }
"*"			{ return int('*'); }
"="			{ return int('='); }
"<"			{ return int('<'); }
"."			{ return int('.'); }
"~"			{ return int('~'); }
","			{ return int(','); }
";"			{ return int(';'); }
":"			{ return int(':'); }
"("			{ return int('('); }
")"			{ return int(')'); }
"@"			{ return int('@'); }
"{"			{ return int('{'); }
"}"			{ return int('}'); }



 	/*
  	* Keywords are case-insensitive except for the values true and false,
  	* which must begin with a lower-case letter.
  	*/
(?i:class)		{ return CLASS; }
(?i:else) 		{ return ELSE; }
(?i:fi) 		{ return FI; }
(?i:if) 		{ return IF; }
(?i:inherits) 	{ return INHERITS; }
(?i:isvoid) 	{ return ISVOID; }
(?i:let) 		{ return LET; }
(?i:loop) 		{ return LOOP; }
(?i:pool) 		{ return POOL; }
(?i:then) 		{ return THEN; }
(?i:while) 		{ return WHILE; }
(?i:case) 		{ return CASE; }
(?i:esac) 		{ return ESAC; }
(?i:new) 		{ return NEW; }
(?i:of) 		{ return OF; }
(?i:not) 		{ return NOT; }
(?-i:false) 	{ cool_yylval.boolean = false; return BOOL_CONST; }
(?-i:true) 		{ cool_yylval.boolean = true; return BOOL_CONST; }

 	/*
  	*  String constants (C syntax)
  	*  Escape sequence \c is accepted for all characters c. Except for 
  	*  \n \t \b \f, the result is c.
  	*
  	*/


%%