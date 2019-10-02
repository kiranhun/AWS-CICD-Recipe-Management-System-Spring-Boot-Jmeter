package com.allstars.Controller;


import com.allstars.Entity.User;
import com.allstars.Service.UserService;
import com.allstars.errors.RegistrationStatus;
import com.allstars.validators.UserValidator;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.*;

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


    @RequestMapping(value = "v1/user", method = RequestMethod.POST)
    public ResponseEntity<?> createUser(@Valid @RequestBody User user, BindingResult errors,
                                           HttpServletResponse response) throws Exception {
        RegistrationStatus registrationStatus;

        if(errors.hasErrors()) {
            registrationStatus = userService.getRegistrationStatus(errors);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(
                    registrationStatus);
        }else {
            user.setcTime(new Date());
            user.setuTime(new Date());
            registrationStatus = new RegistrationStatus();
            User u = userService.saveUser(user);

            return  new ResponseEntity<User>(u, HttpStatus.CREATED);
        }
    }

    @RequestMapping(value="v1/user/self" ,method = RequestMethod.GET)
    public ResponseEntity<User> getUser(@RequestHeader("Authorization") String token, HttpServletRequest request) throws UnsupportedEncodingException {
       try {
           if(token == null){
               return  ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(null);
           }
           String userDetails[] = decryptAuthenticationToken(token);

           if (!(userService.isEmailPresent(userDetails[0])))
               return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(null);
           else
               return ResponseEntity.status(HttpStatus.OK).body(userService.getUser(userDetails[0]));
       }catch(Exception e){
           return  ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(null);
       }
    }

    @RequestMapping(value = "v1/user/self", method = RequestMethod.PUT)
    public ResponseEntity<String> updateUser(@RequestHeader("Authorization") String header, @Valid @RequestBody User user, BindingResult errors,
                                             HttpServletResponse response) throws UnsupportedEncodingException {
        try {
            if(header == null){
                return  ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(null);
            }
            String[] userDetails = decryptAuthenticationToken(header);

            if (userService.updateUserInfo(user, userDetails[0], userDetails[1])) {
                return ResponseEntity.status(HttpStatus.NO_CONTENT).body("");
            } else {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("");
            }
        } catch(Exception e) {
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
