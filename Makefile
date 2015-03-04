DC = dmd

all: promptd

promptd: promptd.d help.d git.d
	$(DC) -wi -g -debug -of$@ $^

clean:
	rm -f promptd *.o

.PHONY: clean
