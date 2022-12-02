# AdventOfCode

Help Santa by programming computers.

## Setup

The project includes a nix development shell.

Make a file named `.secret` that looks like this:

``` sh
export AOC_SESSION_KEY="your key here"
```

## Prepare to solve a day's puzzles

There is a mix task to create source and test files for a day. The year argument
is optional. It defaults to the current year.

``` sh
mix aoc.prepare 1 2022
```

## Run the solution and print the answers

The input is downloaded once and cached for subsequent runs. See the `Input`
module for details.

``` sh
mix aoc.run 1 2022
```
