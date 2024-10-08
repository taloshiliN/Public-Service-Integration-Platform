import ballerina/crypto;
import ballerina/http;
import ballerina/io;

// Data structures for users and pension applications
type User record {
    int id;
    string firstName;
    string secondName;
    string username;
    string email;
    string password;
    ResidentialAddress address;
};

type ResidentialAddress record {
    string streetName;
    int poBox;
    string city;
    string country; // Added country for consistency with the UI form
};

type ApplicationForPension record {
    int id;
    string firstName;
    string surname;
    int nationalId;
    string dateOfBirth;
    string phoneNumber;
    string email;
    ResidentialAddress address;
    string proofOfAddress; // Path to the file
    string proofOfIncome; // Path to the file
    string bankName;
    string accountNumber;
    string bankStatement; // Path to the file
    string? maritalStatus; // Optional
    string? beneficiaryInfo; // Optional
    string? pensionFundDetails; // Optional
    string status; // Status of the application (e.g., Pending, Approved)
    string? rejectionReason; // Optional, populated when rejected
};

// Data structure for Income Tax Registration
type IncomeTaxRegistration record {
    int id;
    string firstName;
    string surname;
    string gender;
    ResidentialAddress address;
    string natureOfEmployment;
    string employmentStatus;
    string employersName;
    string bankConfirmationLetter;
    EmployerDetails employerDetails;
    string status;
    User user;
};

type EmployerDetails record {
    string postalAddress;
    string email;
    string phoneNumber;
};

type IDRenewal record {
    int id;
    string birthCertificate;
    string guardianBirthCertificate;
    string reasonForRenewal;
    string status; // Status of the renewal application
    User user;
};

isolated map<User> users = {};
isolated map<ApplicationForPension> pensionApplications = {};
isolated map<IncomeTaxRegistration> incomeTaxRegistrations = {};
isolated map<IDRenewal> idRenewals = {};
isolated int nextRenewalId = 1;
isolated int nextUserId = 1;
isolated int nextApplicationId = 1;
isolated int nextTaxRegistrationId = 1;

