%option noyywrap

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

// Define A Simple Symbol Table
#define ST_LEN 1000
char* SYMBOL_TABLE[ST_LEN];
int ST_POINTER = 0;

char* CopyString(char* SourceString) {
    int Length = strlen(SourceString) + 1;
    char* Result = (char*)(malloc(Length));
    for (int i = 0; i < Length; i++)
        Result[i] = SourceString[i];
	Result[Length - 1] = 0;
	return Result;
}

char* SubString(char* SourceString, int Start, int Length) {
    int SourceLength = strlen(SourceString);
    if ((Start + Length) > SourceLength)
        return 0;
    char* Result = (char*)(malloc(Length + 1));
    for (int i = 0; i < Length; i++)
        Result[i] = SourceString[Start + i];
    Result[Length] = 0;
    return Result;
}

char* IntegerToString(unsigned int Number) {
    if (Number == 0) {
        char* ZeroResult = (char*)(malloc(2));
        ZeroResult[0] = '0';	//Zero Character
        ZeroResult[1] =  0;	//Null Character For End Of String
        return ZeroResult;
    }

    unsigned int TempNum = Number;
    int DigitsNumber = 0;
    while (TempNum !=0) {
        TempNum = TempNum / 10;
        DigitsNumber++;
    }

    int Digit = 0;
    char* Result = (char*)(malloc(DigitsNumber + 1));
    for (int i = (DigitsNumber - 1); i >= 0; i--) {
        Digit = Number % 10;
        Number = Number / 10;
        Result[i] = (char)(Digit + 48);
    }

    Result[DigitsNumber] = 0;
    return Result;
}

int ProcessIdentifier(char* Identifier) {
    for (int i = 0; i < ST_POINTER; i++)
        if (strcmp(SYMBOL_TABLE[i], Identifier) == 0)
            return	i;
    SYMBOL_TABLE[ST_POINTER++] = CopyString(Identifier);
    return (ST_POINTER - 1);
}

unsigned int ProcessBinary(char* BinaryLexeme) {
    int DigitsNumber = strlen(BinaryLexeme);
    unsigned int Result = 0;
    for (int i = 2; i < DigitsNumber; i++)
        Result = (Result * 2) + (int)(BinaryLexeme[i]) - 48;
    return Result;
}

unsigned int ProcessDecimal(char* DecimalLexeme) {
    int DigitsNumber = strlen(DecimalLexeme);
    unsigned int Result = 0;
    for (int i = 0; i < DigitsNumber; i++)
        Result = (Result * 10) + (int)(DecimalLexeme[i]) - 48;
    return Result;
}

unsigned int ProcessHexadecimal(char* HexadecimalLexeme) {
    int DigitsNumber = strlen(HexadecimalLexeme);
    unsigned int Result = 0;
    for (int i = 2; i < DigitsNumber; i++)
        if (HexadecimalLexeme[i] < '9')
            Result = (Result * 16) + (int)(HexadecimalLexeme[i]) - 48;
        else if (HexadecimalLexeme[i] < 'F')
            Result = (Result * 16) + (int)(HexadecimalLexeme[i]) - 55;
        else if (HexadecimalLexeme[i] < 'f')
            Result = (Result * 16) + (int)(HexadecimalLexeme[i]) - 87;
    return Result;
}

float ProcessFloat(char* FloatLexeme) {
    float Result = 0;
    int Length = strlen(FloatLexeme);
    int DotPos = -1, EPos = Length;
    for (int i = 0; i < Length; i++)
        if (FloatLexeme[i] == '.')
            DotPos = i;
        else if (FloatLexeme[i] == 'e')
            EPos = i;

    int Integer = 0;
    for (int i = 0; i < DotPos; i++)
        Integer = (Integer * 10) + (int)(FloatLexeme[i]) - 48;

    float NonInteger = 0;
    for (int i = (EPos - 1); i > DotPos; i--)
        NonInteger = (NonInteger / 10) + (int)(FloatLexeme[i]) - 48;
    NonInteger = NonInteger / 10;

    int Power = 0, Coefficient = 1;
    if (EPos < Length) {
        for (int i = (EPos + 1); i < Length; i++)
            if (FloatLexeme[i] == '+')
                Coefficient = 1;
            else if (FloatLexeme[i] == '-')
                Coefficient = -1;
            else
                Power = (Power * 10) + (int)(FloatLexeme[i]) - 48;
        Power = Coefficient * Power;
    }

    Result = (Integer + NonInteger) * pow(10, Power);
    return Result;
}

