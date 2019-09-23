package com.allstars.Entity;

import java.util.Date;

public class User {
    private int uuid;
    private String fName;
    private String lName;
    private String emailid;
    private String password;
    private Date cTime;
    private Date uTime;

    public User(int uuid, String fName, String lName, String emailid, String password, Date cTime, Date uTime) {
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

    public int getUuid() {
        return uuid;
    }

    public void setUuid(int uuid) {
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
