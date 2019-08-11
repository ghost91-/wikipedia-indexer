module wikipedia_indexer.app;

import std.algorithm;
import std.array;
import std.file;
import std.stdio;
import std.experimental.logger;
import wikipedia_indexer.arguments;
import wikipedia_indexer.parser;

void main(string[] args)
{
    auto arguments = handleArguments(args);

    size_t start = 0;
    size_t end = getSize(arguments.inputFileName);

    infof(`Parsing file "%s".`, arguments.inputFileName);
    auto result = parse(arguments.inputFileName, start, end, arguments.numberOfPages);

    info(`Sorting the parsed data.`);
    auto sorted = result.byKeyValue.array.sort!((a, b) => a.key < b.key);

    infof(`Writing index to "%s".`, arguments.outputFileName);
    auto output = File(arguments.outputFileName, "w");
    sorted.each!(e => output.writeln(e.key, ";", e.value[].joiner(", ")));
}
