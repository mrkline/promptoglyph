DC = dmd

all: promptd

promptd: promptd.d
	$(DC) -wi -g -debug -of$@ $^

clean:
	rm -f promptd *.o

.PHONY: clean