// Service to handle user data and applications
service / on new http:Listener(8080) {

    // POST Request: Endpoint to create a new user
    // This function creates a new user in the system.
    resource isolated function post createUser(http:Caller caller, http:Request req) returns error? {
        json payload = check req.getJsonPayload();
        json|error result = createUserLogic(payload);
        http:Response res = new;

        if result is json {
            string status = (check result.status).toString();
            if status == "success" {
                res.statusCode = 200;
                res.setJsonPayload({status: "success", message: "Successfully Registered!"});
                check caller->respond(res);
            } else {
                string message = (check result.message).toString();
                if message == "Email already exists" {
                    res.statusCode = 409;
                    res.setJsonPayload({status: "error", message: "Email already exists"});
                } else if message == "Username already exists" {
                    res.statusCode = 409;
                    res.setJsonPayload({status: "error", message: "Username already exists"});
                } else if message == "ID already exists" {
                    res.statusCode = 409;
                    res.setJsonPayload({status: "error", message: "ID already exists"});
                } else if message == "Invalid email format" {
                    res.statusCode = 400;
                    res.setJsonPayload({status: "error", message: "Invalid email format"});
                } else if message == "Password does not meet security requirements" {
                    res.statusCode = 400;
                    res.setJsonPayload({status: "error", message: "Password does not meet security requirements, must be 8 characters long and contain numbers and special charaters"});
                } else {
                    res.statusCode = 400;
                    res.setJsonPayload({status: "error", message: message});
                }
                check caller->respond(res);
            }
        } else if result is error {
            res.statusCode = 500;
            res.setJsonPayload({status: "error", message: "Internal server error"});
            check caller->respond(res);
        }
    }

    // POST Request: Endpoint to submit or check status of a Pension Application
    // This function allows a user to submit a pension application or check its status.
    resource isolated function post applyForPension(http:Caller caller, http:Request req) returns error? {
        var contentTypeResult = req.getHeader("Content-Type");
        string? contentType = contentTypeResult is string ? contentTypeResult : ();

        http:Response res = new;

        // Check if the content type is multipart/form-data
        if contentType is string && contentType.startsWith("multipart/form-data") {
            // Extract the form-data body
            var bodyPartsResult = req.getBodyParts();
            if bodyPartsResult is error {
                res.statusCode = 400;
                res.setPayload("Error while extracting multipart form-data");
                check caller->respond(res);
                return;
            }

            // Initialize variables to store form-data fields
            json formData = {};
            string proofOfAddressFilePath = "";
            string proofOfIncomeFilePath = "";
            string bankStatementFilePath = "";

            // Folder path where uploaded files will be saved
            string uploadDir = "./uploads/";

            // Process the parts
            foreach var part in bodyPartsResult {
                string partName = part.getContentDisposition().name;

                if partName == "formData" {
                    // Extract the form data as JSON
                    formData = check part.getJson();
                } else if partName == "proofOfAddress" {
                    // Save the proof of address file
                    proofOfAddressFilePath = uploadDir + "proofOfAddress_" + part.getContentDisposition().fileName;
                    byte[] fileContent = check part.getByteArray();
                    io:Error? fileWriteResult = io:fileWriteBytes(proofOfAddressFilePath, fileContent);
                    if fileWriteResult is io:Error {
                        res.statusCode = 500;
                        res.setPayload("Error saving proof of address file");
                        check caller->respond(res);
                        return;
                    }
                } else if partName == "proofOfIncome" {
                    // Save the proof of income file
                    proofOfIncomeFilePath = uploadDir + "proofOfIncome_" + part.getContentDisposition().fileName;
                    byte[] fileContent = check part.getByteArray();
                    io:Error? fileWriteResult = io:fileWriteBytes(proofOfIncomeFilePath, fileContent);
                    if fileWriteResult is io:Error {
                        res.statusCode = 500;
                        res.setPayload("Error saving proof of income file");
                        check caller->respond(res);
                        return;
                    }
                } else if partName == "bankStatement" {
                    // Save the bank statement file
                    bankStatementFilePath = uploadDir + "bankStatement_" + part.getContentDisposition().fileName;
                    byte[] fileContent = check part.getByteArray();
                    io:Error? fileWriteResult = io:fileWriteBytes(bankStatementFilePath, fileContent);
                    if fileWriteResult is io:Error {
                        res.statusCode = 500;
                        res.setPayload("Error saving bank statement file");
                        check caller->respond(res);
                        return;
                    }
                }
            }

            // Call the pension application logic
            json|error result = applyForPensionLogic(formData, proofOfAddressFilePath, proofOfIncomeFilePath, bankStatementFilePath);

            // Handle the result
            if result is json {
                string status = (check result.status).toString();
                if status == "success" {
                    res.statusCode = 200;
                    res.setJsonPayload({status: "success", message: "Pension application submitted successfully"});
                    check caller->respond(res);
                } else if status == "exists" {
                    string applicationStatus = (check result.applicationStatus).toString();
                    res.statusCode = 200;
                    res.setJsonPayload({status: "exists", applicationStatus: applicationStatus, message: "Pension application already exists."});
                    check caller->respond(res);
                } else {
                    string message = (check result.message).toString();
                    res.statusCode = 400;
                    res.setJsonPayload({status: "error", message: message});
                    check caller->respond(res);
                }
            } else if result is error {
                res.statusCode = 500;
                res.setJsonPayload({status: "error", message: "Internal server error while processing the application."});
                check caller->respond(res);
            }
        } else {
            res.statusCode = 415;
            res.setPayload("Unsupported Media Type or missing Content-Type header");
            check caller->respond(res);
        }
    }

    resource isolated function get checkApplication/[int id](http:Caller caller, http:Request req) returns error? {
        json|error result = checkApplicationLogic(id);

        http:Response res = new;
        if result is json {
            if result.status == "exists" {
                res.setJsonPayload(result);
                check caller->respond(res);
            } else {
                res.statusCode = 404;
                res.setJsonPayload(result);
                check caller->respond(res);
            }
        } else {
            res.statusCode = 500;
            res.setPayload("Internal server error");
            check caller->respond(res);
        }
    }

    // POST Request: Endpoint to submit or check status of Income Tax Registration
    // This function allows a user to submit an income tax registration or check its status.
    resource isolated function post applyForTax(http:Caller caller, http:Request req) returns error? {
        io:println("Received request to apply for tax registration");

        var contentTypeResult = req.getHeader("Content-Type");
        string? contentType = contentTypeResult is string ? contentTypeResult : ();
        io:println("Content-Type: ", contentType);

        http:Response res = new;

        // Check if the content type is JSON
        if contentType is string && contentType == "application/json" {
            // Extract the JSON payload
            json payload = check req.getJsonPayload();
            io:println("Payload received: ", payload.toJsonString());

            // Call the tax registration logic
            json|error result = applyForTaxLogic(payload);

            // Handle the result from the logic
            if result is json {
                string status = (check result.status).toString();
                io:println("Result Status: ", status);

                if status == "success" {
                    res.statusCode = 200;
                    res.setJsonPayload({status: "success", message: "Tax registration submitted successfully"});
                    check caller->respond(res);
                } else if status == "exists" {
                    string registrationStatus = (check result.registrationStatus).toString();
                    res.statusCode = 200;
                    res.setJsonPayload({status: "exists", registrationStatus: registrationStatus, message: "Tax registration already exists."});
                    check caller->respond(res);
                } else {
                    string message = (check result.message).toString();
                    res.statusCode = 400;
                    res.setJsonPayload({status: "error", message: message});
                    check caller->respond(res);
                }
            } else if result is error {
                // Internal error handling
                io:println("Error in tax logic: ", result);
                res.statusCode = 500;
                res.setJsonPayload({status: "error", message: "Internal server error while processing the application."});
                check caller->respond(res);
            }
        } else {
            io:println("Unsupported Media Type or missing Content-Type header");
            res.statusCode = 415;
            res.setPayload("Unsupported Media Type or missing Content-Type header");
            check caller->respond(res);
        }
    }

    // POST Request: Endpoint to submit or check status of ID Renewal
    // This function allows a user to submit an ID renewal application or check its status.
    resource isolated function post applyForIDRenewal(http:Caller caller, http:Request req) returns error? {
        json payload = check req.getJsonPayload();
        json response = check applyForIDRenewalLogic(payload);

        http:Response res = new;
        res.setJsonPayload(response);
        check caller->respond(res);
    }

    // POST Request: Endpoint to login a user
    // This function allows a user to log in.
    resource isolated function post login(http:Caller caller, http:Request req) returns error? {
        json payload = check req.getJsonPayload();

        // Call the logic function to handle the login process
        json|error result = loginUserLogic(payload);

        http:Response res = new;

        // Check if the result is a success or an error
        if result is json {
            string status = (check result.status).toString();

            if status == "success" {
                // If login is successful, include userId in the response
                json responsePayload = {
                    status: "success",
                    message: "Login Successful",
                    userId: check result.userId // Include userId in the response
                };
                res.setJsonPayload(responsePayload);
                res.statusCode = 200;
                check caller->respond(res);
            } else if status == "error" {
                string message = (check result.message).toString();

                if message == "Invalid credentials" {
                    res.statusCode = 401;
                    res.setPayload("Error: Invalid credentials");
                } else {
                    res.statusCode = 400;
                    res.setPayload("Error: " + message);
                }

                check caller->respond(res);
            }
        } else if result is error {
            // Handle unexpected errors
            res.statusCode = 500;
            res.setPayload("Internal server error");
            check caller->respond(res);
        }
    }

    // PUT Request: Endpoint to change password with current password validation
    // This function allows a user to change their password.
    resource isolated function put changePassword(http:Caller caller, http:Request req) returns error? {
        json payload = check req.getJsonPayload();
        json response = check changePasswordLogic(payload);

        http:Response res = new;
        res.setJsonPayload(response);
        check caller->respond(res);
    }

    // PUT Request: Endpoint to change ID with current password validation
    // This function allows a user to change their ID after validating their current password.
    resource isolated function put changeID(http:Caller caller, http:Request req) returns error? {
        json payload = check req.getJsonPayload();
        json response = check changeIDLogic(payload);

        http:Response res = new;
        res.setJsonPayload(response);
        check caller->respond(res);
    }

    // PUT Request: Endpoint to change email with current password validation
    // This function allows a user to change their email after validating their current password.
    resource isolated function put changeEmail(http:Caller caller, http:Request req) returns error? {
        json payload = check req.getJsonPayload();
        json response = check changeEmailLogic(payload);

        http:Response res = new;
        res.setJsonPayload(response);
        check caller->respond(res);
    }

    // PUT Request: Endpoint to change username with current password validation
    // This function allows a user to change their username after validating their current password.
    resource isolated function put changeUsername(http:Caller caller, http:Request req) returns error? {
        json payload = check req.getJsonPayload();
        json response = check changeUsernameLogic(payload);

        http:Response res = new;
        res.setJsonPayload(response);
        check caller->respond(res);
    }

    // GET Request: Endpoint to get user profile without password validation
    // This function retrieves a user's profile based on their username (passed as a query parameter).
    resource isolated function get getProfile(http:Caller caller, http:Request req) returns error? {
        string? idParam = req.getQueryParamValue("id");
        if idParam is string {
            int|error userId = 'int:fromString(idParam); // Convert string id to int
            if userId is int {
                json response = getProfileLogic(userId);
                http:Response res = new;
                res.setJsonPayload(response);
                check caller->respond(res);
            } else {
                http:Response res = new;
                res.setJsonPayload({status: "error", message: "Invalid ID format"});
                check caller->respond(res);
            }
        } else {
            http:Response res = new;
            res.setJsonPayload({status: "error", message: "ID query parameter missing"});
            check caller->respond(res);
        }
    }

    // GET Request: Endpoint to check tax status
    resource function get checkTaxRegistration/[int id](http:Caller caller, http:Request req) returns error? {
        json|error result = checkTaxRegistrationLogic(id);

        http:Response res = new;
        if result is json {
            if result.status == "exists" {
                res.setJsonPayload(result);
                check caller->respond(res);
            } else {
                res.statusCode = 404;
                res.setJsonPayload(result);
                check caller->respond(res);
            }
        } else {
            res.statusCode = 500;
            res.setPayload("Internal server error");
            check caller->respond(res);
        }
    }

    resource function get checkIDRenewalStatus/[int userId](http:Caller caller, http:Request req) returns error? {
        json|error result = check checkIDRenewalStatusLogic(userId);

        http:Response res = new;
        if result is json {
            if result.status == "exists" {
                res.setJsonPayload(result);
                check caller->respond(res);
            } else {
                res.statusCode = 404;
                res.setJsonPayload(result);
                check caller->respond(res);
            }
        } else {
            res.statusCode = 500;
            res.setPayload("Internal server error");
            check caller->respond(res);
        }
    }

}

