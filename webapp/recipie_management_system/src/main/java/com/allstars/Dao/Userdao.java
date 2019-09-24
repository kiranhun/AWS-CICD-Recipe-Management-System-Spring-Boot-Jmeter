package com.allstars.Dao;

import com.allstars.Entity.User;
import org.springframework.stereotype.Repository;
import org.springframework.data.repository.CrudRepository;


import java.util.Collection;
import java.util.Date;
import java.util.HashMap;


@Repository
public interface Userdao extends CrudRepository<User, Long>{

}