char* ProcessChar(char* CharacterLexeme) {
    int Length = strlen(CharacterLexeme) + 1;
    char* Result = SubString(CharacterLexeme, 1, Length - 2);
    return Result;
}

char* ProcessSimpleString(char* StringLexeme) {
    int Length = strlen(StringLexeme);
    char* Result = SubString(StringLexeme, 1, Length - 2);
    return Result;
}

char* ProcessConcatString(char* StringLexeme) {
    int Length = strlen(StringLexeme);
    int ResultLength = 0;
    bool Parity = true;
    for (int i = 1; i < Length; i++) {
        if ((StringLexeme[i - 1] != '\\') && (StringLexeme[i] == '\"'))
            Parity = !Parity;
        else if (Parity == true)
            ResultLength++;
    }

    char* Result = (char*)(malloc(ResultLength + 1));
    int j = 0;
    Parity = true;
    for (int i = 1; i < Length; i++) {
        if ((StringLexeme[i - 1] != '\\') && (StringLexeme[i] == '\"'))
            Parity = !Parity;
        else if (Parity == true)
            Result[j++] = StringLexeme[i];
    }

    Result[ResultLength] = 0;
    return Result;
}

char* ProcessSingleComment(char* CommentLexeme) {
    int Length = strlen(CommentLexeme);
    char* Result = SubString(CommentLexeme, 2, Length - 2);
    return Result;
}

char* ProcessMultiComment(char* CommentLexeme) {
    int Length = strlen(CommentLexeme);
    char* Result = SubString(CommentLexeme, 3, Length - 6);
    return Result;
}

void ProcessToken(char* Lexeme, const char* Token, const char* Attribute) {	
}
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

