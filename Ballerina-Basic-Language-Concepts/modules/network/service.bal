// Exercise 10
import ballerina/http;

type Product record {|
    readonly string name;
    decimal price;
|};

table<Product> key(name) productTable = table [
    {name: "Coke", price: 1.0},
    {name: "Pepsi", price: 2.0},
    {name: "Fanta", price: 1.5}
];

type ProductNotFound record {|
    *http:NotFound;
    string body;
|};

type DuplicateProduct record {|
    *http:Conflict;
    string body;
|};

type ProductsResponse record {|
    *http:Ok;
    Product[] body;
|};

service /store on new http:Listener(8008) {
    resource function get products/[string name]() returns Product|ProductNotFound {
        Product? p = productTable[name];
        if (p is Product) {
            return p;
        } else {
            ProductNotFound notFound = {body: "Product not found" + name};
            return notFound;
        }
    }

    resource function post products(@http:Payload Product product, boolean update) returns DuplicateProduct|http:Created|http:Ok {
        if (productTable.hasKey(product.name)) {
            if (update) {
                productTable.put(product);
                return http:OK;
            } else {
                DuplicateProduct duplicateProduct = {body: "Product already exists" + product.name};
                return duplicateProduct;
            }
        } else {
            productTable.add(product);
        }
        return http:CREATED;
    }

    resource function get products() returns ProductsResponse {
        return {
            body: from Product product in productTable
                select product
        };
    }
}
