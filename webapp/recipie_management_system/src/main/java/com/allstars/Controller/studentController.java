package com.allstars.Controller;

import com.allstars.Dao.Userdao;
import com.allstars.Entity.User;
import com.allstars.Service.userService;
import org.apache.catalina.filters.ExpiresFilter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.Collection;
import java.util.Date;

@RestController
@RequestMapping("/")
public class studentController {
    @Autowired
    private userService userservice;

    @Autowired
    private Userdao userDao;


    @RequestMapping(value = "/create",method = RequestMethod.POST)
    @ResponseBody
    public ResponseEntity<User> createUser(HttpServletRequest request,
                                           HttpServletResponse response, @RequestBody User user){

        User u = userDao.save(user);
        if (u == null){
            return  new ResponseEntity<User>(u, HttpStatus.BAD_REQUEST);
        }else{
         return  new ResponseEntity<User>(user, HttpStatus.CREATED);
        }
    }
}
