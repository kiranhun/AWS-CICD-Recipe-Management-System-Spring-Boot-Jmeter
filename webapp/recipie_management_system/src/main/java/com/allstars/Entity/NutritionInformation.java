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
    private int calories;

    @Column(nullable=false)
    private float cholesterol_in_mg;

    @Column(nullable=false)
    private int sodium_in_mg;

    @Column(nullable=false)
    private float carbohydrates_in_grams;

    @Column(nullable=false)
    private float protein_in_grams;

    @OneToOne(mappedBy = "nutritionInformation")
    private Recipie recipie;

    public NutritionInformation(int calories, float cholesterol_in_mg, int sodium_in_mg, float carbohydrates_in_grams, float protein_in_grams, Recipie recipie) {
        this.calories = calories;
        this.cholesterol_in_mg = cholesterol_in_mg;
        this.sodium_in_mg = sodium_in_mg;
        this.carbohydrates_in_grams = carbohydrates_in_grams;
        this.protein_in_grams = protein_in_grams;
        this.recipie = recipie;
    }

    public NutritionInformation() {
    }

    public UUID getNuInfoID() {
        return NuInfoID;
    }

    public void setNuInfoID(UUID nuInfoID) {
        NuInfoID = nuInfoID;
    }

    public int getCalories() {
        return calories;
    }

    public void setCalories(int calories) {
        this.calories = calories;
    }

    public float getCholesterol_in_mg() {
        return cholesterol_in_mg;
    }

    public void setCholesterol_in_mg(float cholesterol_in_mg) {
        this.cholesterol_in_mg = cholesterol_in_mg;
    }

    public int getSodium_in_mg() {
        return sodium_in_mg;
    }

    public void setSodium_in_mg(int sodium_in_mg) {
        this.sodium_in_mg = sodium_in_mg;
    }

    public float getCarbohydrates_in_grams() {
        return carbohydrates_in_grams;
    }

    public void setCarbohydrates_in_grams(float carbohydrates_in_grams) {
        this.carbohydrates_in_grams = carbohydrates_in_grams;
    }

    public float getProtein_in_grams() {
        return protein_in_grams;
    }

    public void setProtein_in_grams(float protein_in_grams) {
        this.protein_in_grams = protein_in_grams;
    }

    public Recipie getRecipie() {
        return recipie;
    }

    public void setRecipie(Recipie recipie) {
        this.recipie = recipie;
    }
}
