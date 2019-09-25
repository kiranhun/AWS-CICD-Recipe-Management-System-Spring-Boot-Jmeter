//package com.allstars.Controller;
//
//
//import com.allstars.Service.UserService;
//import org.junit.Before;
//import org.junit.Test;
//import org.junit.runner.RunWith;
//import org.mockito.InjectMocks;
//import org.mockito.Mock;
//import org.springframework.test.context.junit4.SpringRunner;
//import org.springframework.test.web.servlet.MockMvc;
//import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
//import org.springframework.test.web.servlet.result.MockMvcResultMatchers;
//import org.springframework.test.web.servlet.setup.MockMvcBuilders;
//
//import java.text.SimpleDateFormat;
//import java.util.Calendar;
//
//@RunWith(SpringRunner.class)
//public class UserControllerTest {
//
//    private MockMvc mockMvc;
//
//    @InjectMocks
//    private UserController userController;
//
//    @Mock
//    private UserService userService;
//
//    @Before
//    public void setUp(){
//        this.mockMvc = MockMvcBuilders.standaloneSetup(userController).build();
//    }
//
//    @Test
//    public void userTest() throws Exception{
////        Calendar cal = Calendar.getInstance();
////        SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss");
//
//        mockMvc.perform(MockMvcRequestBuilders.post("/"))
//                .andExpect(MockMvcResultMatchers.status().isOk());
//    }
//
//}
