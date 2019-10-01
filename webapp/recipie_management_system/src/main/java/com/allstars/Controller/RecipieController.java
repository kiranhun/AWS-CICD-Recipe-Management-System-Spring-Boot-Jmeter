package com.allstars.Controller;

import com.allstars.Dao.Userdao;
import com.allstars.Entity.Recipie;
import com.allstars.Entity.User;
import com.allstars.Service.RecipieService;
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

            Recipie newrecipie = recipieService.SaveRecipie(recipie, authDetails[0]);
            return new ResponseEntity<Recipie>(newrecipie, HttpStatus.CREATED);
        }
    }

    public String[] decryptAuthenticationToken(String token) throws UnsupportedEncodingException {
        String[] basicAuthToken = token.split(" ");
        byte[] authKeys = Base64.getDecoder().decode(basicAuthToken[1]);
        return new String(authKeys,"utf-8").split(":");
    }
}
