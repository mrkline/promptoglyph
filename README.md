# promptd

## What the?

promptd generates a shell prompt (or part of it).
Right now it prints a [fish](http://fishshell.com/)-like shortening
of your current directory.
More to follow.

## Why is it called promptd?

It's a prompt that gives the current _d_irectory.
Or it's a prompt written in [D](http://dlang.org).
Take your pick.

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
I [bashed](http://http://instantrimshot.com/) something out in D.
Similarly, the things I might add to the prompt seem easier in a "real"
programming language instead of a zsh script.

Yeah, it's pretty dumb to have your prompt setup be a compiled program
because then you have to recompile it to make tweaks and
you can't just download it and go.
But this is pretty much just for my use and to mess around.

## What are you going to add?

- [ ] Colors (something like coloring only the directory name?)
- [ ] Possibly some command line options
      (though it's equally arguable that it would be cleaner
       to just change the source and recompile for such a small program)
- [ ] Possibly VCS integration, though apparently zsh has a nice
      [plugin](http://arjanvandergaag.nl/blog/customize-zsh-prompt-with-vcs-info.html)
      for that.

## License

See `LICENSE.md`
