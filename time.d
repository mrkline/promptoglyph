import core.time : MonoTime;
import std.datetime : Duration;

private MonoTime start;

void markProgramStart()
{
	start = MonoTime.currTime;
}

/// Returns true if the program has been running for longer
/// than the given duration.
bool pastTime(Duration allottedTime)
{
	return MonoTime.currTime - start > allottedTime;
}