// Logic for checking tax registration status
isolated function checkIDRenewalStatusLogic(int userId) returns json|error {
    // Lock to check for existing ID renewal applications
    lock {
        foreach var [_, renewal] in idRenewals.entries() {
            if renewal.user.id == userId {
                // Return the status of the existing renewal application
                return {
                    "status": "exists",
                    "renewalStatus": renewal.status
                };
            }
        }
    }
    // If no renewal application exists, return an error
    return {
        "status": "not found",
        "message": "No ID renewal application found for this user."
    };
}

isolated function checkTaxRegistrationLogic(int userId) returns json|error {
    // Lock to check for existing tax registrations
    lock {
        foreach var [_, registration] in incomeTaxRegistrations.entries() {
            if registration.user.id == userId {
                // Return the status of the existing registration
                return {
                    "status": "exists",
                    "registrationStatus": registration.status
                };
            }
        }
    }
    // If no registration exists, return an error
    return {"status": "not found", "message": "No tax registration found for this user."};

}

// Isolated logic functions

isolated function checkApplicationLogic(int id) returns json|error {
    // Lock to check for existing pension applications
    lock {
        foreach var [_, application] in pensionApplications.entries() {
            if application.id == id {
                // Return the status of the existing application
                return {
                    "status": "exists",
                    "applicationStatus": application.status
                };
            }
        }
    }
    // If no application exists, return an error
    return {"status": "not found", "message": "No pension application found for this user."};
}

