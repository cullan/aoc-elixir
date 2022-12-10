# AdventOfCode

Help Santa by programming computers.

## Setup

The project includes a nix development shell.

Make a file named `.secret` that looks like this:

``` sh
export AOC_SESSION_KEY="your key here"
export AOC_USER_AGENT="your repo url and email address"
```

## Prepare to solve a day's puzzles

There is a mix task to create source and test files for a day. The year argument
is optional. It defaults to the current year. The title is scraped from the problem
description on the AOC web site.

``` sh
mix aoc.prepare 1 2022
```

## Run the solution and print the answers

The input is downloaded once and cached for subsequent runs. See the `Input`
module and `aoc.run` mix task for details.

``` sh
mix aoc.run 1 2022
```

## API Automation notes

- API calls only happen when one of the mix tasks is run.
- API calls have a cooldown of 3 minutes.
- Downloaded inputs are cached and reused.
- The title is not scraped again once a puzzle source code file is created.
- The user agent is configured by the AOC_USER_AGENT env var.
