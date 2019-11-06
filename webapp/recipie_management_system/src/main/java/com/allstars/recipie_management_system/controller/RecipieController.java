package com.allstars.recipie_management_system.controller;
import com.allstars.recipie_management_system.dao.Userdao;
import com.allstars.recipie_management_system.entity.Recipie;
import com.allstars.recipie_management_system.entity.User;
import com.allstars.recipie_management_system.errors.RecipieCreationStatus;
import com.allstars.recipie_management_system.service.RecipieService;
import com.allstars.recipie_management_system.validators.RecipieValidator;
import com.timgroup.statsd.StatsDClient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletResponse;
import javax.validation.Valid;
import java.io.UnsupportedEncodingException;
import java.util.Base64;

@RestController
public class RecipieController {

    @Autowired
    private RecipieService recipieService;

    @Autowired
    private RecipieValidator recipieValidator;

    @Autowired
    private Userdao userdao;

    @Autowired
    private StatsDClient statsDClient;

    private final static Logger logger = LoggerFactory.getLogger(RecipieController.class);

    @InitBinder
    private void initBinder(WebDataBinder binder) {
        binder.setValidator(recipieValidator);
    }

    @RequestMapping(value = "v1/recipie", method = RequestMethod.POST)
    public ResponseEntity<?> createRecipie(@RequestHeader("Authorization") String token, @Valid @RequestBody Recipie recipie, BindingResult errors,
                                           HttpServletResponse response) throws Exception{
        RecipieCreationStatus recipieCreationStatus;
        long startTime = System.currentTimeMillis();
        statsDClient.incrementCounter("endpoint.recipie.api.post");
        if(errors.hasErrors()){
            recipieCreationStatus = recipieService.getRecipieCreationStatus(errors);
            logger.error("Recipe Creation Failed");
            long endTime = System.currentTimeMillis();
            long duration = (endTime - startTime);
            statsDClient.recordExecutionTime("postRecipieTime", duration);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(recipieCreationStatus);
        }else {
            String[] authDetails = decryptAuthenticationToken(token);
            User user = userdao.findByEmailId(authDetails[0]);
            Recipie newrecipie = recipieService.SaveRecipie(recipie, user);
            logger.info("Recipe creation successful");
            long endTime = System.currentTimeMillis();
            long duration = (endTime - startTime);
            statsDClient.recordExecutionTime("postRecipieTime", duration);
            return new ResponseEntity<Recipie>(newrecipie, HttpStatus.CREATED);
        }
    }

    @RequestMapping(value = "v1/recipie/{id}", method = RequestMethod.GET)
    public ResponseEntity<Recipie> getRecipe(@PathVariable("id") String id) {
        long startTime = System.currentTimeMillis();
        statsDClient.incrementCounter("endpoint.recipie.id.api.get");
        //System.out.println(recipeId);
        //UUID recipeId = UUID.fromString(id);
        Recipie recipe = recipieService.getRecipe(id);
        if (null!=recipe) {
            logger.info("Recipe fetch successful");
            long endTime = System.currentTimeMillis();
            long duration = (endTime - startTime);
            statsDClient.recordExecutionTime("getRecipieTime", duration);
            return new ResponseEntity<Recipie>(recipe, HttpStatus.OK);
        }
        logger.error("Recipe fetch failed");
        long endTime = System.currentTimeMillis();
        long duration = (endTime - startTime);
        statsDClient.recordExecutionTime("getRecipieTime", duration);
        return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
    }

    @RequestMapping(value = "/v1/recipie/{id}", method = RequestMethod.DELETE)
    public ResponseEntity deleteRecipe(@PathVariable("id") String recipeId, @RequestHeader("Authorization") String token) throws UnsupportedEncodingException {
        statsDClient.incrementCounter("endpoint.recipie.id.api.delete");
        long startTime = System.currentTimeMillis();
        String userDetails[] = decryptAuthenticationToken(token);
        Recipie existingRecipie = recipieService.getRecipe(recipeId);
        if(null != existingRecipie){
            if(existingRecipie.getUser().getEmailId().equalsIgnoreCase(userDetails[0])) {
                recipieService.deleteRecipe(recipeId);
                logger.info("Recipe delete successful");
                long endTime = System.currentTimeMillis();
                long duration = (endTime - startTime);
                statsDClient.recordExecutionTime("deleteRecipieTime", duration);
                return ResponseEntity.status(HttpStatus.NO_CONTENT).body(null);
            }else {
                logger.error("user not authorised to delete this recipe");
                long endTime = System.currentTimeMillis();
                long duration = (endTime - startTime);
                statsDClient.recordExecutionTime("deleteRecipieTime", duration);
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(null);
            }
        }
        logger.error("Recipe not found");
        long endTime = System.currentTimeMillis();
        long duration = (endTime - startTime);
        statsDClient.recordExecutionTime("deleteRecipieTime", duration);
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
    }

    @RequestMapping(value = "v1/recipie/{recipieid}", method = RequestMethod.PUT)
    public ResponseEntity<?> updateRecipie(@PathVariable("recipieid") String id, @RequestHeader("Authorization") String token, @Valid  @RequestBody Recipie recipie, BindingResult errors,
                                                HttpServletResponse response) throws UnsupportedEncodingException {
        statsDClient.incrementCounter("endpoint.recipie.recipieid.api.put");
        RecipieCreationStatus recipieCreationStatus;
        long startTime = System.currentTimeMillis();

        if(errors.hasErrors()){
            recipieCreationStatus = recipieService.getRecipieCreationStatus(errors);
            logger.error("Recipe update failed");
            long endTime = System.currentTimeMillis();
            long duration = (endTime - startTime);
            statsDClient.recordExecutionTime("putRecipieTime", duration);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(recipieCreationStatus);
        }else {
            String[] authDetails = decryptAuthenticationToken(token);
            String userEmailID = authDetails[0];
            String t_id = id;
            logger.info("Recipe Update successful");
            long endTime = System.currentTimeMillis();
            long duration = (endTime - startTime);
            statsDClient.recordExecutionTime("putRecipieTime", duration);
            return recipieService.updateRecipie(t_id,userEmailID,recipie);
        }

    }

    public String[] decryptAuthenticationToken(String token) throws UnsupportedEncodingException {
        String[] basicAuthToken = token.split(" ");
        byte[] authKeys = Base64.getDecoder().decode(basicAuthToken[1]);
        return new String(authKeys,"utf-8").split(":");
    }
}
