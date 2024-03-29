import ballerina/persist as _;

public type Movie record {|
    readonly string id;
    string title;
    int year;
    Director director;
|};

public type Director record {|
    readonly string id;
    string name;
    int birthYear;
    Movie[] movies;
|};
