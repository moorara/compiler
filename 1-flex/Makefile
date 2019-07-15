.PHONY: build
build: lex.yy.c lexer

.PHONY: lex.yy.c
lex.yy.c:
	flex lexer.l

.PHONY: lexer
lexer:
	g++ lex.yy.c -o lexer
	rm lex.yy.c

.PHONY: test
test:
	./lexer < testcase-1.txt
	./lexer < testcase-2.txt
