import std.typecons : Flag;

alias UseColor = Flag!"UseColor";

alias ZshEscapes = Flag!"ZshEscapes";

mixin(makeColorFunction("cyan", 36));
mixin(makeColorFunction("green", 32));
mixin(makeColorFunction("yellow", 33));
mixin(makeColorFunction("red", 31));
mixin(makeColorFunction("resetColor", 39));

private:

string makeColorFunction(string name, int code)
{
	import std.conv : to;
	return
	`
	string ` ~ name ~ `(ZshEscapes escapes)
	{
		string ret = "\33[` ~ code.to!string ~ `m";
		return escapes ? zshEscape(ret) : ret;
	}
	`;
}

string zshEscape(string code)
{
	return  "%{" ~ code ~ "%}";
}