"program"                { printf("%s    %s    %s\n",  yytext,  "PROGRAM_KW",       "-"); }
"while"                  { printf("%s    %s    %s\n",  yytext,  "WHILE_KW",         "-"); }
"for"                    { printf("%s    %s    %s\n",  yytext,  "FOR_KW",           "-"); }
"if"                     { printf("%s    %s    %s\n",  yytext,  "IF_KW",            "-"); }
"then"                   { printf("%s    %s    %s\n",  yytext,  "THEN_KW",          "-"); }
"else"                   { printf("%s    %s    %s\n",  yytext,  "ELSE_KW",          "-"); }
"switch"                 { printf("%s    %s    %s\n",  yytext,  "SWITCH_KW",        "-"); }
"case"                   { printf("%s    %s    %s\n",  yytext,  "CASE_KW",          "-"); }
"default"                { printf("%s    %s    %s\n",  yytext,  "DEFAULT_KW",       "-"); }
"break"                  { printf("%s    %s    %s\n",  yytext,  "BREAK_KW",         "-"); }
"continue"               { printf("%s    %s    %s\n",  yytext, "CONTINUE_KW",       "-"); }
"return"                 { printf("%s    %s    %s\n",  yytext,  "RETURN_KW",        "-"); }
"integer"                { printf("%s    %s    %s\n",  yytext,  "INT_KW",           "-"); }
"float"                  { printf("%s    %s    %s\n",  yytext,  "FLOAT_KW",         "-"); }
"character"              { printf("%s    %s    %s\n",  yytext,  "CHAR_KW",          "-"); }
"bool"                   { printf("%s    %s    %s\n",  yytext,  "BOOL_KW",          "-"); }
"false"                  { printf("%s    %s    %s\n",  yytext,  "BOOL_CONSTANT",    "0"); }
"true"                   { printf("%s    %s    %s\n",  yytext,  "BOOL_CONSTANT",    "1"); }
"void"                   { printf("%s    %s    %s\n",  yytext,  "VOID_KW",          "-"); }
"callout"                { printf("%s    %s    %s\n",  yytext,  "CALLOUT_KW",       "-"); }
"read"                   { printf("%s    %s    %s\n",  yytext,  "READ_KW",          "-"); }
"write"                  { printf("%s    %s    %s\n",  yytext,  "WRITE_KW",         "-"); }
"=="                     { printf("%s    %s    %s\n",  yytext,  "EQ",               "-"); }
"!="                     { printf("%s    %s    %s\n",  yytext,  "NE",               "-"); }
"<"                      { printf("%s    %s    %s\n",  yytext,  "LT",               "-"); }
"<="                     { printf("%s    %s    %s\n",  yytext,  "LE",               "-"); }
">"                      { printf("%s    %s    %s\n",  yytext,  "GT",               "-"); }
">="                     { printf("%s    %s    %s\n",  yytext,  "GE",               "-"); }
"!"                      { printf("%s    %s    %s\n",  yytext,  "NOT",              "-"); }
"+"                      { printf("%s    %s    %s\n",  yytext,  "PLUS",             "-"); }
"-"                      { printf("%s    %s    %s\n",  yytext,  "MINUS",            "-"); }
"*"                      { printf("%s    %s    %s\n",  yytext,  "MULT",             "-"); }
"/"                      { printf("%s    %s    %s\n",  yytext,  "DIV",              "-"); }
"%"                      { printf("%s    %s    %s\n",  yytext,  "REM",              "-"); }
"&"                      { printf("%s    %s    %s\n",  yytext,  "AND",              "-"); }
"&&"                     { printf("%s    %s    %s\n",  yytext,  "AND_THEN",         "-"); }
"|"                      { printf("%s    %s    %s\n",  yytext,  "OR",               "-"); }
"||"                     { printf("%s    %s    %s\n",  yytext,  "OR_ELSE",          "-"); }
">>"                     { printf("%s    %s    %s\n",  yytext,  "SHR",              "-"); }
"<<"                     { printf("%s    %s    %s\n",  yytext,  "SHL",              "-"); }
"{"                      { printf("%s    %s    %s\n",  yytext,  "'{'",              "-"); }
"}"                      { printf("%s    %s    %s\n",  yytext,  "'}'",              "-"); }
"["                      { printf("%s    %s    %s\n",  yytext,  "'['",              "-"); }
"]"                      { printf("%s    %s    %s\n",  yytext,  "']'",              "-"); }
"("                      { printf("%s    %s    %s\n",  yytext,  "'('",              "-"); }
")"                      { printf("%s    %s    %s\n",  yytext,  "')'",              "-"); }
","                      { printf("%s    %s    %s\n",  yytext,  "','",              "-"); }
";"                      { printf("%s    %s    %s\n",  yytext,  "';'",              "-"); }
":"                      { printf("%s    %s    %s\n",  yytext,  "':'",              "-"); }
"="                      { printf("%s    %s    %s\n",  yytext,  "'='",              "-"); }
{IDENTIFIER}             { printf("%s    %s    %u\n",  yytext,  "ID",               ProcessIdentifier(yytext)); }
{BINARY_NUMBER}          { printf("%s    %s    %u\n",  yytext,  "INT_CONSTANT",     ProcessBinary(yytext)); }
{DECIMAL_NUMBER}         { printf("%s    %s    %u\n",  yytext,  "INT_CONSTANT",     ProcessDecimal(yytext)); }
{HEXADECIMAL_NUMBER}     { printf("%s    %s    %u\n",  yytext,  "INT_CONSTANT",     ProcessHexadecimal(yytext)); }
{FLOAT_NUMBER}           { printf("%s    %s    %f\n",  yytext,  "FLOAT_CONSTANT",   ProcessFloat(yytext)); }
{CHARACTER}              { printf("%s    %s    %s\n",  yytext,  "CHAR_CONSTANT",    ProcessChar(yytext)); }
{SIMPLE_STRING}          { printf("%s    %s    %s\n",  yytext,  "STRING_CONSTANT",  ProcessSimpleString(yytext)); }
{CONCAT_STRING}          { printf("%s    %s    %s\n",  yytext,  "STRING_CONSTANT",  ProcessConcatString(yytext)); }
{SINGLE_LINE_COMMENT}    { printf("%s    %s    %s\n",  yytext,  "COMMENT_TEXT",     ProcessSingleComment(yytext)); }
{MULTI_LINE_COMMENT}     { printf("%s    %s    %s\n",  yytext,  "COMMENT_TEXT",     ProcessMultiComment(yytext)); }
{WHITE_SPACE}            { }
{OTHER_CHAR}             { }

%%


int main(int argc, char* argv[]) {
    yylex();
}
