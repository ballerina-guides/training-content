// Exercise 03
import ballerina/http;

type Product record {|
    readonly string name;
    decimal price;
|};

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

isolated service /store on new http:Listener(8009) {

    private table<Product> key(name) productTable = table [
        {name: "Coke", price: 1.0},
        {name: "Pepsi", price: 2.0},
        {name: "Fanta", price: 1.5}
    ];
    isolated resource function get products/[string name]() returns Product|ProductNotFound {
        Product? p = ();
        lock {
            p = self.productTable[name].clone();
        }

        if (p is Product) {
            return p.clone();
        } else {
            ProductNotFound notFound = {
                body: "Product not found" + name
            };
            return notFound;
        }
    }

    isolated resource function post products(@http:Payload Product product, boolean update) returns DuplicateProduct|http:Created|http:Ok {
        lock {
            if (self.productTable.hasKey(product.name)) {
                if (update) {
                    lock {
                        self.productTable.put(product.clone());
                    }
                    return http:OK;
                } else {
                    DuplicateProduct & readonly duplicateProduct = {
                        body: "Product already exists" + product.name
                    };
                    return duplicateProduct;
                }
            } else {
                self.productTable.add(product.clone());
            }
        }
        return http:CREATED;
    }

    isolated resource function get products() returns ProductsResponse {
        lock {
            ProductsResponse response = {
                body: from Product product in self.productTable
                    select product
            };
            return response.clone();
        }
    }
}

