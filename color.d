import std.typecons : Flag;

alias UseColor = Flag!"UseColor";

enum Escapes {
	none,
	bash,
	zsh
}

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
	string ` ~ name ~ `(Escapes escapes)
	{
		string ret = "\33[` ~ code.to!string ~ `m";
		final switch (escapes) {
			case Escapes.none:
				return ret;
			case Escapes.bash:
				return bashEscape(ret);
			case Escapes.zsh:
				return zshEscape(ret);
		}
	}
	`;
}

string zshEscape(string code)
{
	return  "%{" ~ code ~ "%}";
}

string bashEscape(string code)
{
	return `\[` ~ code ~ `\]`;
}
