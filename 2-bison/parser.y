%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex(void);

void yyerror(const char* msg) {
    printf("\033[1;31mERROR:  %s\033[1;0m\n", msg);
}
%}

%union{
    char*         str_val;
    int           int_val;
    unsigned int  uint_val;
    float         float_val;
}

%token  PROGRAM_KW
%token  WHILE_KW FOR_KW
%token  IF_KW THEN_KW ELSE_KW
%token  SWITCH_KW CASE_KW DEFAULT_KW
%token  BREAK_KW CONTINUE_KW RETURN_KW
%token  INT_KW FLOAT_KW CHAR_KW BOOL_KW
%token  VOID_KW CALLOUT_KW
%token  READ_KW WRITE_KW
%token  EQ NE LT LE GT GE NOT
%token  PLUS MINUS MULT DIV REM
%token  AND AND_THEN OR OR_ELSE SHR SHL
%token  ID
%token  BOOL_CONSTANT INT_CONSTANT FLOAT_CONSTANT CHAR_CONSTANT STRING_CONSTANT

%left   ','
%right  '='
%left   OR_ELSE
%left   AND_THEN
%left   OR
%left   AND
%left   EQ NE
%left   LT LE GT GE
%left   SHR SHL
%left   PLUS MINUS
%left   MULT DIV REM
%right  NOT
%left   '[' ']'
%left   '(' ')'

%nonassoc  IFX
%nonassoc  ELSE_KW

%%

program                 :  PROGRAM_KW ID '{' field_decl_list_block method_decl_list '}' {} ;
field_decl_list_block   :  '{' field_decl_list '}' {} ;
field_decl_list         :  field_decl field_decl_list {}
                        |  /*lambda*/ {} ;
field_decl              :  type field_name_list ';' {} ;
field_name_list         :  field_name ',' field_name_list {}
                        |  field_name {} ;
field_name              :  ID '[' INT_CONSTANT ']' {}
                        |  ID {} ;
method_decl_list        :  method_decl method_decl_list {}
                        |  /*lambda*/ {} ;
method_decl             :  return_type ID '(' formal_parameter_list ')' block {} ;
method_call             :  ID '(' actual_parameters ')' {}
                        |  CALLOUT_KW '(' STRING_CONSTANT callout_parameters ')' {} ;
actual_parameters       :  actual_parameter_list {}
                        |  /*lambda*/ {} ;
actual_parameter_list   :  expr ',' actual_parameter_list {}
                        |  expr {} ;
callout_parameters      :  ',' callout_parameter_list {}
                        |  /*lambda*/ {} ;
callout_parameter_list  :  expr ',' callout_parameter_list {}
                        |  expr {} ;
formal_parameter_list   :  argumant_list {}
                        |  /*lambda*/ {} ;
argumant_list           :  type ID ',' argumant_list {}
                        |  type ID {} ;
type                    :  INT_KW {}
                        |  FLOAT_KW {}
                        |  CHAR_KW {}
                        |  BOOL_KW {} ;
constant                :  INT_CONSTANT {}
                        |  FLOAT_CONSTANT {}
                        |  CHAR_CONSTANT {}
                        |  BOOL_CONSTANT {} ;
return_type             :  type {}
                        |  VOID_KW {} ;
return_expr             :  expr {}
                        |  /*lambda*/ {} ;
block                   :  '{' var_decl_list statement_list '}' {} ;
var_decl_list           :  var_decl var_decl_list {}
                        |  /*lambda*/ {} ;
var_decl                :  type id_list ';' {} ;
id_list                 :  ID ',' id_list {}
                        |  ID {} ;
statement_list          :  statement statement_list {}
                        |  /*lambda*/ {} ;
statement               :  assignment ';' {}
                        |  method_call ';' {}
                        |  IF_KW '(' expr ')' THEN_KW block ';' {}
                        |  IF_KW '(' expr ')' THEN_KW block ELSE_KW block ';' {}
                        |  WHILE_KW '(' expr ')' block ';' {}
                        |  FOR_KW '(' for_initialize ';' expr ';' assignment ')' block ';' {}
                        |  SWITCH_KW '(' ID ')' '{' case_statements '}' ';' {}
                        |  RETURN_KW return_expr ';' {}
                        |  BREAK_KW ';' {}
                        |  CONTINUE_KW ';' {}
                        |  block {}
                        |  READ_KW '(' ID ')' ';' {}
                        |  WRITE_KW '(' write_parameter ')' ';' {}
                        |  ';' {} ;
case_statements         :  CASE_KW constant ':' statement case_statements {}
                        |  DEFAULT_KW ':' statement {}
                        |  /*lambda*/ {} ;
write_parameter         :  expr {}
                        |  STRING_CONSTANT {} ;
assignment              :  location '=' expr {}
                        |  location {} ;
for_initialize          :  assignment {}
                        |  /*lambda*/ {} ;
location                :  ID {}
                        |  ID '[' expr ']' {} ;
expr                    :  location {}
                        |  constant {}
                        |  '(' expr ')' {}
                        |  method_call {}
                        |  operational_expr {} ;
operational_expr        :  expr LT expr {}
                        |  expr LE expr {}
                        |  expr GT expr {}
                        |  expr GE expr {}
                        |  expr EQ expr {}
                        |  expr NE expr {}
                        |  expr AND expr {}
                        |  expr OR expr {}
                        |  expr AND_THEN expr {}
                        |  expr OR_ELSE expr {}
                        |  expr PLUS expr {}
                        |  expr MINUS expr {}
                        |  expr MULT expr {}
                        |  expr DIV expr {}
                        |  expr REM expr {}
                        |  SHR expr {}
                        |  SHL expr {}
                        |  MINUS expr {}
                        |  NOT expr {} ;

%%


int main(int argc, char* argv[]) {
    return yyparse();
}
