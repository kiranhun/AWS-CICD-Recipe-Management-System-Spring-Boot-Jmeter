package com.allstars.Service;

import com.allstars.Dao.Userdao;
import com.allstars.Entity.User;
import com.allstars.Entity.UserDetailsCustom;
import com.allstars.errors.RegistrationStatus;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;

@Service
public class UserService implements UserDetailsService {

    @Autowired
    private Userdao userDao;

    @Autowired
    private BCryptPasswordEncoder passwordEncoder;

    public User saveUser(User user){

        try {
            passwordEncoder = new BCryptPasswordEncoder();
            user.setPassword(passwordEncoder.encode(user.getPassword()));
            user = userDao.save(user);
        } catch (Exception e){
            return null;
        }
        return  user;
    }


    public Boolean isEmailPresent(String emailId) {
        return userDao.isEmailPresent(emailId) > 0 ? true : false;
    }

    public User getUser(String emailId) {
        return userDao.findByEmailId(emailId);
    }

    @Override
    public UserDetails loadUserByUsername(String emailId) throws UsernameNotFoundException {
        User user = userDao.findByEmailId(emailId);
        if(user==null) throw new UsernameNotFoundException("User with given emailId does not exist");
        else return new UserDetailsCustom(user);
    }

    public RegistrationStatus getRegistrationStatus(BindingResult errors) {
        FieldError emailIdError = errors.getFieldError("emailId");
        FieldError passwordError = errors.getFieldError("password");
        String emailIdErrorMessage = emailIdError == null ? "-" : emailIdError.getCode();
        String passwordErrorMessage = passwordError == null ? "-" : passwordError.getCode();
        RegistrationStatus registrationStatus = new RegistrationStatus(emailIdErrorMessage, passwordErrorMessage);
        return registrationStatus;
    }

}
