CC = g++
CFLAGS = -g -Wall -ansi -pedantic
OBJS = parser.tab.o lex.yy.o
BIN = parser

build: $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $(BIN)

lex.yy.o: lex.yy.c
	$(CC) $(CFLAGS) -c lex.yy.c -o lex.yy.o

lex.yy.c: lexer.l 
	flex lexer.l

parser.tab.o: parser.tab.c
	$(CC) $(CFLAGS) -c parser.tab.c -o parser.tab.o

parser.tab.c: parser.y
	bison -vd parser.y

clean:
	rm -f $(BIN) lex.yy.c lex.yy.o parser.tab.h parser.tab.c parser.tab.o parser.output

.PHONY: test
test: $(BIN)
	./parser < tests/program.txt