isolated function applyForTaxLogic(json payload) returns json|error {
    io:println("Starting tax registration logic");

    // Check if the essential fields are present
    if payload.userId is int && payload.firstName is string && payload.surname is string && payload.gender is string {
        int userId = check payload.userId;
        io:println("Processing registration for userId: ", userId);

        // Check for existing tax registrations
        lock {
            foreach var [_, registration] in incomeTaxRegistrations.entries() {
                if registration.user.id == userId {
                    io:println("User already registered: ", registration.user.id);
                    return {
                        "status": "exists",
                        "registrationStatus": registration.status
                    };
                }
            }
        }

        // Get user details
        User? user;
        lock {
            user = users[userId.toString()].clone();
            io:println("User details found: ", user.clone());
        }

        if user is User {
            IncomeTaxRegistration newRegistration;

            // Safely check if nested fields like address are present
            json address = payload.address is json ? check payload.address : {"streetName": "", "poBox": "", "city": ""};
            json employerDetails = payload.employerDetails is json ? check payload.employerDetails : {"postalAddress": "", "email": "", "phoneNumber": ""};

            lock {
                newRegistration = {
                    id: nextTaxRegistrationId + 1,
                    firstName: check payload.firstName,
                    surname: check payload.surname,
                    gender: check payload.gender,
                    address: {
                        streetName: check address.streetName,
                        poBox: check address.poBox,
                        city: check address.city,
                        country: ""
                    },
                    natureOfEmployment: check payload.natureOfEmployment,
                    employmentStatus: check payload.employmentStatus,
                    employersName: check payload.employersName,
                    bankConfirmationLetter: check payload.bankConfirmationLetter,
                    employerDetails: {
                        postalAddress: check employerDetails.postalAddress,
                        email: check employerDetails.email,
                        phoneNumber: check employerDetails.phoneNumber
                    },
                    status: "Pending",
                    user: user.clone()
                };
                io:println("New tax registration created with ID: ", newRegistration.id);
                nextTaxRegistrationId += 1;
            }

            lock {
                incomeTaxRegistrations[newRegistration.id.toString()] = newRegistration.clone();
                io:println("New tax registration stored with ID: ", newRegistration.id);
            }

            return {status: "success", message: "Tax registration submitted successfully"};
        } else {
            io:println("User not found for userId: ", userId);
            return {status: "error", message: "User not found"};
        }
    } else {
        io:println("Missing or invalid required fields in payload: ", payload.toJsonString());
        return {status: "error", message: "Missing or invalid required fields"};
    }
}

