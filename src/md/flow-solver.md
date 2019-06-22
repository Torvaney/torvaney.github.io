% Flow Free: A SATisfying solution

A solver for the Flow Free puzzle game using Clojure and SAT.

<br>

<img src="../src/static/img/flow-solver/before-and-after.png" class="fat"/>

<br>

Find the code [on github](https://github.com/Torvaney/flow-solver).

<marquee behavior="scroll" direction="left" scrollamount="1" class="red">------------</marquee>
<marquee behavior="scroll" direction="left" scrollamount="2" class="blue">---------------</marquee>
<marquee behavior="scroll" direction="right" scrollamount="1" class="green">-------------</marquee>

## Overview

On a recent holiday, I found out that the friend I was travelling with plays this game a lot. A lot as in _every day for the past few years_. And to be fair, I can see the appeal (to an extent...). It's a pleasant game, and there is a feeling of satisfaction that comes with solving one of the game's puzzles.

But wouldn't it be more satisfying if we could find a solution to _all_ Flow Free maps?

This blog explores one way to do this using [Boolean Satisfiability](https://en.wikipedia.org/wiki/Boolean_satisfiability_problem) (SAT).

### So, what is Flow Free anyway?

The core mechanics of the game are pretty simple[^1]. At each level, you are presented with a map with pairs of coloured dots occupying some cells:

[^1]: In fact, in the process of writing this post, I discovered that the origins of the game go back to [1897 as "Numberlink"](https://en.wikipedia.org/wiki/Numberlink)

<br>

<img src="../src/static/img/flow-solver/flow-free-puzzle.png" class="skinny"/>

<p style="text-align: center">Screenshot from [youtube](https://youtu.be/TCnQPsExQuY?t=30).</p>

<br>

This usually (although not always) takes the form of a square grid. As you progress through the game, the levels get harder by either increasing the size of the map, and/or increasing the number of coloured dot pairs.

The goal of the game is to connect the dots with pipes that can move to adjacent cells, such that every cell is filled:

<br>

<img src="../src/static/img/flow-solver/flow-free-solution.gif" class="skinny"/>

<p style="text-align: center">Gameplay from [youtube](https://youtu.be/TCnQPsExQuY?t=30).</p>

<br>

So far, so intuitive.

However, in order to pass the puzzle off to a computer to solve, we need to represent the puzzle as data.

<marquee behavior="scroll" direction="right" scrollamount="2" class="pink">-------------</marquee>
<marquee behavior="scroll" direction="left" scrollamount="1" class="orange">-----------</marquee>
<marquee behavior="scroll" direction="right" scrollamount="1" class="yellow">------------</marquee>

## Representing the problem

Perhaps the most obvious way to think about the puzzle is as it is displayed in that app. Namely as an array in which each cell takes a colour. The goal of the puzzle is then to find the correct (more on this later) colour for each cell.

This is a fine approach, and will work for the examples we've seen so far. However, it is not generic enough to handle *everything* that Flow Free has to offer.

The Flow Free app comes with a range of additional maze layouts, some of which would be cumbersome to store in a simple array layout. These can be grouped according to a few key characteristics:

#### Alternate shapes

<div class="img-row">

<div class="img-column">
  <img src="../src/static/img/flow-solver/inkblot.jpeg" style="width:100%"/>
</div>

<div class="img-column">
  <img src="../src/static/img/flow-solver/worms.jpeg" style="width:100%"/>
</div>

<div class="img-column">
  <img src="../src/static/img/flow-solver/amoeba.jpeg" style="width:100%"/>
</div>

</div>

#### Additional connections

<div class="img-row">

<div class="img-column">
  <img src="../src/static/img/flow-solver/bridges.jpeg" style="width:100%"/>
</div>

<div class="img-column">
  <img src="../src/static/img/flow-solver/hexes.jpeg" style="width:100%"/>
</div>

<div class="img-column">
  <img src="../src/static/img/flow-solver/warps.jpeg" style="width:100%"/>
</div>

</div>

#### Walls (blocked connections)

<div class="img-row">

<div class="img-column">
  <img src="../src/static/img/flow-solver/courtyard.jpeg" style="width:100%"/>
</div>

<div class="img-column">
  <img src="../src/static/img/flow-solver/star-field.jpeg" style="width:100%"/>
</div>

<div class="img-column">
  <img src="../src/static/img/flow-solver/courtyard-spin.jpeg" style="width:100%"/>
</div>

</div>

<br>

Or, of course, some combination of the three:

<img src="../src/static/img/flow-solver/combination.jpeg" class="skinny"/>

So what we need is something that can handle these cases as well as the standard square map.

### Graphs all the way down

One way of representing any given Flow Free puzzle is a [graph](https://en.wikipedia.org/wiki/Graph_(abstract_data_type))[^2].

[^2]: After all, [everything is a graph](https://gephi.wordpress.com/2011/10/12/everything-looks-like-a-graph-but-almost-nothing-should-ever-be-drawn-as-one/), even if we're not sure of the best way [to draw them](https://dhs.stanford.edu/algorithmic-literacy/everything-is-a-graph-and-drawing-it-as-such-is-always-the-best-thing-to-do/).

Representing a puzzle map as a graph is relatively straighforward. Each cell is represented by a node in the graph. If a pipe can move from one cell to another, then those two cells will be connected by an edge.

We also mark out which cells are "terminal" cells, where flows must start and end. These are marked by a coloured circle in the app's display.

For example, for a square map this looks like:

<img src="../src/static/img/flow-solver/7-by-7-to-graph.png" class="fat"/>

However, this also works for the other variants. For example, puzzles with additional connections, like this warp puzzle simply require an additional edge:

<img src="../src/static/img/flow-solver/warps-to-graph.png" class="fat"/>

Or in the case of the "bridge" puzzles, we would have to split any bridge cells into 2 nodes. One with the horizontal connections and the other with the vertical connections. For walls or blocked connections, we would _remove_ edges. While with alternate shapes, we would have to employ some combination of adding/removing nodes and edges, depending on the exact map.

<marquee behavior="scroll" direction="left" scrollamount="1" class="green">------------</marquee>
<marquee behavior="scroll" direction="right" scrollamount="2" class="blue">---------------</marquee>
<marquee behavior="scroll" direction="right" scrollamount="2" class="skyblue">-------------</marquee>

## Solving the problem

As I have alluded to already, one convenient way to solve a puzzle like this is reduction to Boolean Satisfiability, or SAT. According to [Wikipedia](https://en.wikipedia.org/wiki/Boolean_satisfiability_problem), SAT

> ... asks whether the variables of a given Boolean formula can be consistently replaced by the values TRUE or FALSE in such a way that the formula evaluates to TRUE. If this is the case, the formula is called satisfiable.

This is useful because this particular problem is very well studied, and as a result, there are many extremely effective off-the-shelf libraries for solving SAT problems. So instead of having to write our own solution from scratch, we can instead convert this problem into a Boolean formula, and pass it off to a pre-existing solver.

In order to convert a given Flow Free level to SAT, we must come up with a set of variables and constraints for SAT, such that the solved expression (i.e. all the variables are set to "true" or "false", and all the constraints evaluate to "true") will give us a valid puzzle solution[^3].

[^3]: A common task used to demonstrate this is solving a sudoku puzzle with SAT. I think [this talk](https://www.youtube.com/watch?v=XGl-TumKD98) does a good job of walking through this at a slower pace than I have done here. I've also shamelessly ripped off the tile pun for this blog post.

### Variables

[Note about modelling the edges]

For example, in a 3-colour map, edge _i_ may be associated with three separate variables:

* _i_ is blue
* _i_ is red
* _i_ is green

Of course, only one of these can be true, which brings us neatly to ...

### Constraints

#### Each edge must have **exactly one** colour

As mentioned, this constraint follows on naturally from the variable definition. It may seem obvious but we still need to make it explicit. So for edge _i_, we get an expression like:

* (_i_ is blue) and (_i_ is not green) and (_i_ is not red), or
* (_i_ is green) and (_i_ is not blue) and (_i_ is not red), or
* (_i_ is red) and (_i_ is not green) and (_i_ is not blue), or


#### Connecting nodes must have **exactly two** coloured edges of the **same colour**

Edges in the graph represent connections between cells in the puzzle. This constraint represents the fact that each empty ("connecting") cell must have a pipe flowing in and out of it. This constraint ensures that all the map gets filled.

#### Terminal nodes must have **exactly one** coloured edge

The rationale here is similar to that of connecting cells. However, by nature terminal cells must be connected to only _one_ other cell, rather than two. This constraint ensures that pipes actually connect to their start/end points (and go no further).

### Solution

Having represented our problem in this way, we can hand it off to a SAT solver and receive our solution (if one exists):

<br>

<img src="../src/static/img/flow-solver/7-by-7-graph-solved.png" class="chubby"/>

<br>

<marquee behavior="scroll" direction="right" scrollamount="2" class="pink">------------</marquee>
<marquee behavior="scroll" direction="left" scrollamount="2" class="skyblue">---------------</marquee>
<marquee behavior="scroll" direction="right" scrollamount="1" class="yellow">-------------</marquee>


## Wrap up & technical notes


As I mentioned above, the code for this solver is available [on github](https://github.com/Torvaney/flow-solver). This is written in Clojure and uses the [rolling-stones](https://github.com/Engelberg/rolling-stones) library (an interface to [sat4j](https://www.sat4j.org)) to solve a given puzzle, returning "before" and "after" images similar to those shown at the top of this post. This proved to be a particularly nice way to go because Rolling Stones allows you to use arbitrary clojure data structures as your SAT variables. Likewise the [ubergraph](https://github.com/Engelberg/ubergraph) library[^4] made working with and visualising the graphs extremely painless, which was a nice surprise. See the project README for more instructions on running the solver.

[^4]: As it happens, both rolling-stones and ubergraph have the same author!

Although I used SAT to solve this, there are a few other approaches that I think could prove interesting. One such approach is using a genetic algorithm instead of SAT to find the edge colours. As far as I can see, by converting the constraints to a fitness function, a very similar approach could find success. Although I think this would be significantly less convenient and efficient than SAT.

There is also a website, [flowfreesolutions.com](https://flowfreesolutions.com), that lists solutions to every level of Flow Free. This got me thinking that it'd be an interesting (if quite different) project to try and create a solver using supervised learning methods. After all, it would be relatively trivial to generate a training set of valid mazes automatically.

---


## Appendix

### Prior work

Since I did this project as part of an attempt to learn a bit more about SAT, I did not do much research beforehand. However, attempting to create a solver for this kind of puzzle is far from unique, and there are plenty of other (generally more impressive) ones floating around:

* Aug 2007: ["Beyond Sudoku"](https://www.mathematica-journal.com/data/uploads/2007/08/NumberLink.pdf), an article in The Mathematica Journal inviting readers to send in their solutions for some Numberlink puzzles to win a prize. I suspect I may have missed the boat on this one.
* Apr 2012: A [general solver](https://www.mdpi.com/1999-4893/5/2/176) for this type of puzzle using ZDDs (no, I hadn't heard of ZDDs either).
* Nov 2013: A [Numberlink solver](http://bach.istc.kobe-u.ac.jp/copris/puzzles/numberlink/) Scala (using [Copris](http://bach.istc.kobe-u.ac.jp/copris/))
* May 2015: A [proof that Flow Free is NP Complete](https://www.jstage.jst.go.jp/article/ipsjjip/23/3/23_239/_article/-char/ja/)
* Aug 2016: [A fast, automated solver written in C](https://mzucker.github.io/2016/08/28/flow-solver.html) by Matt Zucker, looking at the puzzle as a [shortest-path](https://en.wikipedia.org/wiki/Shortest_path_problem) problem.
* Jan 2017: A [puzzling.stackexchange.com discussion](https://puzzling.stackexchange.com/questions/47685/strategy-for-solving-flow-free-puzzles) on the strategies for solving Flow Free levels. The top answer suggests a few heuristics to help solve the puzzles.
* Apr 2017: A [python solver](https://github.com/lukegarbutt/Flow-Free-Solver) that uses heuristics to solve each level. This comes with a [video series](https://www.youtube.com/watch?v=zbH6ZhmLx3c&list=PLsYctZrw5bWte2DOCCxhUF9Nzr_z_fZK6) explaining the solver. Another cool thing about this project is that it takes the screen of the phone or device running Flow Free as its input.

Some additional entries from 2016 and earlier can be found in [Matt Zucker's post](https://mzucker.github.io/2016/08/28/flow-solver.html#theend), which I have pasted below:

* Jun 2011: just a [video](https://www.youtube.com/watch?v=ghEK_79owaU) of a solver proceeding at a leisurely pace, couldn’t find source.
* Nov 2011: [solver in C++](https://github.com/imos/Puzzle/tree/master/NumberLink) for a related puzzle, looks like a standard recursive backtracker.
* Aug 2012: [solver in Perl](https://github.com/DeeNewcum/FlowFree), mothballed, doesn’t work, but README has a link to an interesting paper.
* Oct 2012: [solver in C#](https://github.com/JamesDunne/freeflow-solver), appears not to work based upon final commit message.
* Feb 2013: chatting about designing solvers in a [C++ forum](http://www.cplusplus.com/forum/general/93467/).
* Jul 2013: [solver in R](https://www.r-bloggers.com/using-r-and-integer-programming-to-find-solutions-to-flowfree-game-boards/), framed as integer programming.2
* Sep 2013: [two](https://github.com/taylorjg/FlowFreeDlx) [solvers](https://github.com/taylorjg/FlowFreeSolverWpf) from the same programmer, both in C#, both use DLX; author notes long solve times for large grids.
* Feb 2014: solver as [coding assignment](http://cs.mwsu.edu/~terry/?route=/courses/3013/content/assignments/page/Program1.md) in a C++ class, yikes.
* Mar 2014: [StackOverflow chat](http://stackoverflow.com/questions/23622068/algorithm-for-solving-flow-free-game) on designing a solver, top answer suggests reducing to SAT.3
* Feb 2016: [solver in MATLAB](https://github.com/GameAutomators/Flow-Free) using backtracking; very slow on puzzles > 10x10 but it does live image capture and there’s a cool YouTube demo.
