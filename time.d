import std.datetime : Clock, Duration;

/// Returns true if the program has been running for longer
/// than the given duration.
bool pastTime(Duration allottedTime)
{
	return cast(Duration)Clock.currAppTick > allottedTime;
}

