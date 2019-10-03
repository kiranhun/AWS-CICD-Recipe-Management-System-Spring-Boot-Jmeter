package com.allstars.Entity;

import javax.persistence.*;
import java.util.UUID;

@Entity
public class OrderedList {
    @Id
    @GeneratedValue
    @Column(name = "OListID", columnDefinition = "BINARY(16)")
    private UUID OListID;

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

    public UUID getOListID() {
        return OListID;
    }

    public void setOListID(UUID OListID) {
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
