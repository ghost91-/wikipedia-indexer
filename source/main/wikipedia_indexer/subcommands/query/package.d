module wikipedia_indexer.subcommands.query;

import std.algorithm;
import std.array;

void query(string[] args)
{
    import std.file : read;
    import std.range : assumeSorted;
    import std.stdio : writeln;
    import wikipedia_indexer.subcommands.query.arguments : handleArguments;

    auto arguments = handleArguments(args);
    auto data = cast(string) read(arguments.inputFileName);

    auto found = data.splitter('\n').filter!(a => !a.empty)
        .array
        .assumeSorted!(pred)
        .equalRange(arguments.query).map!(extractKeywordAndResultsFromLine);

    if (!found.empty)
    {
        found.front.results.each!writeln;
    }
}

private:

bool pred(string a, string b)
{
    return a.extractKeywordFromLine < b.extractKeywordFromLine;
}

auto extractKeywordFromLine(string line)
{
    return line.splitter('>').front;
}

auto extractKeywordAndResultsFromLine(string line)
{
    import std.typecons : tuple;

    auto splitLine = line.splitter('>');
    immutable keyword = splitLine.front;
    splitLine.popFront;
    immutable results = splitLine.front.splitter('|').array;

    return tuple!("keyword", "results")(keyword, results);
}
