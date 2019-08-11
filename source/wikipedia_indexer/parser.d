module wikipedia_indexer.parser;

import dxml.parser;
import std.algorithm;
import std.range;
import std.typecons;
import std.experimental.logger;
import wikipedia_indexer.hashset;
import wikipedia_indexer.mmfile;

alias UsernameTitle = Tuple!(string, "username", string, "title");
alias usernameTitle = tuple!("username", "title");

auto parse(string inputFileName, size_t start, size_t end, size_t numberOfPages)
{
    HashSet!string[string] articlesPerAuthor;

    auto parserRange = MmFileRange(inputFileName)[start .. end].parseXML
        .splitter!(e => e.type == EntityType.elementStart && e.name.equal("page"))
        .filter!(r => r.hasElement!"title")
        .filter!(r => r.hasElement!"username")
        .map!(r => usernameTitle(r.getElement!"username", r.getElement!"title"))
        .enumerate(1).tee!((e) {
            if (e.index % 1_000 == 0)
                infof("Parsed pages: %s", e.index);
        });

    alias ParsedElementType = ElementType!(typeof(parserRange));
    scope merge = (ParsedElementType e) {
        articlesPerAuthor = articlesPerAuthor.merge(e.value);
    };

    if (numberOfPages > 0)
    {
        parserRange.take(numberOfPages).each!(merge);
    }
    else
    {
        parserRange.each!(merge);
    }

    return articlesPerAuthor;
}

bool hasElement(string element, R)(R r)
{
    return !r.find!(e => e.type == EntityType.elementStart && e.name.equal(element)).empty;
}

auto getElement(string element, R)(R r)
{
    return r.find!(e => e.type == EntityType.elementStart
            && e.name.equal(element)).drop(1).front.text.array;
}

auto merge(HashSet!string[string] a, UsernameTitle e)
{
    scope create = () => HashSet!string(e.title);
    scope update = (scope ref HashSet!string titles) {
        titles.add(e.title);
        return titles;
    };
    a.update(e.username, create, update);
    return a;
}
