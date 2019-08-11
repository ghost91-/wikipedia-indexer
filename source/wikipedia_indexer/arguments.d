module wikipedia_indexer.arguments;

import core.stdc.stdlib : exit;
import std.format : format;
import std.getopt : config, defaultGetoptPrinter, getopt, GetOptException;
import std.stdio : writeln;

struct Arguments
{
    string inputFileName;
    string outputFileName;
    string executableName;
    size_t numberOfPages;
}

auto handleArguments(string[] args)
{
    string inputFileName;
    string outputFileName;
    string executableName = args[0];
    size_t numberOfPages;

    try
    {
        auto helpInformation = getopt(args, config.required, "input|i",
                "The name of the file to read the data from.", &inputFileName,
                config.required, "output|o",
                "The name of the file to write the index to.",
                &outputFileName, "pages|p",
                "The number of pages to process. If set to 0, all pages are processed.",
                &numberOfPages);

        if (helpInformation.helpWanted)
        {
            defaultGetoptPrinter(format!"Usage: %s [options] \n\nOptions:"(executableName),
                    helpInformation.options);
            exit(0);
        }
    }
    catch (GetOptException e)
    {
        writeln("Skipping execution because there was an error while trying to parse the commandline options: ",
                e.msg);
        exit(1);
    }

    return Arguments(inputFileName, outputFileName, executableName, numberOfPages);
}
