// Explicitly specify what we're importing from each module.
// I don't usually do this, but the argument for it is that
// it makes it easier to keep track of what each import is here for.
// It's similar to Python's "from x import y"
import std.algorithm : map, startsWith, take;
import std.array : array;
import std.conv : to;
import std.exception : ifThrown;
import std.file : getcwd;
import std.getopt;
import std.path : pathSplitter, buildPath;
import std.process : environment;
import std.range : empty;
import std.stdio : write, writeln;
import std.traits : isSomeString;
import std.utf : count, stride;

import std.c.stdlib : exit;

import git;

void main(string[] args)
{
	int shortenAt = 0;

	getopt(args, config.caseSensitive,
		"help|h", { writeln(helpString); exit(0); },
		"version|v", { writeln(versionString); exit(0); },
		"shorten-at-length|s", &shortenAt);

	immutable string home = environment["HOME"].ifThrown("");
	immutable string cwd = getcwd().ifThrown("???");

	string prompt = homeToTilde(cwd, home);

	if (prompt.count >= shortenAt)
		prompt = shorten(prompt);

	write(prompt, " ", stringRepOfStatus(getRepoStatus()));
}

string versionString = q"EOS
promptd by Matt Kline, version 0.1
EOS";

string helpString = q"EOS
usage: promptd [-s <length>]

Options:

  --help, -h
    Display this help text

  --version, -v
    Display the version info

  --shorten-at-length, -s <length>
    Shorten the path if it exceeds <length>.
    Defaults to 0 (always shorten)
EOS";

// TODO: Parse /etc/passwd so that this works with other users'
//       home directories as well.
pure string homeToTilde(string cwd, string home)
{
	if (!home.empty && cwd.startsWith(home))
		return "~" ~ cwd[home.length .. $];
	else
		return cwd;
}

pure string shorten(string path)
{
	auto pathTokens = pathSplitter(path).array;

	if (pathTokens.length < 2)
		return path;

	// We never shorten the last part of the path
	auto last = pathTokens[$-1];
	auto rest = pathTokens[0 .. $-1];

	// If we have a home directory at the start, don't shorten that.
	if (rest[0].startsWith("~"))
		rest = rest[0] ~ rest[1 .. $].map!(s => firstOf(s)).array;
	else
		rest = rest.map!(s => firstOf(s)).array;

	return buildPath(rest ~ last);
}

unittest
{
	assert(shorten("foo") == "foo");
	assert(shorten("/foo/bar/baz") == "/f/b/baz");
	assert(shorten("~foo/bar/baz") == "~foo/b/baz");
}

// Takes a string and returns its first character,
// as a string
pure auto firstOf(S)(S s) if (isSomeString!S)
in
{
	assert(!s.empty);
}
body
{
	// We use take so that this plays nicely
	// with non-ASCII file names.
	return s.take(1).to!S;
}

unittest
{
	assert(firstOf("ASCII") == "A");
	assert(firstOf("漢字") == "漢");
}
