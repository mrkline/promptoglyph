# promptoglyph

## What the?

promptoglyph is a set of tools for shell prompts.
It currently has two parts:

- `promptoglyph-path`, which prints a [fish](http://fishshell.com/)-like shortening
  of your current directory.

- `promptoglyph-vcs`, which uses glyphs to give you a quick overview of your
  Git repository status.
  Unlike existing solutions such as the
  [vcs_info](http://zsh.sourceforge.net/Doc/Release/User-Contributions.html#Gathering-information-from-version-control-systems)
  plugin for Zsh or [oh-my-git](https://github.com/arialdomartini/oh-my-git),
  `promptoglyph-vcs` stops running after a user-specified amount of
  time so that fetching the status of your repo doesn't make your prompt laggy.

Together, you can use them to build a prompt like this:

![animated promptoglyph example](http://i.imgur.com/2xhoIus.gif)

More to follow.

## Why is it called promptoglyph?

It was originally called `promptd` because it is a *prompt* that gives the
current <em>d</em>irectory and is written in [D](http://dlang.org).
But someone made the valid point that the name implies a daemon,
so I went with promptoglyph.
Cheesy, but according to a cursory Google search, unique.

## How do I get it?

Linux builds can be found at the
[releases](https://github.com/mrkline/promptoglyph/releases) page.
They haven't been tested extensively across many distros,
but Probably Work™ since they only depend on vanilla C libraries
(pthread, libm, librt, libc).

Alternatively, building form source is simple.

## How do I build it?

Grab a [D compiler](http://dlang.org/download.html) and run `make release`.
That's all.
There are no dependencies.

promptoglyph will be added as a [Dub](http://code.dlang.org) package soon-ish.

## How do I use it for my prompt?

Just invoke the programs with the desired options (see their `--help` info)
in your prompt expression.

In Zsh (for the prompt shown in the demo):

```shell
setopt PROMPT_SUBST
setopt PROMPT_PERCENT
PROMPT='%B$(promptoglyph-path) $(promptoglyph-vcs --zsh) %%%b '
```

In Bash,

```shell
PS1="\$(promptoglyph-path) \$(promptoglyph-vcs --bash) % "
```

## It's 2015. Why are you generating a prompt with a compiled program?

I was using Zsh with [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh),
but it seemed to be really slow in some cases and someone on Reddit
[raised some concerns about it](http://www.reddit.com/r/programming/comments/pvbfp/zsh_a_bash_alternative_thats_easily_customizable/c3smc2d).
I could try [the fork](https://github.com/sorin-ionescu/prezto),
but I figured it wouldn't hurt to slim down my Zsh config
to things I actually use.
After doing that, all that remained was the need for a decent prompt.
I'm allergic to writing a shell script more than five lines long, 
and some of my goals (like hard time limits)
seemed easier in a "real" programming language instead of a Zsh script.
So, I started this project.

## What additions are planned?

- Support for additional VCSes, starting with SVN and Mercurial

- Additional Git info (such as the name of a branch being merged)

- Colorized path output

## License

zlib (Use it for whatever but don't claim you wrote it.)
See `LICENSE.md`
