// Data structures used for reporting version control information.
// Currently only used by Git, but hopefully general enough for all (future)
// supported version control systems.

/// Information returned by invoking git status
struct StatusFlags {
	bool untracked; ///< Untracked files are present in the repo.
	bool modified; ///< Tracked files have been modified
	bool indexed; ///< Files are ready for commit
}

/// Status output plus the repository's HEAD
struct RepoStatus {
	StatusFlags flags; ///< See above
	string head; ///< The HEAD, or in more general VCS terms, the current branch
}
