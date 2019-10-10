package com.allstars.Entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import org.hibernate.annotations.GenericGenerator;
import org.hibernate.annotations.Type;

import javax.persistence.*;
import java.util.UUID;

@Entity
@JsonIgnoreProperties(value={"OListID"}, allowSetters= true)
public class OrderedList {

    @GeneratedValue(generator = "uuid")
    @GenericGenerator(name = "uuid", strategy = "uuid")
    @Column(name = "OListID", columnDefinition = "CHAR(32)")
    @Id
    private String OListID;

    @Column
    private Integer position;

    @Column
    private String items;



    public OrderedList(int position, String items) {
        this.position = position;
        this.items = items;
    }

    public OrderedList() {
    }

    public String getOListID() {
        return OListID;
    }

    public void setOListID(String OListID) {
        this.OListID = OListID;
    }

    public Integer getPosition() {
        return position;
    }

    public void setPosition(Integer position) {
        this.position = position;
    }

    public String getItems() {
        return items;
    }

    public void setItems(String items) {
        this.items = items;
    }
}
