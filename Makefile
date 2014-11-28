
all: promptd

promptd: promptd.d
	dmd -wi -debug -of$@ $^

clean:
	rm promptd *.o

.PHONY: clean