isolated function changeEmailLogic(json payload) returns json|error {
    string currentPassword = check payload.currentPassword;
    string newEmail = check payload.newEmail;

    User? optionalUser;

    // Lock to validate user's password and clone the user for safe manipulation
    lock {
        optionalUser = validateUserByPassword(currentPassword);
    }

    if optionalUser is User {
        User user = optionalUser.clone(); // Now it's safe to call clone() on the non-optional User type

        // Lock to check if the new email already exists in the system
        lock {
            foreach var [_, existingUser] in users.entries() {
                if existingUser.email == newEmail {
                    return {status: "error", message: "Email already exists"};
                }
            }
        }

        // Update the cloned user's email
        user.email = newEmail;

        // Lock to update the users map with the modified user data
        lock {
            users[user.id.toString()] = user.clone(); // Write the modified user clone back to the original map
        }

        return {status: "success", message: "Email changed successfully"};
    } else {
        return {status: "error", message: "Incorrect password"};
    }
}

isolated function loginUserLogic(json payload) returns json|error {
    string username = check payload.username;
    string password = check payload.password;

    User? foundUser = findUserByUsername(username);

    if foundUser is User {
        byte[] hashedPassword = crypto:hashSha256(password.toBytes());

        // Check if the provided password matches the stored password
        if hashedPassword.toBase16() == foundUser.password {
            // Return success along with the userId
            return {status: "success", message: "Login successful", userId: foundUser.id};
        } else {
            return {status: "error", message: "Invalid credentials"};
        }
    } else {
        return {status: "error", message: "User not found"};
    }
}

