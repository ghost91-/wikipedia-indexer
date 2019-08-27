module wikipedia_indexer.subcommands;

static immutable void function(string[])[string] subcommands;

shared static this()
{
    import wikipedia_indexer.subcommands.create : create;
    import wikipedia_indexer.subcommands.query : query;

    subcommands = ["create" : &create, "query" : &query];
}
