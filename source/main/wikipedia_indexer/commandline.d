module wikipedia_indexer.commandline;

import core.stdc.stdlib : exit;
import std.getopt;
import std.stdio : writeln;
import std.typecons : tuple, Tuple;

void handleArguments(string[] args)
{
    import wikipedia_indexer.subcommands : subcommands;

    string executableName = args[0];
    try
    {
        auto helpInformationAndArguments = args.parseArguments;
        auto subcommand = (helpInformationAndArguments.parsedArguments.subcommand in subcommands);

        if (subcommand is null)
        {
            handleMissingSubcommand(helpInformationAndArguments, executableName);
        }
        else
        {
            (*subcommand)(helpInformationAndArguments.unparsedArguments);
        }
    }
    catch (GetOptException e)
    {
        writeln("Error while trying to parse the commandline options: ", e.msg);
        printHelp(executableName, [executableName, "-h"].parseArguments.helpInformation);
        exit(1);
    }
    assert(0);
}

private:

struct Arguments
{
    string subcommand;
    bool _version;
}

auto parseArguments()(string[] args)
{
    Arguments arguments;

    auto getoptResult = getopt(args, config.passThrough, config.caseSensitive,
            "version|V", "Print version info and exit.", &arguments._version);

    if (args.length >= 2)
    {
        arguments.subcommand = args[1];
    }

    if (getoptResult.helpWanted)
    {
        args ~= "-h";
    }

    return tuple!("helpInformation", "parsedArguments", "unparsedArguments")(
            getoptResult, arguments, args);
}

alias HelpInformationAndArguments = Tuple!(GetoptResult, "helpInformation",
        Arguments, "parsedArguments", string[], "unparsedArguments");

void handleMissingSubcommand(
        HelpInformationAndArguments helpInformationAndArguments, string executableName)
{
    if (helpInformationAndArguments.helpInformation.helpWanted)
    {
        printHelp(executableName, helpInformationAndArguments.helpInformation);
        exit(0);
    }
    else if (helpInformationAndArguments.parsedArguments._version)
    {
        printVersion();
        exit(0);
    }
    else
    {
        writeln("No subcommand given.");
        printHelp(executableName, [executableName, "-h"].parseArguments.helpInformation);
        exit(1);
    }
}

void printHelp(string executableName, GetoptResult getoptResult)
{
    import std.format : format;

    defaultGetoptPrinter(format!"Usage: %s [global options] [subcommand] [options] \n\nCommands:"(executableName),
            [Option("create", null, "Create an index for a Wikipedia dump.", false)]);
    defaultGetoptPrinter("\nGlobal options:", getoptResult.options);
}

void printVersion()
{
    import wikipedia_indexer._version : _version;

    writeln("wikipedia-indexer " ~ _version);
}
