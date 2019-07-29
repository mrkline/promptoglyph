import std.algorithm : canFind, count, filter, splitter;
import std.conv : to;
import std.datetime : Duration;
import std.exception : enforce;
import std.file;
import std.path : baseName, buildPath, relativePath;
import std.process; // : A whole lotta stuff
import std.range : empty, front, back;
import std.stdio : File;
import std.string : startsWith, strip, chompPrefix;
import std.array : split;

import core.stdc.stdio : fileno;

import time;
import vcs;

// Fetches information about the Git repository,
// or returns null if we are not in one.
RepoStatus* getRepoStatus()
{
	import std.parallelism;

	// This should give us the root directory of the Git repo
	auto rootFinder = execute(["git", "rev-parse", "--show-toplevel"]);

	immutable repoRoot = rootFinder.output.strip();

	if (rootFinder.status != 0 || repoRoot.empty)
		return null;

	RepoStatus* ret = new RepoStatus;

	ret.head = getHead(repoRoot);

	ret.flags = getFlags();

	return ret;
}


private:

StatusFlags getFlags()
{
	StatusFlags ret;

	// Local function for processing the output of git status.
	// See the docs for git status porcelain output
	void processPorcelainLine(const char[] line)
	{
		if (line is null)
			return;

		// git status --porcelain spits out a two-character code
		// for each file that would show up in Git status
		const char[] set = line[0 .. 2];

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

	// Light off git status while we find the HEAD
	auto pipes = pipeProcess(["git", "status", "--porcelain"], Redirect.stdout);
	scope (failure) {
		kill(pipes.pid);
	}
	scope (exit) {
		wait(pipes.pid);
	}

	foreach (line; pipes.stdout.byLine) processPorcelainLine(line);

	return ret;
}

/// Gets the name of the current Git head, or a shortened SHA
/// if there is no symbolic name.
string getHead(string repoRoot)
{
	// NOTE(dkg): added check to allow for git submodules
	// check if the .git file/folder is actually a folder
	// if it is a file, we are in a submodule
	immutable gitFileOrFolder = buildPath(repoRoot, ".git");
	if (exists(gitFileOrFolder) && isFile(gitFileOrFolder)) {
		string content = gitFileOrFolder.readAndStrip();
		//Example content: gitdir: ../.git/modules/modulename
		string[] contentSplit = split(content, "/");
		if (contentSplit.length > 0) {
			return "sub: " ~ (contentSplit[$-1]);
		}
		else {
			return "<an unknown submodule>";
		}
	}

	immutable headPath = buildPath(repoRoot, ".git", "HEAD");
	immutable headSHA = headPath.readAndStrip();

	// If we're on a branch head, .git/HEAD will look like
	// ref: refs/heads/<branch>
	if (headSHA.startsWith("ref:")) {
		if (headSHA.count("/") == 2)
			return headSHA.baseName;
		else
			return headSHA.chompPrefix("ref: refs/heads/");
	}

	// Otherwise let's go rummaging through the refs to find something
	immutable refsPath = buildPath(repoRoot, ".git", "refs");

	string ret;

	// Let's check tags next
	immutable tagsPath = buildPath(refsPath, "tags");
	ret = searchTagsForHead(tagsPath, headSHA);
	if (!ret.empty)
		return relativePath(ret, tagsPath);

	// No need to check heads as we handled that case above.
	// Let's check remotes
	immutable remotesPath = buildPath(refsPath, "remotes");
	ret = searchDirectoryForHead(remotesPath, headSHA);
	if (!ret.empty)
		return relativePath(ret, remotesPath);

	// We didn't find anything in remotes. Let's check packed-refs
	immutable packedRefsPath = buildPath(repoRoot, ".git", "packed-refs");
	if (exists(packedRefsPath)) {
		auto packedRefs = File(packedRefsPath)
			.byLine
			.filter!(l => !l.startsWith('#'))
			.filter!(l => !l.startsWith('^'));

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
	}

	// Still nothing. Just return a shortened version of the HEAD SHA
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
    if (!dir.exists() || !dir.isDir())
        return "";

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

string searchTagsForHead(string dir, string head)
{
	bool matchesHead(ref DirEntry de)
	{
		// Tags are a special case. They can either point
		// to the tagged commit, or to an annotated tag.
		// We will use git rev-parse to extract the commit
		// either way.
		string revParseArg = de.name.readAndStrip() ~ "^{commit}";
		auto execResult = execute(["git", "rev-parse", revParseArg]);

		// In some really rare and weird cases,
		// there's some standalone tree objects that make the command fall over.
		// For an example, see 5dc01c595e6c6ec9ccda4f6f69c131c0dd945f8c in
		// the Linux kernel.
		if (execResult.status != 0) return false;

		string pointsTo = execResult.output.strip();
		return pointsTo == head;
	}

	auto matchingRemotes = dirEntries(dir, SpanMode.depth, false)
		.filter!(f => isRefFile(f) && matchesHead(f));

	if (!matchingRemotes.empty)
		return matchingRemotes.front.name;
	else
		return "";
}
