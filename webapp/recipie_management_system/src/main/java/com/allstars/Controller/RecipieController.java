package com.allstars.Controller;

import com.allstars.Entity.Recipie;
import com.allstars.Entity.User;
import com.allstars.Service.RecipieService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletResponse;
import javax.validation.Valid;

@RestController
@RequestMapping("/")
public class RecipieController {

    @Autowired
    private RecipieService recipieService;

    @RequestMapping(value = "v1/recipie", method = RequestMethod.POST)
    public ResponseEntity<Recipie> createRecipie(@Valid @RequestBody Recipie recipie,
                                                 HttpServletResponse response) throws Exception{

        Recipie newrecipie = recipieService.SaveRecipie(recipie);

        return new ResponseEntity<Recipie>(newrecipie, HttpStatus.CREATED);
    }
}
