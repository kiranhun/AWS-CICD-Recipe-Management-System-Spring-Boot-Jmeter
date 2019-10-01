package com.allstars.Entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import org.hibernate.validator.constraints.Range;
import org.springframework.data.jpa.repository.Temporal;

import javax.persistence.*;

import java.util.*;

@Entity
@JsonIgnoreProperties(value={"user"}, allowSetters= true)
public class Recipie {
    @Id
    @GeneratedValue
    @Column(name = "recipeid", columnDefinition = "BINARY(16)")
    private UUID recipeid;

    @Column
    private Date created_ts;

    @Column
    private Date updated_ts;

    @ManyToOne(optional = true)
    @JoinColumn(name="uuid", nullable = true)
    private User user;

    @Column
    private UUID author_id;

    @Column
    private int cook_time_in_min;

    @Column
    private int prep_time_in_min;

    @Column
    private int total_time_in_min;

    @Column
    private String title;

    @Column
    private String cuisine;

    @Column
    @Range(min=1, max=5)
    private String servings;

    @Column
    @ElementCollection
    private List<String> ingredients;

    @OneToMany(cascade = CascadeType.ALL,orphanRemoval = true)
    @JoinColumn(name="join_id")
    private Set<OrderedList> steps;

    @OneToOne(cascade = CascadeType.ALL)
    @JoinColumn(unique = true)
    private NutritionInformation nutritionInformation;

    public Recipie(Date created_ts, Date updated_ts, int cook_time_in_min, int prep_time_in_min, int total_time_in_min, String title, String cuisine, @Range(min = 1, max = 5) String servings, List<String> ingredients, Set<OrderedList> steps, NutritionInformation nutritionInformation) {
        this.created_ts = created_ts;
        this.updated_ts = updated_ts;
        this.cook_time_in_min = cook_time_in_min;
        this.prep_time_in_min = prep_time_in_min;
        this.total_time_in_min = total_time_in_min;
        this.title = title;
        this.cuisine = cuisine;
        this.servings = servings;
        this.ingredients = ingredients;
        this.steps = steps;
        this.nutritionInformation = nutritionInformation;
    }

    public Recipie() {
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public UUID getAuthor_id() {
        return author_id;
    }

    public void setAuthor_id(UUID author_id) {
        this.author_id = author_id;
    }

    public UUID getRecipeId() {
        return recipeid;
    }

    public void setRecipeId(UUID recipeId) {
        this.recipeid = recipeId;
    }

    public Date getCreated_ts() {
        return created_ts;
    }

    public void setCreated_ts() {

            this.created_ts = new Date();

    }

    public Date getUpdated_ts() {
        return updated_ts;
    }

    public void setUpdated_ts() {

            this.updated_ts = new Date();

    }

    public int getCook_time_in_min() {
        return cook_time_in_min;
    }

    public void setCook_time_in_min(int cook_time_in_min) {
        this.cook_time_in_min = cook_time_in_min;
    }

    public int getPrep_time_in_min() {
        return prep_time_in_min;
    }

    public void setPrep_time_in_min(int prep_time_in_min) {
        this.prep_time_in_min = prep_time_in_min;
    }

    public int getTotal_time_in_min() {
        return total_time_in_min;
    }

    public void setTotal_time_in_min() {
        this.total_time_in_min = this.cook_time_in_min + this.prep_time_in_min;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getCuisine() {
        return cuisine;
    }

    public void setCuisine(String cuisine) {
        this.cuisine = cuisine;
    }

    public String getServings() {
        return servings;
    }

    public void setServings(String servings) {
        this.servings = servings;
    }

    public List<String> getIngredients() {
        return ingredients;
    }

    public void setIngredients(List<String> ingredients) {
        this.ingredients = ingredients;
    }

    public Set<OrderedList> getSteps() {
        return steps;
    }

    public void setSteps(Set<OrderedList> steps) {
        this.steps = steps;
    }

    public NutritionInformation getNutritionInformation() {
        return nutritionInformation;
    }

    public void setNutritionInformation(NutritionInformation nutritionInformation) {
        this.nutritionInformation = nutritionInformation;
    }
}

