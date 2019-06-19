% Flow Free: A SATisfying solution

A solver for the Flow Free puzzle game using Clojure and SAT.

<img src="../src/static/img/flow-solver/before-and-after.png" class="wide"/>

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

To me, it feels like the natural solution is a [graph](https://en.wikipedia.org/wiki/Graph_(abstract_data_type)). After all, [everything is a graph](https://gephi.wordpress.com/2011/10/12/everything-looks-like-a-graph-but-almost-nothing-should-ever-be-drawn-as-one/), even if the best way to draw then [is disputed](https://dhs.stanford.edu/algorithmic-literacy/everything-is-a-graph-and-drawing-it-as-such-is-always-the-best-thing-to-do/).

[Explain the rationale/argument]

In this way, the representation of a puzzle map as a graph is relatively straighforward. Each cell is represented by a node in the graph. If a pipe can move from one cell to another, then those two cells will be connected by an edge.

For example, for a square map this looks like:

[Show an example image of a map and unsolved graph. The solved version will be shown later. Maybe the same map from the gif earlier]

However, this also works for the other variants:

[another example map]


<marquee behavior="scroll" direction="left" scrollamount="1" class="green">------------</marquee>
<marquee behavior="scroll" direction="right" scrollamount="2" class="blue">---------------</marquee>
<marquee behavior="scroll" direction="right" scrollamount="2" class="skyblue">-------------</marquee>

## Solving the problem

One convenient way to solve a puzzle like this is to convert it to SAT. SAT, according to [Wikipedia](https://en.wikipedia.org/wiki/Boolean_satisfiability_problem):

> ... asks whether the variables of a given Boolean formula can be consistently replaced by the values TRUE or FALSE in such a way that the formula evaluates to TRUE. If this is the case, the formula is called satisfiable.

This is useful because this particular problem is very well studied, and as a result, there are many highly effective off-the-shelf libraries for solving SAT problems. So instead of having to code our own solution from scratch, we can instead convert this problem into a Boolean formula, and pass it off to a pre-existing solver.

In order to convert a given Flow Free level to SAT, we must come up with a set of variables and a set of constraints, such that the solved expression (i.e. all the variables are set to "true" or "false", and all the constraints evaluate to "true") will give us a valid puzzle solution.

### Variables

The only action the player can actually take in the game is altering a cell's colour, and so it makes sense for the base propositions of the Boolean formula to take this form, too[^2].

[^2]: In the initial solver, I modelled the pipes more directly by assigning colours to the _edges_ of the graph rather than the nodes. I think this formulation is potentially more elegant, but it turned out the computational requirements are an order of magnitude larger than setting the cell colours, due to the larger number of variables involved. In the end, a solver isn't much use if it can't actually be run.

In the solver, a variable is created representing each possible colour that each cell could take in the solved puzzle. For example, in a 3-colour map, cell _i_ may be associated with 3 variables:

* _i_ is blue
* _i_ is red
* _i_ is green

[Note about modelling the edges instead]

### Constraints

#### Each cell must be **exactly one** colour

The first constraint follows on naturally from the variable definition. It may seem obvious but we still need to make it explicit. If we extend the example above we get something like:

* (_i_ is blue) and (_i_ is not green) and (_i_ is not red), or
* (_i_ is green) and (_i_ is not blue) and (_i_ is not red), or
* (_i_ is red) and (_i_ is not green) and (_i_ is not blue), or


#### Connecting cells must be adjacent to **at least two** coloured edges of the **same colour**

In other words, cells that appear empty at the start must be filled by a pipe going in and a pipe going out of the cell. This helps to prevent pipes from ending before they reaches a terminal cell (the coloured points given on an unsolved map).

#### **Terminal cells** must be adjacent to **at least one** coloured edge

The rationale here is similar to that of connecting cells. However, by nature terminal cells must be connected to only _one_ other cell, rather than two. This constraint ensures that pipes actually connect to their start/end points.

### Solution

Having represented our problem in this way, we can hand it off to a SAT solver and receive our solution (if one exists):

[Insert an example image of a solved graph here]


<marquee behavior="scroll" direction="right" scrollamount="2" class="pink">------------</marquee>
<marquee behavior="scroll" direction="left" scrollamount="2" class="skyblue">---------------</marquee>
<marquee behavior="scroll" direction="right" scrollamount="1" class="yellow">-------------</marquee>


## Wrap up


As I mentioned above, the code for this solver is available [on github](https://github.com/Torvaney/flow-solver). This is written in Clojure and uses the [rolling-stones](https://github.com/Engelberg/rolling-stones) library (an interface to [sat4j](https://www.sat4j.org)) to solve a given puzzle, returning "before" and "after" images similar to those shown at the top of this post. This proved to be a particularly nice way to go because Rolling Stones allows you to use arbitrary clojure data structures as your SAT variables. Likewise the [ubergraph](https://github.com/Engelberg/ubergraph) library (by the same author!) made working with and visualising the graphs extremely painless, which was a nice surprise.

Although I used SAT to solve this, I also considered using a genetic algorithm. As far as I can see, by converting the constraints to a fitness function, a very similar approach could find success here. There is also a website, [flowfreesolutions.com](https://flowfreesolutions.com), that lists solutions to every level of Flow Free. It'd be an interesting (if quite different) project to try and create a solver using supervised learning methods and a training set from flowfreesolutions.

---


## Appendix

### Prior work

Since I did this project as part of an attempt to learn a bit more about SAT, I did not do much research beforehand. However, attempting to create a solver for this kind of puzzle is far from unique, and there are plenty of other (generally more impressive) ones floating around:

* August 2007: ["Beyond Sudoku"](https://www.mathematica-journal.com/data/uploads/2007/08/NumberLink.pdf), an article in The Mathematica Journal inviting readers to send in their solutions for some Numberlink puzzles to win a prize. I suspect I may have missed the boat on this one.
* April 2012: A [general solver](https://www.mdpi.com/1999-4893/5/2/176) for this type of puzzle using ZDDs (no, I hadn't heard of ZDDs either).
* November 2013: A [Numberlink solver](http://bach.istc.kobe-u.ac.jp/copris/puzzles/numberlink/) Scala (using [Copris](http://bach.istc.kobe-u.ac.jp/copris/))
* Aug 2016: [A fast, automated solver written in C](https://mzucker.github.io/2016/08/28/flow-solver.html) by Matt Zucker, looking at the puzzle as a [shortest-path](https://en.wikipedia.org/wiki/Shortest_path_problem) problem.
* January 2017: A [puzzling.stackexchange.com discussion](https://puzzling.stackexchange.com/questions/47685/strategy-for-solving-flow-free-puzzles) on the strategies for solving Flow Free levels. The top answer suggests a few heuristics to help solve the puzzles.
* April 2017: A [python solver](https://github.com/lukegarbutt/Flow-Free-Solver) that uses heuristics to solve each level. This comes with a [video series](https://www.youtube.com/watch?v=zbH6ZhmLx3c&list=PLsYctZrw5bWte2DOCCxhUF9Nzr_z_fZK6) explaining the solver. Another cool thing about this project is that it takes the screen of the phone or device running Flow Free as its input.

Some additional entries from 2016 can be found in [Matt Zucker's post](https://mzucker.github.io/2016/08/28/flow-solver.html#theend). I have pasted these below:

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
