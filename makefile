build: in.txt
	yacc -d ex.y
	lex ex.l
	g++ y.tab.c lex.yy.c -lfl
	./a.out < in.txt
clean:
	rm y.tab.* lex.yy.c a.out
