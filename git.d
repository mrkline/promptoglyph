import std.algorithm;
import std.conv;
import std.exception;
import std.file;
import std.path;
import std.process;
import std.range;
import std.stdio;
import std.string;

import color;

struct RepoStatus {
	bool untracked;
	bool modified;
	bool indexed;
	string head;
};

string stringRepOfStatus(UseColor colors, ZshEscapes escapes)
{
	auto status = getRepoStatus();
	if (status is null)
		return "";

	// Local function that colors a source string if the colors flag is set.
	string colorText(string source,
	                 string function(ZshEscapes) colorFunction)
	{
		if (!colors)
			return source;
		else
			return colorFunction(escapes) ~ source;
	}

	// TODO: Abstract ANSI escape code magic.
	string head;

	if (!status.head.empty)
		head = colorText(status.head, &cyan);

	string flags = " ";

	if (status.indexed)
		flags ~= colorText("✔", &green);
	if (status.modified)
		flags ~= colorText("±", &yellow); // Yellow plus/minus
	if (status.untracked)
		flags ~= colorText("?", &red); // Red quesiton mark

	// We don't want an extra space if there's nothing to show.
	if (flags == " ")
		flags = "";

	return "[" ~ head ~ flags ~ colorText("]", &resetColor);
}

private:

RepoStatus* getRepoStatus()
{
	auto rootFinder = execute(["git", "rev-parse", "--show-toplevel"]);

	immutable repoRoot = rootFinder.output.strip();

	if (rootFinder.status != 0 || repoRoot.empty)
		return null;

	// Light off git status while we find the HEAD
	auto pipes = pipeProcess(["git", "status", "--porcelain"]);
	scope(failure) { kill(pipes.pid); wait(pipes.pid); }

	RepoStatus* ret = new RepoStatus;

	ret.head = repoRoot.getHead();

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
		if (set.canFind('?')) {
			ret.untracked = true;
		}
		else {
			// The second character indicates the working tree.
			// If it is not a blank or a question mark,
			// we have some un-indexed changes.
			if (set.back != ' ')
				ret.modified = true;

			// The first character indicates the index.
			// If it is not blank or a question mark,
			// we have some indexed changes.
			if (set.front != ' ')
				ret.indexed = true;
		}
	}

	enforce(wait(pipes.pid) == 0, "Git status failed.");

	return ret;
}

string getHead(string repoRoot)
{

	immutable headPath = buildPath(repoRoot, ".git", "HEAD");
	immutable headSHA = headPath.readAndStrip();

	// If we're on a branch head, .git/HEAD will look like
	// ref: refs/heads/<branch>
	if (headSHA.startsWith("ref:"))
		return headSHA.baseName;

	// Otherwise lets go rummaging through the refs to find something
	immutable refsPath = buildPath(repoRoot, ".git", "refs");

	// No need to check heads as we handled that case above.
	// Let's check remotes
	immutable remotesPath = buildPath(refsPath, "remotes");

	string ret = searchDirectoryForHead(remotesPath, headSHA);
	if (!ret.empty)
		return relativePath(ret, remotesPath);

	// We didn't find anything in remotes. Let's check tags.
	immutable tagsPath = buildPath(refsPath, "tags");
	ret = searchDirectoryForHead(tagsPath, headSHA);
	if (!ret.empty)
		return relativePath(ret, tagsPath);

	// We didn't find anything in remotes. Let's check packed-refs
	auto packedRefs = File(buildPath(repoRoot, ".git", "packed-refs"))
		.byLine
		.filter!(l => !l.startsWith('#'));

	foreach(line; packedRefs) {
		// Each line is in the form
		// <sha> <path>
		auto tokens = splitter(line);
		auto sha = tokens.front;
		tokens.popFront();
		auto refPath = tokens.front;
		tokens.popFront();
		// Line should be empty now
		enforce(tokens.empty, "Weird Git packed-refs remnant:\n" ~ tokens.to!string);

		if (sha == headSHA)
			return refPath.baseName.idup;
	}

	// Still nothing. Just return a shortened version of the HEAD sha
	return headSHA[0 .. 7];
}

// Utility functions for getHead

string readAndStrip(string path)
{
	return readText(path).strip();
}

bool isRefFile(ref DirEntry de)
{
	// We are ignoring remote HEADS.
	return de.isFile &&
		de.name.baseName != "HEAD";
}

string searchDirectoryForHead(string dir, string head)
{
	bool matchesHead(ref DirEntry de)
	{
		return de.name.readAndStrip() == head;
	}

	auto matchingRemotes = dirEntries(dir, SpanMode.depth, false)
		.filter!(f => isRefFile(f) && matchesHead(f));

	if (!matchingRemotes.empty)
		return matchingRemotes.front.name;
	else
		return "";
}
