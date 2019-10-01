package com.allstars.errors;

public class RecipieCreationStatus {

    private String cookTimeError;

    private String prepTimeError;

    private String titlerror;

    private String cuisineError;

    public RecipieCreationStatus() {
        cookTimeError = "-";
        prepTimeError = "-";
        titlerror = "-";
        cuisineError = "-";
    }

    public RecipieCreationStatus(String cookTimeError, String prepTimeError, String titlerror, String cuisineError) {
        this.cookTimeError = cookTimeError;
        this.prepTimeError = prepTimeError;
        this.titlerror = titlerror;
        this.cuisineError = cuisineError;
    }

    public String getCookTimeError() {
        return cookTimeError;
    }

    public void setCookTimeError(String cookTimeError) {
        this.cookTimeError = cookTimeError;
    }

    public String getPrepTimeError() {
        return prepTimeError;
    }

    public void setPrepTimeError(String prepTimeError) {
        this.prepTimeError = prepTimeError;
    }

    public String getTitlerror() {
        return titlerror;
    }

    public void setTitlerror(String titlerror) {
        this.titlerror = titlerror;
    }

    public String getCuisineError() {
        return cuisineError;
    }

    public void setCuisineError(String cuisineError) {
        this.cuisineError = cuisineError;
    }
}
