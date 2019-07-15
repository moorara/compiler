%option noyywrap

%{
#include "helper.h"
#include "parser.tab.h"
%}


DIGIT               ([0-9])
NON_ZERO            ([1-9])
LETTER              ([A-Za-z])
LETTER_DIGIT        ([0-9A-Za-z])
BLANK               ([ ])
DELIM               ([ \t\n\r])
WHITE_SPACE         ({DELIM}+)
OTHER_CHAR          (.)
IDENTIFIER          (({LETTER}({LETTER}{LETTER})*)("_"{LETTER}+({DIGIT}({LETTER}{2,5}{DIGIT})?)?{LETTER}*)?)
BINARY_NUMBER       ("0b1"[01]*)
DECIMAL_NUMBER      ("0"|[1-9][0-9]*)
HEXADECIMAL_NUMBER  ("0x"[1-9A-Fa-f][0-9A-Fa-f]*)
FLOAT_NUMBER        (("0"|{DECIMAL_NUMBER})"."("0"|[0-9]*[1-9])("e"[-+]?{DECIMAL_NUMBER})?)
CHAR                ([\x20\x21\x23-\x26\x28-\x5B\x5D-\x7E\x80-\xFF]|("\\"[bnt'"\\]))
CHARACTER           (\'{CHAR}\')
SIMPLE_STRING       (\"{CHAR}*\")
CONCAT_STRING       (\"{CHAR}*\"({DELIM}*"+"{DELIM}*\"{CHAR}*\")+)
STRING              (\"({CHAR}*(\"{DELIM}*"+"{DELIM}*\")?{CHAR}*)*\")
SINGLE_LINE_COMMENT ("//"[\x20-\x7E\x80-\xFF]*)
MULTI_LINE_COMMENT  ("%%%"(("%"|"%%")?[^%]+)*"%%%")

%%

"program"                { yylval.str_val = "-"; return PROGRAM_KW; }
"while"                  { yylval.str_val = "-"; return WHILE_KW; }
"for"                    { yylval.str_val = "-"; return FOR_KW; }
"if"                     { yylval.str_val = "-"; return IF_KW; }
"then"                   { yylval.str_val = "-"; return THEN_KW; }
"else"                   { yylval.str_val = "-"; return ELSE_KW; }
"switch"                 { yylval.str_val = "-"; return SWITCH_KW; }
"case"                   { yylval.str_val = "-"; return CASE_KW; }
"default"                { yylval.str_val = "-"; return DEFAULT_KW; }
"break"                  { yylval.str_val = "-"; return BREAK_KW; }
"continue"               { yylval.str_val = "-"; return CONTINUE_KW; }
"return"                 { yylval.str_val = "-"; return RETURN_KW; }
"integer"                { yylval.str_val = "-"; return INT_KW; }
"float"                  { yylval.str_val = "-"; return FLOAT_KW; }
"character"              { yylval.str_val = "-"; return CHAR_KW; }
"bool"                   { yylval.str_val = "-"; return BOOL_KW; }
"false"                  { yylval.str_val = "0"; return BOOL_CONSTANT; }
"true"                   { yylval.str_val = "1"; return BOOL_CONSTANT; }
"void"                   { yylval.str_val = "-"; return VOID_KW; }
"callout"                { yylval.str_val = "-"; return CALLOUT_KW; }
"read"                   { yylval.str_val = "-"; return READ_KW; }
"write"                  { yylval.str_val = "-"; return WRITE_KW; }
"=="                     { yylval.str_val = "-"; return EQ; }
"!="                     { yylval.str_val = "-"; return NE; }
"<"                      { yylval.str_val = "-"; return LT; }
"<="                     { yylval.str_val = "-"; return LE; }
">"                      { yylval.str_val = "-"; return GT; }
">="                     { yylval.str_val = "-"; return GE; }
"!"                      { yylval.str_val = "-"; return NOT; }
"+"                      { yylval.str_val = "-"; return PLUS; }
"-"                      { yylval.str_val = "-"; return MINUS; }
"*"                      { yylval.str_val = "-"; return MULT; }
"/"                      { yylval.str_val = "-"; return DIV; }
"%"                      { yylval.str_val = "-"; return REM; }
"&"                      { yylval.str_val = "-"; return AND; }
"&&"                     { yylval.str_val = "-"; return AND_THEN; }
"|"                      { yylval.str_val = "-"; return OR; }
"||"                     { yylval.str_val = "-"; return OR_ELSE; }
">>"                     { yylval.str_val = "-"; return SHR; }
"<<"                     { yylval.str_val = "-"; return SHL; }
"{"                      { yylval.str_val = "-"; return '{'; }
"}"                      { yylval.str_val = "-"; return '}'; }
"["                      { yylval.str_val = "-"; return '['; }
"]"                      { yylval.str_val = "-"; return ']'; }
"("                      { yylval.str_val = "-"; return '('; }
")"                      { yylval.str_val = "-"; return ')'; }
","                      { yylval.str_val = "-"; return ','; }
";"                      { yylval.str_val = "-"; return ';'; }
":"                      { yylval.str_val = "-"; return ':'; }
"="                      { yylval.str_val = "-"; return '='; }
{IDENTIFIER}             { yylval.int_val = process_id(yytext); return ID; }
{BINARY_NUMBER}          { yylval.uint_val = process_binary(yytext); return INT_CONSTANT; }
{DECIMAL_NUMBER}         { yylval.uint_val = process_decimal(yytext); return INT_CONSTANT; }
{HEXADECIMAL_NUMBER}     { yylval.uint_val = process_hex(yytext); return INT_CONSTANT; }
{FLOAT_NUMBER}           { yylval.float_val = process_float(yytext); return FLOAT_CONSTANT; }
{CHARACTER}              { yylval.str_val = process_char(yytext); return CHAR_CONSTANT; }
{SIMPLE_STRING}          { yylval.str_val = process_simple_string(yytext); return STRING_CONSTANT; }
{CONCAT_STRING}          { yylval.str_val = process_concat_string(yytext); return STRING_CONSTANT; }
{SINGLE_LINE_COMMENT}    { }
{MULTI_LINE_COMMENT}     { }
{WHITE_SPACE}            { }
{OTHER_CHAR}             { }

%%
