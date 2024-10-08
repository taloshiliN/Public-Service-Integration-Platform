import ballerina/http;
import ballerina/io;

final http:Client clientEP = check new ("http://localhost:8080");

public function main() returns error? {
    io:println("****** Public Service Integration Platform ******");

    // Main menu loop for account creation or login
    while true {
        io:println("\nMenu:");
        io:println("1. Create Account");
        io:println("2. Login");
        io:println("0. Exit");

        string option = io:readln("Enter your choice: ");

        match option {
            "1" => {
                check createAccount();
            }
            "2" => {
                boolean isLoggedIn = check login();
                if isLoggedIn {
                    // Proceed to the logged-in menu
                }
            }
            "0" => {
                io:println("Exiting the system. Goodbye!");
                break;
            }
            _ => {
                io:println("Invalid choice. Please try again.");
            }
        }
    }
}

// Function to handle user account creation
function createAccount() returns error? {
    // Collect user input for account creation
    string userIdInput = io:readln("Enter your ID: ");
    int userId = check 'int:fromString(userIdInput);
    string firstName = io:readln("Enter first name: ");
    string secondName = io:readln("Enter second name: ");
    string email = io:readln("Enter email: ");
    string username = io:readln("Enter username: ");
    string password = io:readln("Enter password: ");
    string streetName = io:readln("Enter street name: ");
    string poBoxInput = io:readln("Enter PO Box (numeric): ");
    int poBox = check 'int:fromString(poBoxInput);
    string city = io:readln("Enter city: ");

    // Construct the JSON payload for account creation
    json payload = {
        "id": userId,
        "firstName": firstName,
        "secondName": secondName,
        "email": email,
        "username": username,
        "password": password,
        "address": {
            "streetName": streetName,
            "poBox": poBox,
            "city": city
        }
    };

    // Send POST request to create user
    http:Response|error response = clientEP->post("/createUser", payload);

    if response is http:Response {
        json result = check response.getJsonPayload();
        io:println("Response: ", result.toString());
    } else {
        io:println("Error: Failed to create account.");
    }
}

// Function to handle user login
function login() returns boolean|error {
    // Collect user input for login
    string username = io:readln("Enter username: ");
    string password = io:readln("Enter password: ");

    // Construct the JSON payload for login
    json payload = {
        "username": username,
        "password": password
    };

    // Send POST request to login user
    http:Response|error response = clientEP->post("/login", payload);

    if response is http:Response {
        json result = check response.getJsonPayload();
        io:println("Response: ", result.toString());

        if result.status == "success" {
            io:println("Login successful!");
            check loggedInMenu(username); // Pass the username to loggedInMenu
            return true;
        } else {
            io:println("Login failed: ", result.message);
            return false;
        }
    } else {
        io:println("Error: Failed to connect to server.");
        return false;
    }
}

// Function to display the menu after successful login
function loggedInMenu(string username) returns error? {
    string option = "";
    while option != "0" {
        io:println("\nLogged-in Menu:");
        io:println("1. Apply for Pension");
        io:println("2. Submit Income Tax Registration");
        io:println("3. Submit ID Renewal");
        io:println("4. Change Password");
        io:println("5. Change ID");
        io:println("6. Change Email");
        io:println("7. Change Username");
        io:println("8. See Profile");
        io:println("0. Logout");

        option = io:readln("Enter your choice: ");

        match option {
            "1" => {
                check applyForPension();
            }
            "2" => {
                check submitIncomeTaxRegistration();
            }
            "3" => {
                check submitIDRenewal();
            }
            "4" => {
                check changePassword();
            }
            "5" => {
                check changeID();
            }
            "6" => {
                check changeEmail();
            }
            "7" => {
                check changeUsername();
            }
            "8" => {
                check viewProfile(username);
            }
            "0" => {
                io:println("Logging out...");
            }
            _ => {
                io:println("Invalid choice. Please try again.");
            }
        }
    }
}