isolated function applyForPensionLogic(json formData, string proofOfAddressFilePath, string proofOfIncomeFilePath, string bankStatementFilePath) returns json|error {

    // Ensure formData is a map<json>
    if formData is map<json> {
        // Safely extract userId
        if formData.hasKey("userId") && formData["userId"] is int {
            int userId = check formData["userId"];
            io:println("Processing pension application for userId: ", userId); // Log userId

            // Lock to check for existing pension applications
            lock {
                foreach var [_, application] in pensionApplications.entries() {
                    if application.id == userId {
                        // Return the status of the existing application
                        return {status: "exists", applicationStatus: application.status};
                    }
                }
            }

            // Extract other fields safely
            string firstName = formData.hasKey("firstName") && formData["firstName"] is string ? check formData["firstName"].toString() : "";
            string surname = formData.hasKey("surname") && formData["surname"] is string ? check formData["surname"].toString() : "";
            int nationalId = formData.hasKey("nationalId") && formData["nationalId"] is string ? check int:fromString(formData["nationalId"].toString()) : 0;
            string dateOfBirth = formData.hasKey("dob") && formData["dob"] is string ? check formData["dob"].toString() : "";
            string phoneNumber = formData.hasKey("phoneNumber") && formData["phoneNumber"] is string ? check formData["phoneNumber"].toString() : "";
            string email = formData.hasKey("email") && formData["email"] is string ? check formData["email"].toString() : "";

            // Access residential address fields
            json address = formData["address"];
            string streetName = address is map<json> && address.hasKey("streetName") ? check address["streetName"].toString() : "";
            int poBox = address is map<json> && address.hasKey("poBox") ? check int:fromString(address["poBox"].toString()) : 0;
            string city = address is map<json> && address.hasKey("city") ? check address["city"].toString() : "";
            string country = address is map<json> && address.hasKey("country") ? check address["country"].toString() : "";

            // Access bank information
            json bankInfo = formData["bankInfo"];
            string bankName = bankInfo is map<json> && bankInfo.hasKey("bankName") ? check bankInfo["bankName"].toString() : "";
            string accountNumber = bankInfo is map<json> && bankInfo.hasKey("accountNumber") ? check bankInfo["accountNumber"].toString() : "";

            // Optional fields
            string? maritalStatus = formData.hasKey("maritalStatus") && formData["maritalStatus"] is string ? check formData["maritalStatus"].toString() : ();
            string? beneficiaryInfo = formData.hasKey("beneficiaryInfo") && formData["beneficiaryInfo"] is string ? check formData["beneficiaryInfo"].toString() : ();
            string? pensionFundDetails = formData.hasKey("pensionFundDetails") && formData["pensionFundDetails"] is string ? check formData["pensionFundDetails"].toString() : ();

            // Create the application
            ApplicationForPension newApplication;

            // Lock to increment the next application ID
            lock {
                newApplication = {
                    id: nextApplicationId + 1,
                    firstName: firstName,
                    surname: surname,
                    nationalId: nationalId,
                    dateOfBirth: dateOfBirth,
                    phoneNumber: phoneNumber,
                    email: email,
                    address: {
                        streetName: streetName,
                        poBox: poBox,
                        city: city,
                        country: country
                    },
                    proofOfAddress: proofOfAddressFilePath,  // Pass file path
                    proofOfIncome: proofOfIncomeFilePath,  // Pass file path
                    bankName: bankName,
                    accountNumber: accountNumber,
                    bankStatement: bankStatementFilePath,  // Pass file path
                    maritalStatus: maritalStatus,
                    beneficiaryInfo: beneficiaryInfo,
                    pensionFundDetails: pensionFundDetails,
                    status: "Pending",
                    rejectionReason: ()
                };
                nextApplicationId += 1; // Increment the application ID
            }

            // Lock to store the new pension application in the map
            lock {
                pensionApplications[newApplication.id.toString()] = newApplication.clone();
            }

            return {status: "success", message: "Pension application submitted successfully"};
        } else {
            io:println("Error: userId missing or invalid");
            return {status: "error", message: "Invalid or missing userId"};
        }
    } else {
        io:println("Error: formData is not a valid map<json>");
        return {status: "error", message: "Invalid formData"};
    }
}

