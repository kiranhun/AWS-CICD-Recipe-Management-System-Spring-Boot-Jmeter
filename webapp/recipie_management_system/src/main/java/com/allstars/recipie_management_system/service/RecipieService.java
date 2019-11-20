package com.allstars.recipie_management_system.service;

import com.allstars.recipie_management_system.controller.RecipieController;
import com.allstars.recipie_management_system.dao.RecipeImageDao;
import com.allstars.recipie_management_system.dao.RecipieDao;
import com.allstars.recipie_management_system.dao.Userdao;
import com.allstars.recipie_management_system.entity.RecipeImage;
import com.allstars.recipie_management_system.entity.Recipie;
import com.allstars.recipie_management_system.entity.User;
import com.allstars.recipie_management_system.errors.RecipieCreationStatus;
import com.timgroup.statsd.StatsDClient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;

import java.util.Date;
import java.util.List;
import java.util.Optional;

@Service
public class RecipieService {

    @Autowired
    private RecipieDao recipieDao;

    @Autowired
    private Userdao userdao;

    @Autowired
    private StatsDClient statsDClient;

    @Autowired
    private RecipeImageDao recipeImageDao;

    @Autowired
    private RecipeImageAwsService recipeImageAwsService;


    private final static Logger logger = LoggerFactory.getLogger(RecipieController.class);

    public Recipie SaveRecipie(Recipie recipie, User user){
        try {
            recipie.setUser(user);
            recipie.setAuthor_id(user.getUuid());
            recipie.setCreatedts(new Date());
            recipie.setUpdated_ts();
            recipie.setTotal_time_in_min();
            long startTime = System.currentTimeMillis();
            recipie = recipieDao.save(recipie);
            long endTime = System.currentTimeMillis();
            long duration = (endTime - startTime);
            statsDClient.recordExecutionTime("SaveRecipieQuery", duration);
            return recipie;
        }catch(Exception e){
            return null;
        }
    }


    public RecipieCreationStatus getRecipieCreationStatus(BindingResult errors) {
        FieldError cookTimeError  = errors.getFieldError("cook_time_in_min");
        FieldError prepTimeError = errors.getFieldError("prep_time_in_min");
        FieldError titleError = errors.getFieldError("title");
        FieldError cuisineError = errors.getFieldError("cuisine");
        FieldError ingredientsError = errors.getFieldError("ingredients");
        FieldError stepsError = errors.getFieldError("steps");
        FieldError nutritionInformationError = errors.getFieldError("nutritionInformation");
        FieldError servingsError = errors.getFieldError("servings");

        String cookTimeErrorMessage = cookTimeError == null ? "-" : cookTimeError.getCode();
        String prepTimeErrorMessage = prepTimeError == null ? "-" : prepTimeError.getCode();
        String titleErrorMessage = titleError == null ? "-" : titleError.getCode();
        String cuisineErrorMessage = cuisineError == null ? "-" : cuisineError.getCode();
        String ingredientsErrorMessage = ingredientsError == null ? "-" : ingredientsError.getCode();
        String stepsErrorMessage = stepsError == null ? "-" : stepsError.getCode();
        String nutritionInformationErrorMessage = nutritionInformationError == null ? "-" : nutritionInformationError.getCode();
        String servingsErrorMessage = servingsError == null ? "-" : servingsError.getCode();
        RecipieCreationStatus recipieCreationStatus= new RecipieCreationStatus(cookTimeErrorMessage, prepTimeErrorMessage,titleErrorMessage , cuisineErrorMessage, servingsErrorMessage, ingredientsErrorMessage, stepsErrorMessage, nutritionInformationErrorMessage);
        return recipieCreationStatus;
    }

    public Recipie getRecipe(String recipeid) {
        //if(recipieDao.isRecipiePresent(recipeid)>0) {
            long startTime = System.currentTimeMillis();
            Recipie recipie = recipieDao.findByRecipeid(recipeid);
            long endTime = System.currentTimeMillis();
            long duration = (endTime - startTime);
            statsDClient.recordExecutionTime("getRecipieQuery", duration);
            return recipie;
            //}
       // return null;
    }

    public void deleteRecipe(String recipeId){
        long startTime = System.currentTimeMillis();
        Recipie recipie = recipieDao.findByRecipeid(recipeId);
        RecipeImage recipeImage = recipie.getImage();

        if(recipeImage != null){
            try{
                recipeImageAwsService.deleteImage(recipeImage,recipeId);
                recipeImageDao.delete(recipeImage);
            }catch (Exception e){
                logger.warn("Recipe image doesn't exist");
            }
        }
        recipieDao.deleteById(recipeId);
        long endTime = System.currentTimeMillis();
        long duration = (endTime - startTime);
        statsDClient.recordExecutionTime("deleteRecipieQuery", duration);
    }

    public ResponseEntity<?> updateRecipie(String id, String userEmailId, Recipie recipie){
        long startTime = System.currentTimeMillis();
        Recipie retrivedRecipie = recipieDao.findByRecipeid(id);

        if(retrivedRecipie == null){
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("");
        }
        else {
            if(retrivedRecipie.getUser().getEmailId().equals(userEmailId)){

                recipie.setRecipeId(retrivedRecipie.getRecipeId());
                recipie.setUser(retrivedRecipie.getUser());
                recipie.setAuthor_id(retrivedRecipie.getAuthor_id());
                recipie.setCreatedts(retrivedRecipie.getCreatedts());
                recipie.setUpdated_ts();
                recipie.setTotal_time_in_min();
                recipieDao.save(recipie);
                long endTime = System.currentTimeMillis();
                long duration = (endTime - startTime);
                statsDClient.recordExecutionTime("updateRecipieQuery", duration);
                return new ResponseEntity<Recipie>(recipie, HttpStatus.CREATED);
            }
            else{
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("");
            }
        }
    }

    public boolean isRecipeImagePresent( Recipie recipie) {
        if(recipie.getImage() == null) return false;
        return true;
    }

    public Optional<Recipie> findById(String idRecipe) {
        try{
            return recipieDao.findById(idRecipe);
        }catch(Exception exc) {
            return null;
        }
    }

    public List<Recipie> getAllRecipes(String author_id) {

        try{
            long startTime =  System.currentTimeMillis();

            List<Recipie> allRecipes=recipieDao.findByAuthorid(author_id);
            long endTime = System.currentTimeMillis();
            long duration = (endTime - startTime);

            statsDClient.recordExecutionTime("dbQueryTimeGetAllRecipe",duration);

            logger.info("Get All recipe from DB");

            return allRecipes;
        }catch(Exception exc) {
            logger.error("Could not find Recipes for the given userId");
            return null;
        }
    }

    public Recipie getLatestRecipie() {
        try{
            long startTime = System.currentTimeMillis();
            Recipie latestRecipe = null;
            if(recipieDao.findTopByOrderByCreatedtsDesc()!=null) {
                latestRecipe = recipieDao.findTopByOrderByCreatedtsDesc();
            }

            long endTime = System.currentTimeMillis();
            long duration = (endTime - startTime);

            statsDClient.recordExecutionTime("dbQueryLatestRecipe",duration);
            logger.info("Get latest recipe from DB");

            return latestRecipe;
        } catch (Exception exc) {
            logger.error("Could not get latest Recipe from the dB");
            return null;
        }
    }
}
