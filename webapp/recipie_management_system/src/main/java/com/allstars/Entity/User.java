package com.allstars.Entity;
import org.hibernate.validator.constraints.UniqueElements;
import org.springframework.context.annotation.Primary;

import javax.persistence.*;
import java.util.Date;
import java.util.UUID;

@Entity
public class User {
    @Id
    //@GeneratedValue(strategy = GenerationType.AUTO)
    @Column(columnDefinition = "VARCHAR(40)")
    private String uuid;
    @Column
    private String fName;
    @Column
    private String lName;
    @Column(unique = true)
    private String emailid;
    @Column
    private String password;
    @Column
    private Date cTime;
    @Column
    private Date uTime;

    public User(String uuid, String fName, String lName, String emailid, String password, Date cTime, Date uTime) {
        this.uuid = uuid;
        this.fName = fName;
        this.lName = lName;
        this.emailid = emailid;
        this.password = password;
        this.cTime = cTime;
        this.uTime = uTime;
    }

    public User()
    {

    }

    public String getUuid() {
        return uuid;
    }

    public void setUuid(String uuid) {
        this.uuid = uuid;
    }

    public String getfName() {
        return fName;
    }

    public void setfName(String fName) {
        this.fName = fName;
    }

    public String getlName() {
        return lName;
    }

    public void setlName(String lName) {
        this.lName = lName;
    }

    public String getEmailid() {
        return emailid;
    }

    public void setEmailid(String emailid) {
        this.emailid = emailid;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public Date getcTime() {
        return cTime;
    }

    public void setcTime(Date cTime) {
        this.cTime = cTime;
    }

    public Date getuTime() {
        return uTime;
    }

    public void setuTime(Date uTime) {
        this.uTime = uTime;
    }
}
