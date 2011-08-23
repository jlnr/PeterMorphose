# Peter Morphose

```bash
gem install petermorphose
petermorphose
```

## What is Peter Morphose?

Peter Morphose is a jump-and-run-and-survive platformer I wrote between 2000 and 2001, using Borland Delphi and the DelphiX library.

To give you an idea about the style of the game, you can look at the screenshot map of a typical level here: http://www.petermorphose.de/biddy/level/diezweibaeume.png

It was available only for Windows and only in German. The integrated level editor was popular with fans, but I never managed to build a community site to share those levels. I made some available in a level pack, though.

## What is this repository?

This repository is a work-in-progress rewrite of Peter Morphose using Ruby and Gosu, with the following differences:

* Runs on Windows, Mac OS X, Linux
* Supports English and German
* Simplified controls
* Simplified gameplay
* Full gamepad support
* Level compatibility with the original game is retained (but not all levels are tested & included yet)

## Why oh why remake such a frustrating game?

* I was jamming along the Ludum Dare #21 competition with the given theme 'Escape'. Peter Morphose was a natural match.
* The existing source code was neither public nor versioned. It was fantastically terrible too.
* Translating from Delphi to Ruby sounded easy enough, given how similar the languages look like.
* I wanted to have a new toy Ruby game to try to get running in NaCl. I ran out of time just porting the game though.

## References

* The original website, http://www.petermorphose.de/
* The Gosu gamedev library, http://www.libgosu.org/
* KaiserBiddy’s German info page, with screenshots of many levels, http://www.petermorphose.de/biddy/
* Christopher Hauck’s German fansite, with more downloadable levels, http://www.christopherhauck.de/f2_pm.php
* Its lonely Facebook page I didn’t even know about, https://www.facebook.com/pages/Peter-Morphose/124840104250204

## But there is still so much wrong about the game!

Feel free to fork it or file issues :)

-- Julian