// Function to handle pension application or check status
function applyForPension() returns error? {
    string userIdInput = io:readln("Enter your user ID: ");
    int userId = check 'int:fromString(userIdInput);

    json payload = {
        "userId": userId
    };

    // Send POST request to check or apply for pension
    http:Response|error response = clientEP->post("/applyForPension", payload);

    if response is http:Response {
        json result = check response.getJsonPayload();
        if result.status == "exists" {
            io:println("Pension Application Status: ", result.applicationStatus);
        } else {
            io:println("No existing pension application found. Please enter your details.");

            // Collect user input for new pension application
            string streetName = io:readln("Enter your residential street name: ");
            string poBoxInput = io:readln("Enter your PO Box (numeric): ");
            int poBox = check 'int:fromString(poBoxInput);
            string city = io:readln("Enter your city: ");
            string proofOfAddress = io:readln("Enter proof of address (file name): ");

            // Construct the JSON payload for the new application
            json newPensionPayload = {
                "userId": userId,
                "address": {
                    "streetName": streetName,
                    "poBox": poBox,
                    "city": city
                },
                "proofOfAddress": proofOfAddress
            };

            // Send POST request to create a new pension application
            http:Response|error newPensionResponse = clientEP->post("/applyForPension", newPensionPayload);

            if newPensionResponse is http:Response {
                json newResult = check newPensionResponse.getJsonPayload();
                io:println("Response: ", newResult.toString());
            } else {
                io:println("Error: Failed to submit pension application.");
            }
        }
    } else {
        io:println("Error: Failed to process pension application.");
    }
}

// Function to submit Income Tax Registration or check status
function submitIncomeTaxRegistration() returns error? {
    string userIdInput = io:readln("Enter your user ID: ");
    int userId = check 'int:fromString(userIdInput);

    json payload = {
        "userId": userId
    };

    // Send POST request to check or submit income tax registration
    http:Response|error response = clientEP->post("/applyForTax", payload);

    if response is http:Response {
        json result = check response.getJsonPayload();
        if result.status == "exists" {
            io:println("Income Tax Registration Status: ", result.registrationStatus);
        } else {
            io:println("No existing tax registration found. Please enter your details.");

            // Collect user input for new income tax registration
            string firstName = io:readln("Enter first name: ");
            string surname = io:readln("Enter surname: ");
            string gender = io:readln("Enter gender (M/F): ");
            string streetName = io:readln("Enter residential street name: ");
            string poBoxInput = io:readln("Enter PO Box (numeric): ");
            int poBox = check 'int:fromString(poBoxInput);
            string city = io:readln("Enter your city: ");
            string natureOfEmployment = io:readln("Enter nature of employment: ");
            string employmentStatus = io:readln("Enter employment status: ");
            string employersName = io:readln("Enter employer's name: ");
            string bankConfirmationLetter = io:readln("Enter bank confirmation letter file name (e.g., 'bank_letter.pdf'): ");
            string employerPostalAddress = io:readln("Enter employer's postal address: ");
            string employerEmail = io:readln("Enter employer's email: ");
            string employerPhoneNumber = io:readln("Enter employer's phone number: ");

            // Construct the JSON payload for the new tax registration
            json newTaxPayload = {
                "userId": userId,
                "firstName": firstName,
                "surname": surname,
                "gender": gender,
                "address": {
                    "streetName": streetName,
                    "poBox": poBox,
                    "city": city
                },
                "natureOfEmployment": natureOfEmployment,
                "employmentStatus": employmentStatus,
                "employersName": employersName,
                "bankConfirmationLetter": bankConfirmationLetter,
                "employerDetails": {
                    "postalAddress": employerPostalAddress,
                    "email": employerEmail,
                    "phoneNumber": employerPhoneNumber
                }
            };

            // Send POST request to create new tax registration
            http:Response|error newTaxResponse = clientEP->post("/applyForTax", newTaxPayload);

            if newTaxResponse is http:Response {
                json newResult = check newTaxResponse.getJsonPayload();
                io:println("Response: ", newResult.toString());
            } else {
                io:println("Error: Failed to submit tax registration.");
            }
        }
    } else {
        io:println("Error: Failed to process tax registration.");
    }
}

