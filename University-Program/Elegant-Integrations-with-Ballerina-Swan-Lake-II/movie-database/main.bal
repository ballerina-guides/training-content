import movie_database.datasource;

import ballerina/graphql;

final datasource:Client dbClient = check new;

@graphql:ServiceConfig {
    graphiql: {
        enabled: true
    },
    maxQueryDepth: 4
}
service on new graphql:Listener(9090) {

    resource function get movies() returns Movie[]|error {
        stream<datasource:Movie, error?> movieStream = dbClient->/movies();
        return from datasource:Movie m in movieStream select new (m);
    }

    resource function get directors() returns Director[]|error {
        stream<datasource:Director, error?> directorStream = dbClient->/directors();
        return from datasource:Director d in directorStream select new (d);
    }
}

service class Movie {
    private final readonly & datasource:Movie movie;

    function init(datasource:Movie movie) {
        self.movie = movie.cloneReadOnly();
    }

    resource function get id() returns @graphql:ID string => self.movie.id;

    resource function get title() returns string => self.movie.title;

    resource function get year() returns int => self.movie.year;

    resource function get director() returns Director|error {
        datasource:Director director = check dbClient->/directors/[self.movie.directorId];
        return new (director);
    }
}

service class Director {
    private final readonly & datasource:Director director;

    function init(datasource:Director director) {
        self.director = director.cloneReadOnly();
    }

    resource function get id() returns @graphql:ID string => self.director.id;

    resource function get name() returns string => self.director.name;

    resource function get birthYear() returns int => self.director.birthYear;

    resource function get movies() returns Movie[]|error {
        record {|
            datasource:Movie[] movies;
        |} result = check dbClient->/directors/[self.director.id];
        return from datasource:Movie m in result.movies select new (m);
    }
}
