package com.allstars.Controller;

import com.allstars.Dao.Userdao;
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
import javax.servlet.http.HttpServletResponse;
import javax.validation.Valid;

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
    public ResponseEntity<RegistrationStatus> createUser(@Valid @RequestBody User user, BindingResult errors,
                                           HttpServletResponse response) throws Exception {
        RegistrationStatus registrationStatus;

        if(errors.hasErrors()) {
            registrationStatus = userService.getRegistrationStatus(errors);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(
                    registrationStatus);
        }else {
            registrationStatus = new RegistrationStatus();
            userService.saveUser(user);
            return ResponseEntity.status(HttpStatus.CREATED).body(
                    registrationStatus);
        }
//        User u = userService.saveUser(user);
//        if (u == null){
//            return  new ResponseEntity<User>(u, HttpStatus.BAD_REQUEST);
//        }else{
//         return  new ResponseEntity<User>(user, HttpStatus.CREATED);
//        }
    }

    @RequestMapping(value="v1/user/self" ,method = RequestMethod.GET)
    public String getUser(@RequestHeader("Authorization") String language) {
        return language;
    }
}
