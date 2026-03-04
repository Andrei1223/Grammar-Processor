build:
	flex parser.l && g++ -std=c++11 -o parser lex.yy.c -ll

clean:
	rm lex.yy.c parser
