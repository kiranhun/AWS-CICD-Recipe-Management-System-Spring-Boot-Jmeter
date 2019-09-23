package com.allstars.Dao;

import com.allstars.Entity.User;
import org.springframework.stereotype.Repository;

import java.util.Collection;
import java.util.Date;
import java.util.HashMap;

@Repository
public class Userdao {
    private static HashMap<Integer,User> users;

    static{
        users = new HashMap<Integer, User>(){
            {
                put(1, new User(1, "amogh", "Doijode", "amoghdoijode07@gmail.com","amogh", new Date(), new Date()));
            }
        };
    }

    public Collection<User> getAllUsers(){
        return this.users.values();
    }
}
