package com.allstars.Service;

import com.allstars.Dao.Userdao;
import com.allstars.Entity.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Collection;
@Service
public class userService {

    @Autowired
    private Userdao userDao;

    public User saveUser(User user){

        try {
            userDao.save(user);
        } catch (Exception e){
            return null;
        }
        return  user;
    }


}
