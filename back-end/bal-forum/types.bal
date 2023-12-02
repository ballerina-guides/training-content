type UserRegistration record {
    string name;
    string email;
    string password;
};

type SuccessResponse record {
    string message;
};

type FailureResponse record {
    string error_message;
};

type UserCredentials record {
    string name;
    string password;
};

type UserLogin record {
    string message;
    string id;
};
