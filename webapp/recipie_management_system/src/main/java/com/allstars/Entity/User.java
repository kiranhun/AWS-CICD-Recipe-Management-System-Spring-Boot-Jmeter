package com.allstars.Entity;

import javax.persistence.*;
import java.util.Date;
import java.util.UUID;

@Entity
public class User {
    @Id
    @GeneratedValue
    @Column(name = "uuid", columnDefinition = "BINARY(16)")
    private UUID uuid;
    @Column
    private String fName;
    @Column
    private String lName;
    @Column
    private String emailId;
    @Column(nullable=false)
    private String password;
    @Column
    private Date cTime;
    @Column
    private Date uTime;

    public User(UUID uuid, String fName, String lName, String emailId, String password, Date cTime, Date uTime) {
        this.uuid = uuid;
        this.fName = fName;
        this.lName = lName;
        this.emailId = emailId;
        this.password = password;
        this.cTime = cTime;
        this.uTime = uTime;

    }

    public User()
    {

    }

    public UUID getUuid() {
        return uuid;
    }

    public void setUuid(UUID uuid) {
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

    public String getEmailId() {
        return emailId;
    }

    public void setEmailId(String emailId) {
        this.emailId = emailId;
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
