package com.allstars.Service;


import com.allstars.Dao.Userdao;
import com.allstars.Entity.User;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.springframework.test.context.junit4.SpringRunner;

import java.util.Date;
import java.util.UUID;

@RunWith(SpringRunner.class)
public class UserServiceTest {

    @InjectMocks
    private UserService userService;

    @Mock
    private Userdao userdao;

    private static User user;

    @Before
    public void setUp() {
        this.user = new User(UUID.randomUUID(),"ravi","kiran","kiranhun@gmail.com","WonderFul@28",new Date(),new Date());
    }

    @Test
    public void userRegisterTest(){
        userService.saveUser(user);
        Mockito.verify(userdao).save(user);
    }
}
