module wikipedia_indexer.subcommands.create;

import std.algorithm;
import std.array : array;
import std.stdio : File;
import std.experimental.logger;
import wikipedia_indexer.subcommands.create.arguments : handleArguments;
import wikipedia_indexer.subcommands.create.mmfile : MmFileRange;
import wikipedia_indexer.subcommands.create.parser : parse;

void create(string[] args)
{
    auto arguments = handleArguments(args);
    globalLogLevel = arguments.verbose ? LogLevel.all : LogLevel.info;

    infof(`Parsing file "%s".`, arguments.inputFileName);
    auto result = MmFileRange(arguments.inputFileName).parse(arguments.numberOfPages);

    info(`Sorting the parsed data.`);
    auto sorted = result.byKeyValue.array.sort!((a, b) => a.key < b.key);

    infof(`Writing index to "%s".`, arguments.outputFileName);
    auto output = File(arguments.outputFileName, "w");
    sorted.each!(e => output.writeln(e.key, ">", e.value[].joiner("|")));
}
