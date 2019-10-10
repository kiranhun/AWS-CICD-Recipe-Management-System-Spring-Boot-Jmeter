package com.allstars.Controller;

import com.allstars.Dao.Userdao;
import com.allstars.Entity.Recipie;
import com.allstars.Entity.User;
import com.allstars.Service.RecipieService;
import com.allstars.Service.UserService;
import com.allstars.errors.RecipieCreationStatus;
import com.allstars.validators.RecipieValidator;
import com.allstars.validators.UserValidator;
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
import java.util.Date;
import java.util.UUID;

@RestController
public class RecipieController {

    @Autowired
    private RecipieService recipieService;

    @Autowired
    private RecipieValidator recipieValidator;

    @Autowired
    private Userdao userdao;

    @InitBinder
    private void initBinder(WebDataBinder binder) {
        binder.setValidator(recipieValidator);
    }

    @RequestMapping(value = "v1/recipie", method = RequestMethod.POST)
    public ResponseEntity<?> createRecipie(@RequestHeader("Authorization") String token, @Valid @RequestBody Recipie recipie, BindingResult errors,
                                           HttpServletResponse response) throws Exception{
        RecipieCreationStatus recipieCreationStatus;

        if(errors.hasErrors()){
            recipieCreationStatus = recipieService.getRecipieCreationStatus(errors);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(
                    recipieCreationStatus);
        }else {
            String[] authDetails = decryptAuthenticationToken(token);
            User user = userdao.findByEmailId(authDetails[0]);
            Recipie newrecipie = recipieService.SaveRecipie(recipie, user);
            return new ResponseEntity<Recipie>(newrecipie, HttpStatus.CREATED);
        }
    }

    @RequestMapping(value = "v1/recipie/{id}", method = RequestMethod.GET)
    public ResponseEntity<Recipie> getRecipe(@PathVariable("id") String id) {
        //System.out.println(recipeId);
        //UUID recipeId = UUID.fromString(id);
        Recipie recipe = recipieService.getRecipe(id);
        if (null!=recipe) {
            return new ResponseEntity<Recipie>(recipe, HttpStatus.OK);
        }
        return new ResponseEntity<>(null, HttpStatus.NOT_FOUND);
    }

    @RequestMapping(value = "/v1/recipie/{id}", method = RequestMethod.DELETE)
    public ResponseEntity deleteRecipe(@PathVariable("id") String recipeId, @RequestHeader("Authorization") String token) throws UnsupportedEncodingException {
        String userDetails[] = decryptAuthenticationToken(token);
        Recipie existingRecipie = recipieService.getRecipe(recipeId);
        if(null != existingRecipie){
            if(existingRecipie.getUser().getEmailId().equalsIgnoreCase(userDetails[0])) {
                recipieService.deleteRecipe(recipeId);
                return ResponseEntity.status(HttpStatus.NO_CONTENT).body(null);
            }
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(null);
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
    }

    @RequestMapping(value = "v1/recipie/{recipieid}", method = RequestMethod.PUT)
    public ResponseEntity<?> updateRecipie(@PathVariable("recipieid") String id, @RequestHeader("Authorization") String token, @Valid  @RequestBody Recipie recipie, BindingResult errors,
                                                HttpServletResponse response) throws UnsupportedEncodingException {

        RecipieCreationStatus recipieCreationStatus;

        if(errors.hasErrors()){
            recipieCreationStatus = recipieService.getRecipieCreationStatus(errors);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(
                    recipieCreationStatus);
        }else {
            String[] authDetails = decryptAuthenticationToken(token);
            String userEmailID = authDetails[0];
            String t_id = id;
            return recipieService.updateRecipie(t_id,userEmailID,recipie);
        }

    }

    public String[] decryptAuthenticationToken(String token) throws UnsupportedEncodingException {
        String[] basicAuthToken = token.split(" ");
        byte[] authKeys = Base64.getDecoder().decode(basicAuthToken[1]);
        return new String(authKeys,"utf-8").split(":");
    }
}
