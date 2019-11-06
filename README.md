# CSYE 6225 - Fall 2019

## Team Information

| Name | NEU ID | Email Address |
| --- | --- | --- |
| Veena Vasudevan Iyer | 001447061 | iyer.v@husky.neu.edu |
| Amogh Doijode Harish| 001449026 | doijodeharish.a@husky.neu.edu |
| Ravi Kiran | 001491808 | lnu.ra@husky.neu.edu |
| | | |

## Technology Stack

The Recipe Management Web application is developed using Java Spring Boot framework that uses the REST architecture 
to create, update and retrieve user
Spring Security using Base64 authentication to secure retrieve user information and update user information
Spring Security using Base64 authentication to create recipe and update recipe
A user can create a recipe, delete & update only authored recipes. Anyone can fetch a recipe

## Build Instructions
Pre-req : Need tool to run REST endpoints like POSTMAN, MariaDB & IDE
    * Clone repository git@github.com:VeenaIyer-17/ccwebapp.git using SSH key
    * Import Maven Dependencies
    * Setup database connection by setting the datasource url, username & password
    * Create database named test
    * Test connection
    * Run application by traversing to ccwebapp/webapp/recipie_management_system/src/main/java/com/allstars/main.java
    * Console should state the application has started
    * From the command line run ./mvnw clean install -Ddomain={localhost} -Dusername={username} -Dpassword={password} -Daccess={aws access key} -Dsecret={aws secret key}  -Dbucket={s3 bucket name}
    * After the war file is built run  java -jar recipie_management_system-0.0.1-SNAPSHOT.war --domain={localhost} --username={username} --password={password} --access={access key}  --secret={secret key}  --bucket={bucketname}

## Deploy Instructions
    * To hit the end points of the REST API use any REST tool like POSTMAN
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
     
    * To Create Recipe
        - /v1/recipie/ & set Authentication to Basic Auth
        - Success : 201 CREATED
        - Failure : 400 BAD REQUEST
    
    * To Get Recipe
        - v1/recipie/{id} & No Auth
        - Success : 200 OK
        - Failure : 404 NOT FOUND
     
     * To Update Recipe
        - v1/recipie/{id} & set Authentication to Basic Auth
        - Success : 200 OK 
        - Failure : 400 BAD REQUEST
                  : 401 UNAUTHORIZED
                  : 404 NOT FOUND
     
     * To Delete Recipe
        - v1/recipie/{id} & set Authentication to Basic Auth
        - Success : 204 NO CONTENT
        - Failure : 401 UNAUTHORIZED
                  : 404 NOT FOUND
      
     * To Add and Image to the recipe(POST)
        - /v1/recipe/{id}/image & set Authentication to Basic Auth
        - select form-data in body and add an image
        - Success : 201
            {
              "id": "d290f1ee-6c54-4b01-90e6-d701748f0851",
              "url": "https://s3-eu-central-1.amazonaws.com/BUCKET/FILE"
            }
        - Failure : 400 Bad Request
     * To get an Image(GET)
        - /v1/recipe/{recipeId}/image/{imageId} and set Authentication to no Auth
        - Success : 200
            {
              "id": "d290f1ee-6c54-4b01-90e6-d701748f0851",
              "url": "https://s3-eu-central-1.amazonaws.com/BUCKET/FILE"
            }
        - Failure : 404 Not Found
     * To Delete and image (Delete)
        - /v1/recipe/{recipeId}/image/{imageId} and set Authentication to Basic Auth
        - Success : 204 No Content
        - Failure : 401 Unauthorized
                    404 Not Found
                
            
### Running Tests

    * Implemented Junit using Mockito for unit testing for creation of user & create recipe
    * Run Application using "Run All Tests"

### CI/CD
Om gam ganapataye namaha


