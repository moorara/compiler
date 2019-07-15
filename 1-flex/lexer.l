%option noyywrap

%{
#include "helper.h"
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

"program"                { print_string_out(yytext, "PROGRAM_KW", "-"); }
"while"                  { print_string_out(yytext, "WHILE_KW", "-"); }
"for"                    { print_string_out(yytext, "FOR_KW", "-"); }
"if"                     { print_string_out(yytext, "IF_KW", "-"); }
"then"                   { print_string_out(yytext, "THEN_KW", "-"); }
"else"                   { print_string_out(yytext, "ELSE_KW", "-"); }
"switch"                 { print_string_out(yytext, "SWITCH_KW", "-"); }
"case"                   { print_string_out(yytext, "CASE_KW", "-"); }
"default"                { print_string_out(yytext, "DEFAULT_KW", "-"); }
"break"                  { print_string_out(yytext, "BREAK_KW", "-"); }
"continue"               { print_string_out(yytext, "CONTINUE_KW", "-"); }
"return"                 { print_string_out(yytext, "RETURN_KW", "-"); }
"integer"                { print_string_out(yytext, "INT_KW", "-"); }
"float"                  { print_string_out(yytext, "FLOAT_KW", "-"); }
"character"              { print_string_out(yytext, "CHAR_KW", "-"); }
"bool"                   { print_string_out(yytext, "BOOL_KW", "-"); }
"false"                  { print_string_out(yytext, "BOOL_CONSTANT", "0"); }
"true"                   { print_string_out(yytext, "BOOL_CONSTANT", "1"); }
"void"                   { print_string_out(yytext, "VOID_KW", "-"); }
"callout"                { print_string_out(yytext, "CALLOUT_KW", "-"); }
"read"                   { print_string_out(yytext, "READ_KW", "-"); }
"write"                  { print_string_out(yytext, "WRITE_KW", "-"); }
"=="                     { print_string_out(yytext, "EQ", "-"); }
"!="                     { print_string_out(yytext, "NE", "-"); }
"<"                      { print_string_out(yytext, "LT", "-"); }
"<="                     { print_string_out(yytext, "LE", "-"); }
">"                      { print_string_out(yytext, "GT", "-"); }
">="                     { print_string_out(yytext, "GE", "-"); }
"!"                      { print_string_out(yytext, "NOT", "-"); }
"+"                      { print_string_out(yytext, "PLUS", "-"); }
"-"                      { print_string_out(yytext, "MINUS", "-"); }
"*"                      { print_string_out(yytext, "MULT", "-"); }
"/"                      { print_string_out(yytext, "DIV", "-"); }
"%"                      { print_string_out(yytext, "REM", "-"); }
"&"                      { print_string_out(yytext, "AND", "-"); }
"&&"                     { print_string_out(yytext, "AND_THEN", "-"); }
"|"                      { print_string_out(yytext, "OR", "-"); }
"||"                     { print_string_out(yytext, "OR_ELSE", "-"); }
">>"                     { print_string_out(yytext, "SHR", "-"); }
"<<"                     { print_string_out(yytext, "SHL", "-"); }
"{"                      { print_string_out(yytext, "'{'", "-"); }
"}"                      { print_string_out(yytext, "'}'", "-"); }
"["                      { print_string_out(yytext, "'['", "-"); }
"]"                      { print_string_out(yytext, "']'", "-"); }
"("                      { print_string_out(yytext, "'('", "-"); }
")"                      { print_string_out(yytext, "')'", "-"); }
","                      { print_string_out(yytext, "','", "-"); }
";"                      { print_string_out(yytext, "';'", "-"); }
":"                      { print_string_out(yytext, "':'", "-"); }
"="                      { print_string_out(yytext, "'='", "-"); }
{IDENTIFIER}             { print_int_out(yytext, "ID", process_id(yytext)); }
{BINARY_NUMBER}          { print_uint_out(yytext, "INT_CONSTANT", process_binary(yytext)); }
{DECIMAL_NUMBER}         { print_uint_out(yytext, "INT_CONSTANT", process_decimal(yytext)); }
{HEXADECIMAL_NUMBER}     { print_uint_out(yytext, "INT_CONSTANT", process_hex(yytext)); }
{FLOAT_NUMBER}           { print_float_out(yytext, "FLOAT_CONSTANT", process_float(yytext)); }
{CHARACTER}              { print_string_out(yytext, "CHAR_CONSTANT", process_char(yytext)); }
{SIMPLE_STRING}          { print_string_out(yytext, "STRING_CONSTANT", process_simple_string(yytext)); }
{CONCAT_STRING}          { print_string_out(yytext, "STRING_CONSTANT", process_concat_string(yytext)); }
{SINGLE_LINE_COMMENT}    { print_string_out(yytext, "COMMENT_TEXT", process_single_comment(yytext)); }
{MULTI_LINE_COMMENT}     { print_string_out(yytext, "COMMENT_TEXT", process_multi_comment(yytext)); }
{WHITE_SPACE}            { }
{OTHER_CHAR}             { }

%%


int main(int argc, char* argv[]) {
    return yylex();
}
