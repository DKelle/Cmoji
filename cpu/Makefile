VFILES=$(wildcard *.v)

cpu : $(VFILES) Makefile
	iverilog -o cpu $(VFILES)

clean :
	rm -rf cpu testing/mem.hex testing/test.ok

test : $(sort $(patsubst testing/%.ok,%,$(wildcard testing/test?.ok)))

test% : cpu testing/mem%.hex
	@echo -n "test$* ... "
	@cp testing/mem$*.hex testing/mem.hex
	@cp testing/test$*.ok testing/test.ok
	@timeout 10 ./cpu > testing/test.raw 2>&1
	-@egrep "^#" testing/test.raw > testing/test.out
	-@egrep "^@" testing/test.raw > testing/test.cycles
	@((diff -b testing/test.out testing/test.ok > /dev/null 2>&1) && echo "pass `cat testing/test.cycles`") || (echo "fail" ; echo "\n\n----------- expected ----------"; cat testing/test.ok ; echo "\n\n------------- found ----------"; cat testing/test.out)

printtest : 
	@cp testing/memprint.hex testing/mem.hex
	@cp testing/testprint.ok testing/test.ok
	@timeout 10 ./cpu > testing/test.raw 2>&1
	-@egrep "^#" testing/test.raw | sed 's/^.//' > testing/test.out
	-@egrep "^@" testing/test.raw > testing/test.cycles
	@cat testing/test.out
