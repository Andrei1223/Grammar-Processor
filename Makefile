# Timofte_Andrei-Ioan_335CC 

build:
	flex main.l && g++ -std=c++11 -o main lex.yy.c -ll

run:
	./main

clean:
	rm lex.yy.c main
