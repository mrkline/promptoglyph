module promptd.vcs;

import std.getopt;
import std.datetime : msecs;
import std.stdio : write;

import color;
import git;
import help;

void main(string[] args)
{
	uint timeLimit = 500;
	bool noColor;
	bool zsh;

	try {
		getopt(args,
			config.caseSensitive,
			config.bundling,
			"help|h", { writeAndSucceed(helpString); },
			"version|v", { writeAndSucceed(versionString); },
			"time-limit|t", &timeLimit,
			"no-color", &noColor,
			"zsh|z", &zsh);
	}
	catch (GetOptException ex) {
		writeAndFail(ex.msg, "\n", helpString);
	}

	string vcsInfo = stringRepOfStatus(
		timeLimit.msecs,
		noColor ? UseColor.no : UseColor.yes,
		zsh ? ZshEscapes.yes : ZshEscapes.no);

	write(vcsInfo);
}

string versionString = q"EOS
promptd-vcs by Matt Kline, version 0.2
Part of the promptd tool set
EOS";

string helpString = q"EOS
usage: promptd-vcs [-t <milliseconds>]

Options:

  --help, -h
    Display this help text

  --version, -v
    Display the version info

  --time-limit, t
    The maximum amount of time the program can run before exiting,
    in milliseconds. Defaults to 500 milliseconds.
    Running "git status" can take a long time for big or complex
    repositories, but since this program is for a prompt,
    we can't delay an arbitrary amount of time without annoying the user.
    If it takes longer than this amount of time to get the repo status,
    we prematurely kill "git status" and display whatever information
    was received so far. The hope is that in subsequent runs, "git status" will
    complete in time since your operating system caches recently-accessed
    files and directories.

  --no-color
    Disables colored output, which is on by default

  --zsh|z
    Used to emit additional escapes needed for color sequences in ZSH prompts.
    Ignored if --no-color is specified.

promptd-vcs is designed to be part of a shell prompt.
It prints a quick, glyph-based look at the status of a Git repository
if you are currently in one and nothing otherwise. Output looks like
    [master ✔±?]
where "master" is the current branch, ? indicates untracked files,
± indicates changed but unstaged files, and ✔ indicates files staged
in the index. If "git status" could not run in a timely manner to get this info
(see --time-limit above), a T is placed in front.
Future plans include configurable glyphs, additional info (like when merging),
and possibly Subversion and Mercurial support.
EOS";