// Function to submit ID Renewal or check status
function submitIDRenewal() returns error? {
    string userIdInput = io:readln("Enter your user ID: ");
    int userId = check 'int:fromString(userIdInput);

    json payload = {
        "userId": userId
    };

    // Send POST request to check or submit ID renewal
    http:Response|error response = clientEP->post("/submitIDRenewal", payload);

    if response is http:Response {
        json result = check response.getJsonPayload();
        if result.status == "exists" {
            io:println("ID Renewal Status: ", result.renewalStatus);
        } else {
            io:println("No existing ID renewal found. Please enter your details.");

            // Collect user input for new ID renewal
            string birthCertificate = io:readln("Enter birth certificate file name (e.g., 'birth_certificate.pdf'): ");
            string guardianBirthCertificate = io:readln("Enter guardian/parent birth certificate file name (e.g., 'guardian_certificate.pdf'): ");
            string reasonForRenewal = io:readln("Enter reason for renewal (lost, stolen, etc.): ");

            // Construct the JSON payload for the new ID renewal
            json newRenewalPayload = {
                "userId": userId,
                "birthCertificate": birthCertificate,
                "guardianBirthCertificate": guardianBirthCertificate,
                "reasonForRenewal": reasonForRenewal
            };

            // Send POST request to create new ID renewal
            http:Response|error newRenewalResponse = clientEP->post("/submitIDRenewal", newRenewalPayload);

            if newRenewalResponse is http:Response {
                json newResult = check newRenewalResponse.getJsonPayload();
                io:println("Response: ", newResult.toString());
            } else {
                io:println("Error: Failed to submit ID renewal.");
            }
        }
    } else {
        io:println("Error: Failed to process ID renewal.");
    }
}

// Function to view profile without password validation
function viewProfile(string username) returns error? {
    // Construct the query parameter with the username
    string url = "/getProfile?username=" + username;

    // Send GET request to retrieve user profile
    http:Response|error response = clientEP->get(url);

    if response is http:Response {
        json result = check response.getJsonPayload();
        if result.status == "success" {
            io:println("\n---- User Profile ----");
            io:println("First Name: ", result.profile.firstName);
            io:println("Second Name: ", result.profile.secondName);
            io:println("ID: ", result.profile.id);
            io:println("Email: ", result.profile.email);
            io:println("Address: ");
            io:println("  Street Name: ", result.profile.address.streetName);
            io:println("  PO Box: ", result.profile.address.poBox);
            io:println("  City: ", result.profile.address.city);
        } else {
            io:println("Error: ", result.message);
        }
    } else {
        io:println("Error: Failed to retrieve profile.");
    }
}

// Function to change password
function changePassword() returns error? {
    string currentPassword = io:readln("Enter your current password: ");
    string newPassword = io:readln("Enter your new password: ");
    string confirmPassword = io:readln("Confirm your new password: ");

    // Check if the new password and confirm password match
    if newPassword != confirmPassword {
        io:println("Error: New password and confirmation password do not match.");
        return;
    }

    json payload = {
        "currentPassword": currentPassword,
        "newPassword": newPassword
    };

    // Send PUT request to change password
    http:Response|error response = clientEP->put("/changePassword", payload);

    if response is http:Response {
        json result = check response.getJsonPayload();
        io:println("Response: ", result.toString());
    } else {
        io:println("Error: Failed to change password.");
    }
}

// Function to change ID
function changeID() returns error? {
    string currentPassword = io:readln("Enter your current password: ");
    string newIDInput = io:readln("Enter your new ID: ");
    int newID = check 'int:fromString(newIDInput);

    json payload = {
        "currentPassword": currentPassword,
        "newID": newID
    };

    // Send PUT request to change ID
    http:Response|error response = clientEP->put("/changeID", payload);

    if response is http:Response {
        json result = check response.getJsonPayload();
        io:println("Response: ", result.toString());
    } else {
        io:println("Error: Failed to change ID.");
    }
}

// Function to change email
function changeEmail() returns error? {
    string currentPassword = io:readln("Enter your current password: ");
    string newEmail = io:readln("Enter your new email: ");

    json payload = {
        "currentPassword": currentPassword,
        "newEmail": newEmail
    };

    // Send PUT request to change email
    http:Response|error response = clientEP->put("/changeEmail", payload);

    if response is http:Response {
        json result = check response.getJsonPayload();
        io:println("Response: ", result.toString());
    } else {
        io:println("Error: Failed to change email.");
    }
}

// Function to change username
function changeUsername() returns error? {
    string currentPassword = io:readln("Enter your current password: ");
    string newUsername = io:readln("Enter your new username: ");

    json payload = {
        "currentPassword": currentPassword,
        "newUsername": newUsername
    };

    // Send PUT request to change username
    http:Response|error response = clientEP->put("/changeUsername", payload);

    if response is http:Response {
        json result = check response.getJsonPayload();
        io:println("Response: ", result.toString());
    } else {
        io:println("Error: Failed to change username.");
    }
}
