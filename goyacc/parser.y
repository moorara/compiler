%{
package goyacc

func setResult(l yyLexer, root *node) {
	l.(*lexer).ast = &ast{
    root: root,
  }
}
%}

%union{
  op    string
  label string
  node  *node
}

%token OPEN
%token CLOSE
%token <op> OP
%token <label> LABEL

%type <node> formula
%type <node> expr

%left OP

%start formula

%%

formula:
  OPEN expr CLOSE {
    setResult(yylex, $2)
  }

expr:
  LABEL {
    $$ = &node{typ: label, val: $1}
  }
  | OPEN expr CLOSE {
    $$ = $2
  }
  | expr OP expr {
    $$ = &node{typ: op, val: $2, left: $1, right: $3}
  }
