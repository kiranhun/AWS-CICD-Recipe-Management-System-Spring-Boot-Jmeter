package com.allstars.Entity;

import javax.persistence.*;
import java.util.UUID;

@Entity
public class OrderedList {
    @Id
    @GeneratedValue
    @Column(name = "uuid", columnDefinition = "BINARY(16)")
    private UUID OListID;

    @Column
    private int position;

    @Column
    private String items;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "recipie_id")
    private Recipie recipie;

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

    public int getPosition() {
        return position;
    }

    public void setPosition(int position) {
        this.position = position;
    }

    public String getItems() {
        return items;
    }

    public void setItems(String items) {
        this.items = items;
    }
}
