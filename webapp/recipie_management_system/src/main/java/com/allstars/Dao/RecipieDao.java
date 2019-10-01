package com.allstars.Dao;

import com.allstars.Entity.Recipie;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface RecipieDao extends CrudRepository<Recipie, UUID> {

    Recipie findByRecipeid(UUID id);

    //Recipie findByRecipeId(UUID recipeid);

    /*@Query("SELECT count(recipeid) FROM recipie WHERE recipeid=:recipeid")
    int isRecipiePresent(@Param("recipeid") UUID recipeid);*/
}
