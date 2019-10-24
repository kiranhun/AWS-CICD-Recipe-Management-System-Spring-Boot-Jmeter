package com.allstars.recipie_management_system.service;

import com.allstars.recipie_management_system.entity.RecipeImage;
import com.amazonaws.auth.AWSCredentials;
import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.s3.model.DeleteObjectsRequest;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.S3ObjectSummary;
import com.google.common.hash.HashCode;
import com.google.common.hash.Hashing;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import javax.annotation.PostConstruct;
import java.io.BufferedInputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.security.DigestInputStream;
import java.security.MessageDigest;
import java.util.Base64;
import java.util.Optional;

@Service
public class RecipeImageAwsService implements RecipeImageService {



    private final static Logger logger = LoggerFactory.getLogger(RecipeImageService.class);

    private AmazonS3 s3client;

    private String dir = "Images";



    @Value("${amazonProperties.endpointUrl}")
    private String endpointUrl;
    @Value("${amazonProperties.bucketName}")
    private String bucketName;
    @Value("${amazonProperties.accessKey}")
    private String accessKey;
    @Value("${amazonProperties.secretKey}")
    private String secretKey;




    @PostConstruct
    private void initializeAmazon() {
        AWSCredentials credentials = new BasicAWSCredentials(this.accessKey, this.secretKey);
        this.s3client = AmazonS3ClientBuilder.standard().withRegion("us-east-1").withCredentials(new AWSStaticCredentialsProvider(credentials)).build();

    }

    @Override
    public String uploadImage(MultipartFile multipartFile, String fileName, String recipeId) throws Exception {

        logger.info(multipartFile.getName());

        String name = this.dir + "/" + recipeId + "/" + fileName;

        logger.info(name);

        InputStream inputStream = null;
        try {
            inputStream = multipartFile.getInputStream();

        } catch (IOException e) {
            e.printStackTrace();
        }

//        HashCode hash = com.google.common.io.Files
//                .hash(new File(name), Hashing.md5());


//        byte[] buffer= new byte[8192];
//        int count;
//
//        MessageDigest md = MessageDigest.getInstance("MD5");
//        BufferedInputStream bis = new BufferedInputStream(inputStream);
//        DigestInputStream dis = new DigestInputStream(inputStream, md);
//
//        while ((count = bis.read(buffer)) > 0) {
//            md.update(buffer, 0, count);
//        }
//        bis.close();
//
//        byte[] hash = md.digest();

        s3client.putObject(bucketName, name, multipartFile.getInputStream(), new ObjectMetadata());

        String fileUrl = endpointUrl + "/" + bucketName + "/" + name;

        return fileUrl;

    }

    public String deleteImage(RecipeImage recipeImage, String recipeId) throws Exception {
        String fileUrl= recipeImage.getUrl();
        String fileName = "Images/"+ recipeId + "/" + fileUrl.substring(fileUrl.lastIndexOf("/") + 1);
        for (S3ObjectSummary file : s3client.listObjects(bucketName, fileName).getObjectSummaries()){
            s3client.deleteObject(bucketName, file.getKey());
        }
        return "Successfully deleted";
    }

}
