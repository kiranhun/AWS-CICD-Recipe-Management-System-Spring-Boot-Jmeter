# CSYE 6225 - Fall 2019

## Team Information

| Name | NEU ID | Email Address |
| --- | --- | --- |
| Veena Vasudevan Iyer | 001447061 | iyer.v@husky.neu.edu |
| Amogh Doijode Harish| 001449026 | doijodeharish.a@husky.neu.edu |
| Ravi Kiran | 001491808 | lnu.ra@husky.neu.edu |
| | | |

## Technology Stack

The Recipe Management Web application is developed using Java Spring Boot framework that uses the REST architecture to create,
update and retrieve user.

## Build Instructions

Pre-req : Need POSTMAN and MariaDB installed.
    * Clone repository git@github.com:VeenaIyer-17/ccwebapp.git using SSH key.
    * Import Maven Dependencies
    * Run application by traversing to ccwebapp/webapp/recipie_management_system/src/main/java/com/allstars/main.java

## Deploy Instructions
    * Open POSTMAN
    * To Create User -
        - Use v1/user & No Authentication
        - Success : 200 OK
            {         
                "uuid": "88cba988-7215-45d9-b979-8de0c65e64d0",
                "fName": "veena",
                "lName": "iyer",
                "emailId": "veena@gmail.com",
                "cTime": "2019-09-26T01:02:06.130+0000",
                "uTime": "2019-09-26T01:02:06.130+0000"
             }
         - Failure : 400 BAD REQUEST
    
    * To Get User -
        - Use v1/user/self & set Authentication to Basic Auth
        - Success : 200 OK
            {
                "uuid": "88cba988-7215-45d9-b979-8de0c65e64d0",
                "fName": "veena",
                "lName": "iyer",
                "emailId": "veena@gmail.com",
                "cTime": "2019-09-26T01:02:06.130+0000",
                "uTime": "2019-09-26T01:02:06.130+0000"
            }
        - Failure : 401 UNAUTHORIZED     
            Access Denied
            
    * To Update User
        - Use v1/user/self & set Authentication to Basic Auth
        - Success : 204 NO CONTENT
        - Failure : 400 BAD REQUEST
            
## Running Tests

    * Implemented Junit using Mockito for unit testing for creation of user.
    * Run Application using "Run All Tests"

## CI/CD


