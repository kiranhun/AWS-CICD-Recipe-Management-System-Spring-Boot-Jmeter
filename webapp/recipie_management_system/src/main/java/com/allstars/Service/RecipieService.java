package com.allstars.Service;

import com.allstars.Dao.RecipieDao;
import com.allstars.Dao.Userdao;
import com.allstars.Entity.Recipie;
import com.allstars.Entity.User;
import com.allstars.errors.RecipieCreationStatus;
import com.allstars.errors.RegistrationStatus;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;

@Service
public class RecipieService {

    @Autowired
    private RecipieDao recipieDao;

    @Autowired
    private Userdao userdao;

    public Recipie SaveRecipie(Recipie recipie, String emailid){
        User user = userdao.findByEmailId(emailid);
        recipie.setUser(user);
        recipie.setAuthor_id(user.getUuid());
        recipie.setCreated_ts();
        recipie.setUpdated_ts();
        recipie.setTotal_time_in_min();
        recipie = recipieDao.save(recipie);
        return recipie;
    }

    public RecipieCreationStatus getRecipieCreationStatus(BindingResult errors) {
        FieldError cookTimeError  = errors.getFieldError("cook_time_in_min");
        FieldError prepTimeError = errors.getFieldError("prep_time_in_min");
        FieldError titleError = errors.getFieldError("title");
        FieldError cuisineError = errors.getFieldError("cuisine");
        String cookTimeErrorMessage = cookTimeError == null ? "-" : cookTimeError.getCode();
        String prepTimeErrorMessage = prepTimeError == null ? "-" : prepTimeError.getCode();
        String titleErrorMessage = titleError == null ? "-" : titleError.getCode();
        String cuisineErrorMessage = cuisineError == null ? "-" : cuisineError.getCode();
        RecipieCreationStatus recipieCreationStatus= new RecipieCreationStatus(cookTimeErrorMessage, prepTimeErrorMessage,titleErrorMessage , cuisineErrorMessage);
        return recipieCreationStatus;
    }
}
