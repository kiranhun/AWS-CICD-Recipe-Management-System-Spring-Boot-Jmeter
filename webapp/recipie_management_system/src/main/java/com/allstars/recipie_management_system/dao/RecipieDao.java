package com.allstars.recipie_management_system.dao;

import com.allstars.recipie_management_system.entity.Recipie;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface RecipieDao extends CrudRepository<Recipie, String> {

    Recipie findByRecipeid(String id);

    List<Recipie> findByAuthorid(String author_id);

    Recipie findTopByOrderByCreatedtsDesc();
}
