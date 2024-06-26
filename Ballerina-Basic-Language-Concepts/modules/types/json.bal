import ballerina/io;

// Exercise 09
public function jsonValues() {
    json j1 = {name: "Waruna", age: 30};
    json j2 = 3;
    json j3 = {name: "Waruna", age: 30, city: "Colombo"};
    matchJson(j1);
    matchJson(j2);
    matchJson(j3);
}

function matchJson(json j) {
    match j {
        2|3 => {
            io:println(`Matched json: 2 or 3 for ${j}`);
        }
        var {name, age, city} => {
            io:println(`Matched json: name = ${name}, age = ${age}, city = ${city} for ${j}`);
        }
        var {name, age} => {
            io:println(`Matched json: name = ${name}, age = ${age} for ${j}`);
        }
        _ => {
            io:println(`Json did not match for ${j}`);
        }
    }
}
