DC = dmd
DFLAGS = -wi -g

debug: DFLAGS += -debug
debug: all

release: DFLAGS += -O -release
release: all

all: promptd-path promptd-vcs

package: clean release
	mkdir promptd
	cp promptd-path promptd-vcs promptd
	tar cf promptd.tar promptd
	gzip -f9 promptd.tar
	rm -r promptd

promptd-path: promptd-path.d help.d
	$(DC) $(DFLAGS) -of$@ $^

promptd-vcs: promptd-vcs.d help.d vcs.d time.d color.d git.d
	$(DC) $(DFLAGS) -of$@ $^

clean:
	rm -f promptd-path promptd-vcs *.o

.PHONY: clean debug release all package
