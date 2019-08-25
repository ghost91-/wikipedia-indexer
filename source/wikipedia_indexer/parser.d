module wikipedia_indexer.parser;

import dxml.parser;
import std.algorithm;
import std.range;
import std.traits;
import std.typecons;
import std.experimental.logger;
import wikipedia_indexer.hashset;

public:

auto parse(R)(R input, size_t numberOfPages)
        if (isForwardRange!R && isSomeChar!(ElementType!R))
{
    alias stringType = immutable(ElementType!R)[];

    HashSet!stringType[stringType] articlesPerAuthor;

    auto parserRange = input.parseXML.splitAtElement("page")
        .map!(findTitleAndLatestRevisionForPage)
        .filter!(titleAndRevision => titleAndRevision.revision.hasElement("username"))
        .map!(titleAndRevision => tuple!("username",
                "title")(titleAndRevision.revision.findElement("username"), titleAndRevision.title))
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

///
unittest
{
    import fluent.asserts : should;
    import std.utf : byCodeUnit;

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
    result.byKey.should.containOnly(["SomeOtherUserName", "SomeUserName"]);
    result["SomeOtherUserName"][].should.containOnly(["SomeTitle"]);
    result["SomeUserName"][].should.containOnly(["SomeOtherTitle"]);
}

private:

bool hasElement(R)(R r, string element)
{
    return r.canFind!(e => e.type == EntityType.elementStart && e.name.equal(element));
}

auto findElement(R)(R r, string element)
{
    return r.find!(e => e.type == EntityType.elementStart
            && e.name.equal(element)).drop(1).front.text.array;
}

auto splitAtElement(R)(R r, string element)
{
    return r.splitter!(e => e.type == EntityType.elementStart && e.name.equal(element)).drop(1);
}

auto findTitleAndLatestRevisionForPage(R)(R page)
{
    immutable title = page.findElement("title");
    auto revision = page.splitAtElement("revision")
        .maxElement!(revision => revision.findElement("timestamp"));

    return tuple!("title", "revision")(title, revision);
}

auto merge(T)(HashSet!T[T] existingEntries, Tuple!(T, "username", T, "title") newEntry)
{
    scope create = () => HashSet!T(newEntry.title);
    scope update = (scope ref HashSet!T titles) {
        titles.add(newEntry.title);
        return titles;
    };
    existingEntries.update(newEntry.username, create, update);
    return existingEntries;
}

unittest
{
    import fluent.asserts : should;
    import std.file : read;
    import std.utf : byCodeUnit;

    // given
    auto data = cast(string) read("test_data/test_data_1.xml");

    // when
    auto result = data.byCodeUnit.parse(0);

    // then
    result.byKey.should.containOnly(["Thrashbandicoot01", "Bananabones",
            "Beyond My Ken", "Nat965", "FoxyGrampa75", "Shivertimbers433",
            "Godsy", "CASSIOPEIA", "Tom.Reding", "Starcheerspeaksnewslostwars",
            "Kailash29792", "Алексей Густов", "Fucherastonmeym87"]);
    result["Thrashbandicoot01"][].should.containOnly(["Colt Gilliam"]);
    result["Bananabones"][].should.containOnly(["File:Kerang (Borough) Council 1994.jpg"]);
    result["Beyond My Ken"][].should.containOnly(["Anarchism"]);
    result["Nat965"][].should.containOnly(["No te puedes esconder"]);
    result["FoxyGrampa75"][].should.containOnly(["Manchester North West"]);
    result["Shivertimbers433"][].should.containOnly(["Riley Stearns"]);
    result["Godsy"][].should.containOnly(["AccessibleComputing"]);
    result["CASSIOPEIA"][].should.containOnly(["Draft:National Rally Championship"]);
    result["Tom.Reding"][].should.containOnly(["AfghanistanPeople",
            "AfghanistanGeography", "AfghanistanHistory"]);
    result["Starcheerspeaksnewslostwars"][].should.containOnly(["Beach Fossils (Album)"]);
    result["Kailash29792"][].should.containOnly(["Ian Quinn (Agents of S.H.I.E.L.D.)"]);
    result["Алексей Густов"][].should.containOnly(["Sofie Marmont-Nordlund"]);
    result["Fucherastonmeym87"][].should.containOnly(["File:SDSS NGC 4305.jpg"]);
}
