% Flow Free: A SATisfying solution

A solver for the Flow Free puzzle game using Clojure and SAT.

<img src="../src/static/img/flow-solver/before-and-after.png" class="wide"/>

Find the code [on github](https://github.com/Torvaney/flow-solver).

<marquee behavior="scroll" direction="left" scrollamount="1" class="red">------------</marquee>
<marquee behavior="scroll" direction="left" scrollamount="2" class="blue">---------------</marquee>
<marquee behavior="scroll" direction="right" scrollamount="1" class="green">-------------</marquee>

## Overview

On a recent holiday, I found out that the friend I was travelling with plays this game a lot. A lot as in _every day for the past few years_. And to be fair, I can see the appeal. It's a pleasant game, and there is a feeling of satisfaction that comes with solving one of the game's puzzles.

That said, I can't help but think that it would be more satisfying if we could find a solution to _all_ Flow Free mapa. This blog explores one way to do this using [Boolean Satisfiability](https://en.wikipedia.org/wiki/Boolean_satisfiability_problem) (SAT).

### So, what is Flow Free anyway?

The core mechanics of the game are pretty simple. At each level, you are presented with a map with pairs of coloured dots occupying some cells:

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

#### Blocked or missing connections

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

* A natural solution is a graph
* After all, everything is a graph
* [Explain how you go from map <-> graph]

[Show an example image of a map and unsolved graph. The solved version will be shown later. Maybe the same map from the gif earlier]

[Note how square graphs are input into the program with an .edn file]

* This representation also extends beyond square maps


<marquee behavior="scroll" direction="left" scrollamount="1" class="green">------------</marquee>
<marquee behavior="scroll" direction="right" scrollamount="2" class="blue">---------------</marquee>
<marquee behavior="scroll" direction="right" scrollamount="2" class="skyblue">-------------</marquee>

## Solving the problem

* [Intro to SAT]

So how do we convert _this_ problem to SAT?

...

We come up with the following constraints:

#### Each cell must have **exactly one** colour

This may seem obvious but we still need to make it explicit.

[Pictorial example]

#### Connecting cells must be adjacent to **at least two** coloured edges of the **same colour**

In other words, empty cells must be filled by 1 pipe going in and out of the cell:

[Pictorial example]

#### **Terminal nodes** must be adjacent to **at least one** coloured edge

I think this one is relatively simple. Definitionally, terminal cells (the points given on an unsolved map) must be connected to only one other cell.


<br>


Having represented our problem in this way, we can pass it off to a
SAT solver and receive our solution (if one exists).

``` bash
lein run path/to/file.edn
```

[Insert an example image of a solved graph here]

### But wait...

There is a slight problem with this example.

_explain loops_

[Show an example with a loop]


<br>


_Conclusion goes here_

* Link to code
* What other approaches could I have tried?
* Genetic algorithm > SAT
* Machine learning solution (all the solutions available online)

<marquee behavior="scroll" direction="right" scrollamount="2" class="pink">------------</marquee>
<marquee behavior="scroll" direction="left" scrollamount="2" class="skyblue">---------------</marquee>
<marquee behavior="scroll" direction="right" scrollamount="1" class="yellow">-------------</marquee>

---


## Appendix

### Code & acknowledgements

* Rolling stone library is really nice w/ clojure as SAT variables

### Prior work

* https://mzucker.github.io/2016/08/28/flow-solver.html#theend
