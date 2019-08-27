module wikipedia_indexer.subcommands.query.arguments;

import core.stdc.stdlib : exit;
import std.format : format;
import std.getopt : config, defaultGetoptPrinter, getopt, GetOptException, GetoptResult;
import std.stdio : writeln;

struct Arguments
{
    string inputFileName;
    string query;
}

Arguments handleArguments(string[] args)
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
        writeln("Error while trying to parse the commandline options: ",
                e.msg);
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
    string query;

    auto getoptResult = getopt(args, config.required, "input|i", "The name of the file to read the data from.",
            &inputFileName, config.required, "search|s", "The string to search for.", &query);

    return tuple!("helpInformation", "arguments")(getoptResult, Arguments(inputFileName, query));
}

void printHelp(string executableName, GetoptResult getoptResult)
{
    defaultGetoptPrinter(format!"Usage: %s query [options] \n\nOptions:"(executableName),
            getoptResult.options);
}
