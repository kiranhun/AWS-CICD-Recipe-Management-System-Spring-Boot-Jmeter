package com.allstars.recipie_management_system.controller;


import com.allstars.recipie_management_system.entity.User;
import com.allstars.recipie_management_system.errors.RegistrationStatus;
import com.allstars.recipie_management_system.service.UserService;
import com.allstars.recipie_management_system.validators.UserValidator;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.*;
import org.slf4j.LoggerFactory;
import org.slf4j.Logger;
import com.timgroup.statsd.NoOpStatsDClient;
import com.timgroup.statsd.NonBlockingStatsDClient;
import com.timgroup.statsd.StatsDClient;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.validation.Valid;
import java.io.UnsupportedEncodingException;
import java.util.Base64;
import java.util.Date;

@RestController
@RequestMapping("/")
public class UserController {

    @Autowired
    private UserService userService;

    @Autowired
    private UserValidator userValidator;

    @InitBinder
    private void initBinder(WebDataBinder binder) {
        binder.setValidator(userValidator);
    }

    @Autowired
    private StatsDClient statsDClient;

    private final static Logger logger = LoggerFactory.getLogger(UserController.class);


    @RequestMapping(value = "v1/user", method = RequestMethod.POST)
    public ResponseEntity<?> createUser(@Valid @RequestBody User user, BindingResult errors,
                                        HttpServletResponse response) throws Exception {
        RegistrationStatus registrationStatus;
        statsDClient.incrementCounter("endpoint.user.api.post");
        long startTime = System.currentTimeMillis();

        User u;
        if(errors.hasErrors()) {
            registrationStatus = userService.getRegistrationStatus(errors);
            logger.error("user creation failed");
            long endTime = System.currentTimeMillis();
            long duration = (endTime - startTime);
            statsDClient.recordExecutionTime("postUserTime", duration);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(registrationStatus);
        }else {
            user.setAccount_created(new Date());
            user.setAccount_updated(new Date());
            registrationStatus = new RegistrationStatus();
            u = userService.saveUser(user);
            logger.info("User successfully created");
            long endTime = System.currentTimeMillis();
            long duration = (endTime - startTime);
            statsDClient.recordExecutionTime("postUserTime", duration);
            return  new ResponseEntity<User>(u, HttpStatus.CREATED);
        }
    }

    @RequestMapping(value="v1/user/self" ,method = RequestMethod.GET)
    public ResponseEntity<User> getUser(@RequestHeader("Authorization") String token, HttpServletRequest request) throws UnsupportedEncodingException {
        statsDClient.incrementCounter("endpoint.user.self.api.get");
       try {
           if(token == null){
               return  ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(null);
           }
           String userDetails[] = decryptAuthenticationToken(token);

           if (!(userService.isEmailPresent(userDetails[0]))) {
               logger.info("User does not exist");
               return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(null);
           }
           else {
               long startTime = System.currentTimeMillis();
               User getuser = userService.getUser(userDetails[0]);
               long endTime = System.currentTimeMillis();
               long duration = (endTime - startTime);
               statsDClient.recordExecutionTime("getUserTime", duration);
               logger.info("Get user successful");
               return ResponseEntity.status(HttpStatus.OK).body(getuser);
           }
       }catch(Exception e){
           logger.error("Error in get user");
           return  ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(null);
       }
    }

    @RequestMapping(value = "v1/user/self", method = RequestMethod.PUT)
    public ResponseEntity<String> updateUser(@RequestHeader("Authorization") String header, @Valid @RequestBody User user, BindingResult errors,
                                             HttpServletResponse response) throws UnsupportedEncodingException {
        statsDClient.incrementCounter("endpoint.user.self.api.put");
        try {
            long startTime = System.currentTimeMillis();

            if(header == null){
                long endTime = System.currentTimeMillis();
                long duration = (endTime - startTime);
                statsDClient.recordExecutionTime("putUserTime", duration);
                return  ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(null);
            }
            String[] userDetails = decryptAuthenticationToken(header);

            if (userService.updateUserInfo(user, userDetails[0], userDetails[1])) {
                logger.info("user successfully updated");
                long endTime = System.currentTimeMillis();
                long duration = (endTime - startTime);
                statsDClient.recordExecutionTime("putUserTime", duration);
                return ResponseEntity.status(HttpStatus.NO_CONTENT).body("");
            } else {
                logger.error("Error in put user");
                long endTime = System.currentTimeMillis();
                long duration = (endTime - startTime);
                statsDClient.recordExecutionTime("putUserTime", duration);
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("");
            }
        } catch(Exception e) {
           logger.error("Error in put user");
           return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(null);
        }
    }
    
    public String[] decryptAuthenticationToken(String token) throws Exception {
        try {
            String[] basicAuthToken = token.split(" ");
            byte[] authKeys = Base64.getDecoder().decode(basicAuthToken[1]);
            return new String(authKeys, "utf-8").split(":");
        } catch(Exception e) {
            throw new Exception("Unauthorized");
        }
    }
}
