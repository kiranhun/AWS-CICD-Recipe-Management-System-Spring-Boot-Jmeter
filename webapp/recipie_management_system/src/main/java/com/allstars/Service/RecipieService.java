package com.allstars.Service;

import com.allstars.Dao.RecipieDao;
import com.allstars.Entity.Recipie;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class RecipieService {

    @Autowired
    private RecipieDao recipieDao;

    public Recipie SaveRecipie(Recipie recipie){
        recipie = recipieDao.save(recipie);
        return recipie;
    }
}
