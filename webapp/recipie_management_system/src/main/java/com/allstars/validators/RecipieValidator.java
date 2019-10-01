package com.allstars.validators;

import com.allstars.Entity.Recipie;
import com.allstars.Entity.User;
import com.allstars.Service.RecipieService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.Errors;
import org.springframework.validation.ValidationUtils;
import org.springframework.validation.Validator;

public class RecipieValidator implements Validator {

    @Autowired
    private RecipieService recipieService;

    @Override
    public boolean supports(Class<?> aClass) {
        return Recipie.class.isAssignableFrom(aClass);
    }

    @Override
    public void validate(Object o, Errors errors) {
        ValidationUtils.rejectIfEmptyOrWhitespace(errors, "cook_time_in_min", "cook_time_in_min required");
        ValidationUtils.rejectIfEmptyOrWhitespace(errors, "prep_time_in_min", "prep_time_in_min required");
        ValidationUtils.rejectIfEmptyOrWhitespace(errors, "title", "title required");
        ValidationUtils.rejectIfEmptyOrWhitespace(errors, "cuisine", "cuisine required");
        if(errors.hasErrors()) return;

        Recipie recipie = (Recipie) o;

        if(((recipie.getCook_time_in_min())%5 != 0)){
            errors.rejectValue("cook_time_in_min", "Cook Time should be a multiple of 5");
        }
        if((recipie.getPrep_time_in_min() % 5 != 0)){
            errors.rejectValue("prep_time_in_min", "Prep Time should be a multiple of 5");
        }

        if(errors.hasErrors()) return;
    }

}
