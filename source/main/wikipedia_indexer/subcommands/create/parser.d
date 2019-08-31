module wikipedia_indexer.subcommands.create.parser;

import dxml.parser;
import std.algorithm;
import std.range;
import std.traits : isSomeChar;
import std.typecons;
import wikipedia_indexer.subcommands.create.hashset : HashSet;

package:

auto parse(R)(R input, size_t numberOfPages)
        if (isForwardRange!R && isSomeChar!(ElementType!R))
{
    import std.experimental.logger : tracef;

    alias stringType = immutable(ElementType!R)[];

    HashSet!stringType[stringType] articlesPerAuthor;

    auto parserRange = input.parseXML.splitAtElement("page").map!(parsePage)
        .enumerate(1).tee!((enumeratedPage) {
            if (enumeratedPage.index % 1_000 == 0)
                tracef("Parsed pages: %s", enumeratedPage.index);
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

///
unittest
{
    import std.utf : byCodeUnit;
    import unit_threaded.should : shouldBeSameSetAs;

    // given
    auto input = `<mediawiki>
    <page>
        <title>SomeTitle</title>
        <revision>
            <timestamp>2018-08-14T06:47:24Z</timestamp>
            <contributor>
                <username>SomeUserName</username>
            </contributor>
        </revision>
        <revision>
            <timestamp>2018-08-15T07:39:25Z</timestamp>
            <contributor>
                <username>SomeOtherUserName</username>
            </contributor>
        </revision>
    </page>
        <page>
        <title>SomeOtherTitle</title>
        <revision>
            <timestamp>2019-07-23T15:42:12Z</timestamp>
            <contributor>
                <username>SomeUserName</username>
            </contributor>
        </revision>
        <revision>
            <timestamp>2019-06-15T08:21:13Z</timestamp>
            <contributor>
                <username>SomeThirsUserName</username>
            </contributor>
        </revision>
    </page>
</mediawiki>`.byCodeUnit;

    // when
    auto result = input.parse(0);

    // then
    result.byKey.shouldBeSameSetAs(["SomeOtherUserName", "SomeUserName"]);
    result["SomeOtherUserName"][].shouldBeSameSetAs(["SomeTitle"]);
    result["SomeUserName"][].shouldBeSameSetAs(["SomeOtherTitle"]);
}

private:

auto findElement(R)(R r, string element)
{
    return r.find!(e => e.type == EntityType.elementStart
            && e.name.equal(element)).drop(1).front.text.array;
}

auto splitAtElement(R)(R r, string element)
{
    return r.splitter!(e => e.type == EntityType.elementStart && e.name.equal(element)).drop(1);
}

struct Page
{
    string title;
    Revision latestRevision;

    static struct Revision
    {
        string author;
        string _body;
    }
}

Page parsePage(R)(R pageXML)
{
    immutable title = pageXML.findElement("title");
    auto latestRevisionXML = pageXML.splitAtElement("revision")
        .maxElement!(revision => revision.findElement("timestamp"));
    immutable author = latestRevisionXML.findElement("username");
    return Page(title, Page.Revision(author, null));
}

auto merge(T)(HashSet!T[T] existingEntries, Page newEntry)
{
    scope create = () => HashSet!T(newEntry.title);
    scope update = (scope ref HashSet!T titles) {
        titles.add(newEntry.title);
        return titles;
    };
    existingEntries.update(newEntry.latestRevision.author, create, update);
    return existingEntries;
}
