package com.allstars.Service;

import com.allstars.Dao.RecipieDao;
import com.allstars.Entity.NutritionInformation;
import com.allstars.Entity.OrderedList;
import com.allstars.Entity.Recipie;
import com.allstars.Entity.User;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.springframework.test.context.junit4.SpringRunner;

import java.util.*;

@RunWith(SpringRunner.class)
public class RecipieServiceTest {

    @InjectMocks
    private RecipieService recipieService;

    @Mock
    private RecipieDao recipieDao;

    private static Recipie recipie;
    private static Set<OrderedList> steps;
    private static OrderedList oList;
    private static NutritionInformation nInfo;
    private static User user;

    @Before
    public void setUp() {
        List<String> ingredients = Arrays.asList(new String[]{"1", "abc", "some"});
        this.steps = new HashSet<>();
        this.oList = new OrderedList(1,"first");
        steps.add(oList);
        this.nInfo = new NutritionInformation(Integer.valueOf(2),Float.valueOf(1),Integer.valueOf(3),Float.valueOf(4),Float.valueOf(5));
        this.recipie = new Recipie(new Date(),new Date(),15,5,20,"samosa","indian",1,ingredients,steps,nInfo);
        this.user = new User(UUID.randomUUID(),"ravi","kiran","kiranhun@gmail.com","WonderFul@28",new Date(),new Date());
    }

    @Test
    public void recipeSaveTest(){
        recipieService.SaveRecipie(recipie,user);
        Mockito.verify(recipieDao).save(recipie);
    }

}
