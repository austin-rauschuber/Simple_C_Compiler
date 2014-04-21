
all: scc tests

scc: simple.l simple.y
	lex simple.l
	yacc -d simple.y
	gcc -g -o scc lex.yy.c y.tab.c

run-test1:
	@rm -f *.out && \
	scc test1.c && \
	gcc -o test1.scc test1.s && \
	gcc -w -o test1.gcc test1.c && \
	(./test1.scc > scc.out;	./test1.gcc > gcc.out; echo) && \
	diff scc.out gcc.out && echo "test1 passed..." || \
	(echo "test1 failed..." && \
	 echo ---------scc.out----- && \
	 cat scc.out && \
	 echo ---------gcc.out----- && \
	cat scc.out \
	)

run-test2:
	@rm -f *.out && \
	scc test2.c && \
	gcc -o test2.scc test2.s && \
	gcc -w -o test2.gcc test2.c && \
	(./test2.scc > scc.out;	./test2.gcc > gcc.out; echo) && \
	diff scc.out gcc.out && echo "test2 passed..." || \
	(echo "test2 failed..." && \
	 echo ---------scc.out----- && \
	 cat scc.out && \
	 echo ---------gcc.out----- && \
	cat scc.out \
	)

run-test3:
	@rm -f *.out && \
	scc test3.c && \
	gcc -o test3.scc test3.s && \
	gcc -w -o test3.gcc test3.c && \
	(./test3.scc > scc.out;	./test3.gcc > gcc.out; echo) && \
	diff scc.out gcc.out && echo "test3 passed..." || \
	(echo "test3 failed..." && \
	 echo ---------scc.out----- && \
	 cat scc.out && \
	 echo ---------gcc.out----- && \
	cat scc.out \
	)

run-test4:
	@rm -f *.out && \
	scc test4.c && \
	gcc -o test4.scc test4.s && \
	gcc -w -o test4.gcc test4.c && \
	(./test4.scc > scc.out;	./test4.gcc > gcc.out; echo) && \
	diff scc.out gcc.out && echo "test4 passed..." || \
	(echo "test4 failed..." && \
	 echo ---------scc.out----- && \
	 cat scc.out && \
	 echo ---------gcc.out----- && \
	cat scc.out \
	)

tests: run-test1 run-test2 run-test3 

clean:
	rm -f scc lex.yy.c y.tab.c y.tab.h *.out *.s *.scc *.gcc tests/*.out tests/*.s tests/*.scc tests/*.gcc test1 test2 test3 test4 test5

