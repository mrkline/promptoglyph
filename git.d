import std.algorithm;
import std.conv;
import std.exception;
import std.process;
import std.range;

struct Flags {
	bool untracked;
	bool modified;
	bool indexed;
};

Flags* getRepoStatus()
{
	auto pipes = pipeProcess(["git", "status", "--porcelain"]);
	scope(failure) { kill(pipes.pid); wait(pipes.pid); }

	Flags fl;

	// See the docs for git status porcelain output
	auto statusChars = pipes.stdout
		.byLine
		// Why is this .array needed? Check odd set.back error below
		.map!(l => l.takeExactly(2).array); // Take the first two chars


	foreach (set; statusChars) {
		// git status --porcelain spits out a two-character code
		// for each file that would show up in Git status
		enforce(set.length == 2, "Unexpected Git output:" ~ set.to!string);

		// Question marks indicate a file is untracked.
		if (set.canFind('?'))
		{
			fl.untracked = true;
		}
		else
		{
			// The second character indicates the working tree.
			// If it is not a blank or a question mark,
			// we have some un-indexed changes.
			if (set.back != ' ')
				fl.modified = true;

			// The first character indicates the index.
			// If it is not blank or a question mark,
			// we have some indexed changes.
			if (set.front != ' ')
				fl.indexed = true;
		}
	}

	if (wait(pipes.pid) != 0) {
		return null;
	}
	else {
		Flags* ret = new Flags;
		*ret = fl;
		return ret;
	}
}

string stringRepOfStatus(const Flags* status)
{
	if (status is null)
		return "";

	// TODO: Abstract ANSI escape code magic.
	string ret;
	if (status.indexed)
		ret ~= "\33[32m✔"; // Green check
	if (status.modified)
		ret ~= "\33[33m±"; // Yellow plus/minus
	if (status.untracked)
		ret ~= "\33[31m?"; // Red quesiton mark

	return "[" ~ ret ~ "\33[39m]";
}
