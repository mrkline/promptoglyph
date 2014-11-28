
all: promptd

promptd: *.d
	dmd -wi -debug -ofpromptd *.d

clean:
	rm promptd *.o

.PHONY: clean