isolated function changeIDLogic(json payload) returns json|error {
    string currentPassword = check payload.currentPassword;
    int newID = check payload.newID;

    User? optionalUser;

    // Lock to validate user's password and get the user for safe manipulation
    lock {
        optionalUser = validateUserByPassword(currentPassword);
    }

    if optionalUser is User {
        User user = optionalUser.clone(); // Now it's safe to call clone() on the non-optional User type

        // Lock to check if the new ID already exists in the system
        lock {
            foreach var [_, existingUser] in users.entries() {
                if existingUser.id == newID {
                    return {status: "error", message: "ID already exists"};
                }
            }
        }

        // Lock to remove the user with the old ID
        lock {
            _ = users.remove(user.id.toString());
        }

        // Update the cloned user's ID
        user.id = newID;

        // Lock to update the users map with the modified user data using the new ID
        lock {
            users[newID.toString()] = user.clone(); // Write the modified user clone back to the original map
        }

        return {status: "success", message: "ID changed successfully"};
    } else {
        return {status: "error", message: "Incorrect password"};
    }
}

isolated function applyForIDRenewalLogic(json payload) returns json|error {
    int userId = check payload.userId;

    // Lock to check for existing ID renewal applications
    lock {
        foreach var [_, renewal] in idRenewals.entries() {
            if renewal.user.id == userId {
                return {status: "exists", renewalStatus: renewal.status};
            }
        }
    }

    User? user;

    // Lock to access the users map and clone the user
    lock {
        user = users[userId.toString()].clone();
    }

    if user is User {
        IDRenewal newRenewal;

        // Lock to create a new ID renewal application and increment the next ID
        lock {
            newRenewal = {
                id: nextRenewalId + 1,
                birthCertificate: check payload.birthCertificate,
                guardianBirthCertificate: check payload.guardianBirthCertificate,
                reasonForRenewal: check payload.reasonForRenewal,
                status: "Pending",
                user: user.clone()
            };
            nextRenewalId += 1;
        }

        // Lock to insert the new ID renewal into the idRenewals map
        lock {
            idRenewals[newRenewal.id.toString()] = newRenewal.clone();
        }

        return {status: "success", message: "ID Renewal submitted successfully"};
    } else {
        return {status: "error", message: "User not found"};
    }
}

isolated function changeUsernameLogic(json payload) returns json|error {
    string currentPassword = check payload.currentPassword;
    string newUsername = check payload.newUsername;

    User? optionalUser;

    // Lock to validate user's password and get the user for safe manipulation
    lock {
        optionalUser = validateUserByPassword(currentPassword);
    }

    if optionalUser is User {
        User user = optionalUser.clone(); // Now it's safe to call clone() on the non-optional User type

        // Lock to check if the new username already exists in the system
        lock {
            foreach var [_, existingUser] in users.entries() {
                if existingUser.username == newUsername {
                    return {status: "error", message: "Username already exists"};
                }
            }
        }

        // Update the cloned user's username
        user.username = newUsername;

        // Lock to update the users map with the modified user data
        lock {
            users[user.id.toString()] = user.clone(); // Write the modified user clone back to the original map
        }

        return {status: "success", message: "Username changed successfully"};
    } else {
        return {status: "error", message: "Incorrect password"};
    }
}

isolated function createUserLogic(json payload) returns json|error {
    int userId = check payload.id;
    string firstName = check payload.firstName;
    string secondName = check payload.secondName;
    string email = check payload.email;
    string username = check payload.username;
    string password = check payload.password;
    string streetName = check payload.address.streetName;
    int poBox = check payload.address.poBox;
    string city = check payload.address.city;

    // Email validation using regex
    if !isValidEmail(email) {
        return {status: "error", message: "Invalid email format"};
    }

    // Password validation
    if !isValidPassword(password) {
        return {status: "error", message: "Password does not meet security requirements"};
    }

    // Lock to check if the provided ID, email, or username already exists
    lock {
        foreach var [_, user] in users.entries() {
            if user.id == userId {
                return {status: "error", message: "ID already exists"};
            } else if user.email == email {
                return {status: "error", message: "Email already exists"};
            } else if user.username == username {
                return {status: "error", message: "Username already exists"};
            }
        }
    }

    // Hash the password for security
    byte[] hashedPassword = crypto:hashSha256(password.toBytes());

    // Create a new user object
    User newUser = {
        id: userId,
        firstName: firstName,
        secondName: secondName,
        email: email,
        username: username,
        password: hashedPassword.toBase16(),
        address: {
            streetName: streetName,
            poBox: poBox,
            city: city
            , country: ""}
    };

    // Lock to insert the new user into the users map
    lock {
        users[userId.toString()] = newUser.clone(); // Store the new user
    }

    return {status: "success"};
}

