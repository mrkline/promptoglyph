DC = dmd

all: promptd

promptd: promptd.d help.d git.d color.d
	$(DC) -wi -g -debug -of$@ $^

clean:
	rm -f promptd *.o

.PHONY: clean
