module promptd.vcs;

import std.getopt;
import std.datetime : msecs;
import std.stdio : write;

import color;
import git;
import help;

void main(string[] args)
{
	bool noColor;
	bool zsh;

	try {
		getopt(args,
			config.caseSensitive,
			config.bundling,
			"help|h", { writeAndSucceed(helpString); },
			"version|v", { writeAndSucceed(versionString); },
			"no-color", &noColor,
			"zsh|z", &zsh);
	}
	catch (GetOptException ex) {
		writeAndFail(ex.msg, "\n", helpString);
	}

	string vcsInfo = stringRepOfStatus(
		500.msecs,
		noColor ? UseColor.no : UseColor.yes,
		zsh ? ZshEscapes.yes : ZshEscapes.no);

	write(vcsInfo);
}

string versionString = q"EOS
promptd-vcs by Matt Kline, version 0.1
Part of the promptd tool set
EOS";

string helpString = q"EOS
usage: promptd [-s <length>]

Options:

  --help, -h
    Display this help text

  --version, -v
    Display the version info

  --no-color
    Disables colored output, which is on by default

  --zsh|z
    Used to emit additional escapes needed for color sequences in ZSH prompts.
    Ignored if --no-color is specified.
EOS";
