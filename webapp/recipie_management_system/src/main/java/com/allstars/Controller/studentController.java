package com.allstars.Controller;

import com.allstars.Entity.User;
import com.allstars.Service.userService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import java.util.Collection;

@RestController
@RequestMapping("/users")
public class studentController {
    @Autowired
    private userService userservice;

    @RequestMapping(method = RequestMethod.GET)
    public Collection<User> getAllUsers(){
        return userservice.getAllUsers();
    }
}
