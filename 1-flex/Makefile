CC = g++
CFLAGS = -g -Wall -ansi -pedantic
OBJS = lex.yy.o
BIN = lexer

build: $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $(BIN)

lex.yy.o: lex.yy.c
	$(CC) $(CFLAGS) -c lex.yy.c -o lex.yy.o

lex.yy.c: lexer.l 
	flex lexer.l

clean:
	rm -f $(BIN) $(OBJS) lex.yy.c

.PHONY: test
test: $(BIN)
	./lexer < tests/testcase-1.txt
	./lexer < tests/testcase-2.txt
