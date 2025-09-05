----
title: Realtime Math Lecture Notes
modified: 2025-09-01
meta_description: "Typesetting maths lecture notes in realtime is possible. In this post I'll describe my workflow and tools."
tags: Typesetting
prerequisites: 
----

This blog describes how I take realtime notes during a math lecture. 

I began my note taking journey with
Giles Castel's setup (you can find that tutorial 
[here](https://castel.dev/post/lecture-notes-1/)). 
Eventually, `LaTeX` stopped working. I'm a slow typist (~60 wpm), so the long 
`pdflatex` compile times broke my flow. 

Writing text and mathematical formulas should be as fast as the lecturer writing on a blackboard: no delay is acceptable.

<!--more-->

I switched to Typst. The syntax is intuitive, and there's no need to 
use complicated regex with snippets to typeset fractions. In Typst, correctly 
parenthesized expressions with `/` just work.
I found myself using `ultisnips` much less once I switched to Typst. 

I created a vim shell hook which ran when I opened a `.typ` document. 

The hook would
1. open a new `tmux` frame, 
1. pipe a `typst watch` command on the edited file, and
1. open the corresponding `pdf` in `skim`.


Copy my setup:

1. Install `typst` 
1. Install `skim` 
1. Copy my `.vimrc` (installs `ultisnips`)
1. Profit

