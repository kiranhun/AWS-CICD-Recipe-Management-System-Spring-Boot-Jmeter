package com.allstars.Dao;

import com.allstars.Entity.Recipie;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface RecipieDao extends CrudRepository<Recipie, UUID> {
}
