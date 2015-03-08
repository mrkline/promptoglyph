DC = dmd
DFLAGS = -wi -g

debug: DFLAGS += -debug
debug: all

release: DFLAGS += -O -release
release: all

all: promptd-path promptd-vcs

promptd-path: promptd-path.d help.d
	$(DC) $(DFLAGS) -of$@ $^

promptd-vcs: promptd-vcs.d help.d git.d color.d
	$(DC) $(DFLAGS) -of$@ $^

clean:
	rm -f promptd-path promptd-vcs *.o

.PHONY: clean
