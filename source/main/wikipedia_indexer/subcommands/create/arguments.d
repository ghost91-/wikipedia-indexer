module wikipedia_indexer.subcommands.create.arguments;

import core.stdc.stdlib : exit;
import std.getopt;

package:

struct Arguments
{
    string inputFileName;
    string outputFileName;
    size_t numberOfPages;
    bool verbose;
}

auto handleArguments(string[] args)
{
    string executableName = args[0];

    try
    {
        auto helpInformationAndArguments = args.parseArguments;

        if (!helpInformationAndArguments.helpInformation.helpWanted)
        {
            return helpInformationAndArguments.arguments;
        }
        else
        {
            printHelp(executableName, helpInformationAndArguments.helpInformation);
            exit(0);
        }
    }
    catch (GetOptException e)
    {
        import std.stdio : writeln;

        writeln("Error while trying to parse the commandline options: ", e.msg);
        printHelp(executableName, [executableName, "-h"].parseArguments.helpInformation);
        exit(1);
    }
    assert(0);
}

private:

auto parseArguments(string[] args)
{
    import std.typecons : tuple;

    string inputFileName;
    string outputFileName;
    size_t numberOfPages;
    bool verbose;

    auto getoptResult = getopt(args, config.caseSensitive,
            config.required, "input|i", "The name of the file to read the data from.",
            &inputFileName, config.required, "output|o",
            "The name of the file to write the index to.",
            &outputFileName, "pages|p", "The number of pages to process. If set to 0, all pages are processed.",
            &numberOfPages, "verbose|v", "Use verbose output.", &verbose);

    return tuple!("helpInformation", "arguments")(getoptResult,
            Arguments(inputFileName, outputFileName, numberOfPages, verbose));
}

void printHelp(string executableName, GetoptResult getoptResult)
{
    import std.format : format;

    defaultGetoptPrinter(format!"Usage: %s create [options] \n\nOptions:"(executableName),
            getoptResult.options);
}
