# wikipedia-indexer

[![CircleCI](https://img.shields.io/circleci/build/github/ghost91-/wikipedia-indexer?token=abc123def456)](https://circleci.com/gh/ghost91-/wikipedia-indexer)
[![License](https://img.shields.io/github/license/ghost91-/wikipedia-indexer?color=blue)](https://github.com/ghost91-/wikipedia-indexer/blob/master/LICENSE)

A tool to create indices for Wikipedia pages.

## Building

Building requires DUB and a recent version of DMD or LDC. You can build the
application by running the following on the commandline:

```
dub build
```

If performance matters (e.g. if you want to index a complete Wikipedia dump), it
is advised to use LDC and  build the application in release mode:

```
dub build -b release
```

## Usage

```
Usage: ./wikipedia-indexer [global options] [subcommand] [options] 

Commands:
create  Create an index for a Wikipedia dump.

Global options:
-V --version Print version info and exit.
-h    --help This help information.
```

### Creating an index

```
Usage: ./wikipedia-indexer create [options] 

Options:
-i   --input Required: The name of the file to read the data from.
-o  --output Required: The name of the file to write the index to.
-p   --pages           The number of pages to process. If set to 0, all pages are processed.
-v --verbose           Use verbose output.
-h    --help           This help information.
```

## Running the tests

You can run the test by running the following on the commandline:

```
dub test
```

## Acknowledgments

Part of the test data is exported from [Wikipedia](https://www.wikipedia.org/)
and licensed under [Creative Commons Attribution-ShareAlike 3.0](https://creativecommons.org/licenses/by-sa/3.0/legalcode).