isolated function getProfileLogic(int userId) returns json {
    User? user = findUserById(userId); // Use userId directly now
    if user is User {
        json profile = {
            "firstName": user.firstName,
            "secondName": user.secondName,
            "id": user.id,
            "email": user.email,
            "address": {
                "streetName": user.address.streetName,
                "poBox": user.address.poBox,
                "city": user.address.city
            }
        };
        return {status: "success", profile: profile};
    } else {
        return {status: "error", message: "User not found"};
    }
}

isolated function findUserById(int id) returns User? {
    User? foundUser = (); // Initialize to nil

    // Lock to safely iterate through the users map and clone the found user
    lock {
        foreach var [_, user] in users.entries() {
            if user.id == id {
                foundUser = user.clone(); // Clone the user before returning
                break;
            }
        }
    }

    return foundUser; // Return the found user or nil if not found
}

isolated function changePasswordLogic(json payload) returns json|error {
    string currentPassword = check payload.currentPassword;
    string newPassword = check payload.newPassword;

    User? optionalUser;

    // Lock to validate user's password and clone the user for safe manipulation
    lock {
        optionalUser = validateUserByPassword(currentPassword);
    }

    if optionalUser is User {
        User user = optionalUser.clone(); // Now it's safe to call clone() on the non-optional User type

        // Hash the new password and update the cloned user's password
        byte[] hashedNewPassword = crypto:hashSha256(newPassword.toBytes());
        user.password = hashedNewPassword.toBase16();

        // Lock to update the users map with the modified user data
        lock {
            users[user.id.toString()] = user.clone(); // Write the modified user clone back to the original map
        }

        return {status: "success", message: "Password changed successfully"};
    } else {
        return {status: "error", message: "Incorrect password"};
    }
}

//Helper function
isolated function isValidEmail(string email) returns boolean {
    // Modified regex pattern to be more flexible
    return email.matches(re `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`);
}

isolated function isValidPassword(string password) returns boolean {
    if password.length() < 8 {
        return false;
    }

    boolean hasUpperCase = false;
    boolean hasLowerCase = false;
    boolean hasNumber = false;
    boolean hasSpecialChar = false;

    // Iterate over the string characters directly
    foreach var c in password {
        if c.matches(re `[A-Z]`) { // Check if the character is an uppercase letter
            hasUpperCase = true;
        } else if c.matches(re `[a-z]`) { // Check if the character is a lowercase letter
            hasLowerCase = true;
        } else if c.matches(re `[0-9]`) { // Check if the character is a digit
            hasNumber = true;
        } else if c.matches(re `[!@#$%^&*()\-_=+<>?]`) { // Check if the character is a special character
            hasSpecialChar = true;
        }
    }

    // Ensure the password meets all the criteria
    return hasUpperCase && hasLowerCase && hasNumber && hasSpecialChar;
}

isolated function findUserByUsername(string username) returns User? {
    User? foundUser = (); // Initialize to nil

    // Lock to safely iterate through the users map and clone the found user
    lock {
        foreach var [_, user] in users.entries() {
            if user.username == username {
                foundUser = user.clone(); // Clone the user before returning
                break;
            }
        }
    }

    return foundUser; // Return the found user or nil if not found
}

isolated function validateUserByPassword(string password) returns User? {
    byte[] hashedPassword = crypto:hashSha256(password.toBytes());
    User? foundUser = (); // Initialize to nil

    // Lock to safely iterate through the users map and clone the found user
    lock {
        foreach var [_, user] in users.entries() {
            if user.password == hashedPassword.toBase16() {
                foundUser = user.clone(); // Clone the user before returning
                break;
            }
        }
    }

    return foundUser; // Return the found user or nil if not found
}

