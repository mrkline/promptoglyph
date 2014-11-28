# promptd

## What the?

promptd generates a shell prompt.
Right now it is really dumb and will just print a
[fish](http://fishshell.com/)-like shortening of your current directory.
More to follow.

## Why is it called promptd?

It's a prompt written in [D](http://dlang.org) and I am bad at names.

## It's 2014. Why are you generating a prompt with a compiled program?

I was using zsh with [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh)
but it seemed to be really slow in some cases and someone on Reddit
[suggested not using it](http://www.reddit.com/r/programming/comments/pvbfp/zsh_a_bash_alternative_thats_easily_customizable/c3smc2d).
I could try [the fork](https://github.com/sorin-ionescu/prezto),
but I figured it wouldn't hurt to slim down my zsh config
to things I actually use.
After doing that, all that remained was having a decent prompt.
I wanted something like what fish offers, and since I'm allergic
to writing a shell script more than five lines long
([ew](http://www.zsh.org/mla/workers/2009/msg00415.html))
I bashed something out in D.
Similarly, the things I want to add to the prompt seem easier in a "real"
programming language instead of a zsh script.

## What are you going to add?

- [ ] Colors
- [ ] Git integration like oh-my-zsh
- [ ] Subverison integration like oh-my-zsh
- [ ] Possibly some command line options
      (though it's equally arguable that it would be cleaner
       to just change the source and recompile for such a small program)

## License

See `LICENSE.md`
