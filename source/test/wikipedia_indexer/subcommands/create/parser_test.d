module wikipedia_indexer.subcommands.create.parser_test;

unittest
{
    import std.file : read;
    import std.utf : byCodeUnit;
    import unit_threaded.should : shouldBeSameSetAs;
    import wikipedia_indexer.subcommands.create.parser : parse;

    // given
    auto data = cast(string) read("test_data/test_data_1.xml");

    // when
    auto result = data.byCodeUnit.parse(0);

    // then
    result.byKey.shouldBeSameSetAs(["Thrashbandicoot01", "Bananabones",
            "Beyond My Ken", "Nat965", "FoxyGrampa75", "Shivertimbers433", "Godsy",
            "CASSIOPEIA", "Tom.Reding", "Starcheerspeaksnewslostwars",
            "Kailash29792", "Алексей Густов", "Fucherastonmeym87"]);
    result["Thrashbandicoot01"][].shouldBeSameSetAs(["Colt Gilliam"]);
    result["Bananabones"][].shouldBeSameSetAs(["File:Kerang (Borough) Council 1994.jpg"]);
    result["Beyond My Ken"][].shouldBeSameSetAs(["Anarchism"]);
    result["Nat965"][].shouldBeSameSetAs(["No te puedes esconder"]);
    result["FoxyGrampa75"][].shouldBeSameSetAs(["Manchester North West"]);
    result["Shivertimbers433"][].shouldBeSameSetAs(["Riley Stearns"]);
    result["Godsy"][].shouldBeSameSetAs(["AccessibleComputing"]);
    result["CASSIOPEIA"][].shouldBeSameSetAs(["Draft:National Rally Championship"]);
    result["Tom.Reding"][].shouldBeSameSetAs(["AfghanistanPeople",
            "AfghanistanGeography", "AfghanistanHistory"]);
    result["Starcheerspeaksnewslostwars"][].shouldBeSameSetAs(["Beach Fossils (Album)"]);
    result["Kailash29792"][].shouldBeSameSetAs(["Ian Quinn (Agents of S.H.I.E.L.D.)"]);
    result["Алексей Густов"][].shouldBeSameSetAs(["Sofie Marmont-Nordlund"]);
    result["Fucherastonmeym87"][].shouldBeSameSetAs(["File:SDSS NGC 4305.jpg"]);
}
