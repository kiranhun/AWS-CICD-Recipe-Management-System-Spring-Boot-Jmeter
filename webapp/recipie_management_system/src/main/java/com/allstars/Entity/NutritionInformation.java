package com.allstars.Entity;

import javax.persistence.*;
import java.util.UUID;

@Entity
public class NutritionInformation {

    @Id
    @GeneratedValue
    @Column(name = "uuid", columnDefinition = "BINARY(16)")
    private UUID NuInfoID;

    @Column(nullable=false)
    private Integer calories;

    @Column(nullable=false)
    private Float cholesterol_in_mg;

    @Column(nullable=false)
    private Integer sodium_in_mg;

    @Column(nullable=false)
    private Float carbohydrates_in_grams;

    @Column(nullable=false)
    private Float protein_in_grams;


    public NutritionInformation(Integer calories, Float cholesterol_in_mg, Integer sodium_in_mg, Float carbohydrates_in_grams, Float protein_in_grams) {
        this.calories = calories;
        this.cholesterol_in_mg = cholesterol_in_mg;
        this.sodium_in_mg = sodium_in_mg;
        this.carbohydrates_in_grams = carbohydrates_in_grams;
        this.protein_in_grams = protein_in_grams;
    }

    public NutritionInformation() {
    }

    public UUID getNuInfoID() {
        return NuInfoID;
    }

    public void setNuInfoID(UUID nuInfoID) {
        NuInfoID = nuInfoID;
    }

    public Integer getCalories() {

        return calories;

    }

    public void setCalories(Integer calories) {
        this.calories = calories;
    }

    public Float getCholesterol_in_mg() {
        return cholesterol_in_mg;
    }

    public void setCholesterol_in_mg(Float cholesterol_in_mg) {
        this.cholesterol_in_mg = cholesterol_in_mg;
    }

    public Integer getSodium_in_mg() {
        return sodium_in_mg;
    }

    public void setSodium_in_mg(Integer sodium_in_mg) {
        this.sodium_in_mg = sodium_in_mg;
    }

    public Float getCarbohydrates_in_grams() {
        return carbohydrates_in_grams;
    }

    public void setCarbohydrates_in_grams(Float carbohydrates_in_grams) {
        this.carbohydrates_in_grams = carbohydrates_in_grams;
    }

    public Float getProtein_in_grams() {
        return protein_in_grams;
    }

    public void setProtein_in_grams(Float protein_in_grams) {
        this.protein_in_grams = protein_in_grams;
    }
}


