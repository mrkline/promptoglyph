// Explicitly specify what we're importing from each module.
// I don't usually do this, but the argument for it is that
// it makes it easier to keep track of what each import is here for.
import std.algorithm : map, startsWith;
import std.array : array;
import std.exception : ifThrown;
import std.file : getcwd;
import std.path : pathSplitter, buildPath;
import std.process : environment;
import std.stdio : write;
import std.traits : isSomeString;

void main(string[] args)
{
	immutable string home = environment["HOME"].ifThrown(string.init);
	immutable string cwd = getcwd();

	string prompt = homeToTilde(cwd, home);

	// TODO: Add option to shorten at a certain length, or not at all?
	prompt = shorten(prompt);

	write(prompt);
}

// TODO: Parse /etc/passwd so that this works with other users'
//       home directories as well.
pure string homeToTilde(string cwd, string home)
{
	if (cwd.startsWith(home))
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

// Takes a string and returns its first character,
// as a string
pure auto firstOf(S)(S s) if (isSomeString!S)
in
{
	assert(s.length > 0);
}
body
{
	return [s[0]];
}
