package com.allstars.recipie_management_system.controller;

import com.allstars.recipie_management_system.dao.RecipeImageDao;
import com.allstars.recipie_management_system.dao.RecipieDao;
import com.allstars.recipie_management_system.entity.RecipeImage;
import com.allstars.recipie_management_system.entity.Recipie;
import com.allstars.recipie_management_system.service.RecipeImageService;
import com.allstars.recipie_management_system.service.RecipieService;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import java.io.UnsupportedEncodingException;
import java.util.Base64;
import java.util.UUID;

@RestController
@Validated
public class RecipeImageController {

    private static final Logger LOGGER = LoggerFactory.getLogger(RecipeImageController.class);

//    @Autowired
//    private StatsDClient metricsClient;

    @Autowired
    private RecipieService recipieService;


    @Autowired
    RecipeImageService recipeImageService;


    @Autowired
    RecipieDao recipieDao;

    @Autowired
    RecipeImageDao recipeImageDao;


    @RequestMapping(method = RequestMethod.POST, value = "/v1/recipie/{idRecipe}/image")
    public ResponseEntity<?> addRecipeImage(@PathVariable String idRecipe, @RequestParam MultipartFile image, HttpServletRequest request,@RequestHeader("Authorization") String token) throws Exception {

        if (!recipeImageService.isImagePresent(image))
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("{ \"error\": \"Select a file\" }");
        if (!recipeImageService.isFileFormatRight(image.getContentType()))
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("{ \"error\": \"Image File Format Wrong\" }");

        Recipie recipie = recipieDao.findByRecipeid(idRecipe);

        if (recipieService.isRecipeImagePresent(recipie)) {
            LOGGER.warn("POST->Cover exist already perform PUT to modify");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("{ \"error\": \"POST->Recipe Image exist already perform PUT to modify\" }");
        }

        String userDetails[] = decryptAuthenticationToken(token);

        if (recipie != null) {

            if (recipie.getUser().getEmailId().equalsIgnoreCase(userDetails[0])){

                RecipeImage recipeImage = new RecipeImage();
                String photoNewName = image.getOriginalFilename();
                recipeImage = recipeImageService.uploadImage(image, photoNewName,recipie.getRecipeId(),recipeImage);
                recipie.setImage(recipeImage);
                Recipie rec = recipieDao.save(recipie);
                RecipeImage recImg = rec.getImage();
                return ResponseEntity.status(HttpStatus.CREATED).body(recImg);

            }
            else{
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("");
            }
        }
        else {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("{ \"error\": \"Recipe not Found\" }");
        }
    }


    @DeleteMapping("/v1/recipie/{idRecipe}/image/{idImage}")
    public ResponseEntity<?> deleteRecipeImage(@PathVariable String idRecipe, @PathVariable String idImage,@RequestHeader("Authorization") String token) throws Exception {

        String userDetails[] = decryptAuthenticationToken(token);

        Recipie recipie = recipieDao.findByRecipeid(idRecipe);

        if (recipie != null) {

            if (recipie.getUser().getEmailId().equalsIgnoreCase(userDetails[0])){

                RecipeImage recipeImgOfPassedrecipe = recipie.getImage();
                if (recipeImgOfPassedrecipe != null){
                    RecipeImage recipeImage = recipeImageDao.findByImageId(idImage);
                    if (recipeImage != null){
                        if (recipeImgOfPassedrecipe.getImageId().equals(recipeImage.getImageId())){
                            if (recipeImage != null) {
                                recipeImageService.deleteImage(recipeImage,recipie.getRecipeId());
                                recipie.setImage(null);
                                recipeImageDao.delete(recipeImage);
                                return ResponseEntity.status(HttpStatus.NO_CONTENT).body("");
                            }
                            else {
                                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("");
                            }
                        }
                        else {
                            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("");
                        }
                    }
                    else{
                        return ResponseEntity.status(HttpStatus.NOT_FOUND).body("");
                    }
                }
                else {
                    return ResponseEntity.status(HttpStatus.NOT_FOUND).body("");
                }

            }
            else{
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("");
            }

        }
        else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("");
        }
    }

    @GetMapping("/v1/recipie/{idRecipe}/image/{idImage}")
    public ResponseEntity<?> getImage(@PathVariable String idRecipe, @PathVariable String idImage) throws Exception {

        Recipie recipie = recipieDao.findByRecipeid(idRecipe);;
        if (recipie != null) {
            RecipeImage recipeImage = recipeImageDao.findByImageId(idImage);
            if (recipeImage == null) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("");
            }
            else {
                if (recipie.getImage().getImageId().equals(recipeImage.getImageId())){
                    return ResponseEntity.status(HttpStatus.OK).body(recipeImage);
                }
                else{
                    return ResponseEntity.status(HttpStatus.NOT_FOUND).body("");
                }

            }

        }
        else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("");
        }
    }

    public String[] decryptAuthenticationToken(String token) throws UnsupportedEncodingException {
        String[] basicAuthToken = token.split(" ");
        byte[] authKeys = Base64.getDecoder().decode(basicAuthToken[1]);
        return new String(authKeys,"utf-8").split(":");
    }
}
