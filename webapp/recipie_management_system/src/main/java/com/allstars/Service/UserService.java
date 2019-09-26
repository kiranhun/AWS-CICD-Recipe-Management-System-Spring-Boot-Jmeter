package com.allstars.Service;

import com.allstars.Dao.Userdao;
import com.allstars.Entity.User;
import com.allstars.Entity.UserDetailsCustom;
import com.allstars.errors.RegistrationStatus;
import org.passay.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;

import java.util.Arrays;
import java.util.Date;

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

    public Boolean updateUserInfo(User newUser, String emailId, String Password){
        if (newUser.getEmailId()!=null || newUser.getcTime()!=null || newUser.getuTime()!=null || newUser.getUuid()!=null){
            return false;
        }
        else{
            User currUser = userDao.findByEmailId(emailId);
            if(currUser.getEmailId().equals(emailId)) {

                    PasswordValidator validator = new PasswordValidator(Arrays.asList(
                            new LengthRule(9, 30),
                            new CharacterRule(EnglishCharacterData.UpperCase, 1),
                            new CharacterRule(EnglishCharacterData.LowerCase, 1),
                            new CharacterRule(EnglishCharacterData.Digit, 1),
                            new CharacterRule(EnglishCharacterData.Special, 1),
                            new WhitespaceRule()));
                    RuleResult result = validator.validate(new PasswordData(newUser.getPassword()));
                    if(result.isValid()) {
                        currUser.setfName(newUser.getfName());
                        currUser.setlName(newUser.getlName());
                        currUser.setPassword(passwordEncoder.encode(newUser.getPassword()));
                        currUser.setuTime(new Date());
                        userDao.save(currUser);
                        return true;
                    }
                    else{
                        return false;
                    }

            }
            else{
                return false;
            }
        }

    }

}
