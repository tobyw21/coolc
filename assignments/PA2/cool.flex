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
%x LINE_COMMENT NESTED_COMMENT STRING

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
"(*"       					  { BEGIN NESTED_COMMENT; }
<NESTED_COMMENT>[^\n(*]*      {}
<NESTED_COMMENT>[()*]		  {}
<NESTED_COMMENT>"*)"		  { BEGIN 0; }	
"*)"       					  { cool_yylval.error_msg = "Unmatched *)"; return (ERROR); }
<NESTED_COMMENT><<EOF>>   	  { cool_yylval.error_msg = "EOF in comment"; BEGIN 0; return (ERROR); }

	/*
	* line comment
	*/
"--"       { BEGIN LINE_COMMENT; }
<LINE_COMMENT>.*            {}
<LINE_COMMENT>\n 			{ curr_lineno++; BEGIN 0; }
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

	/* TYPEID*/
[A-Z][A-Za-z0-9_]* { cool_yylval.symbol = idtable.add_string(yytext); return TYPEID; }

	/* OBJID */
[a-z][A-Za-z0-9_]* { cool_yylval.symbol = idtable.add_string(yytext); return OBJECTID; }

	/* int */
{DIGIT}*		   { cool_yylval.symbol = inttable.add_string(yytext); return INT_CONST; }

[^\n] 			   { cool_yylval.error_msg = yytext; return ERROR; }

 	/*
  	*  String constants (C syntax)
  	*  Escape sequence \c is accepted for all characters c. Except for 
  	*  \n \t \b \f, the result is c.
  	*
  	*/
\"						{ BEGIN STRING; yymore(); }
<STRING>\\[^\n]			{ yymore(); }
<STRING><<EOF>> 		{ cool_yylval.error_msg = "EOF in string const"; BEGIN 0; yyrestart(yyin); return ERROR; }
<STRING>\\\n			{ curr_lineno++; yymore(); }
<STRING>\n 				{ cool_yylval.error_msg = "Unterminated string const"; BEGIN 0; curr_lineno++; return ERROR; }
<STRING>\\0				{ cool_yylval.error_msg = "Unterminated string const"; BEGIN 0; return ERROR; }
<STRING>\"				{ 


	cool_yylval.symbol = stringtable.add_string("");
	BEGIN 0;
	return STR_CONST;
}
%%