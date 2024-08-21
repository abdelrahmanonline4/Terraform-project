# Multi-tier WebApp Deployment Migration to AWS using Terraform
# Project Overview

This project involves migrating a multi-tier web application to AWS. The deployment will be managed using Terraform and will include the following AWS services:

VPC (Virtual Private Cloud)
Security Groups
RDS (Relational Database Service)
Amazon MQ
Elastic Cache
EC2 Instances
Elastic Load Balancer (ELB(
  # Architecture Diagram
  ![image](https://github.com/user-attachments/assets/e88635cc-aac8-4f2b-a3dc-4769c987c970)

ok Now let's start the project, we must prepare the iam user and create an account to fetch the secret key and public key information and put them in provider.tf 


create file " main.tf"

# Step 1: Create a VPC

![image](https://github.com/user-attachments/assets/d8b3f5bc-a448-477e-840b-da14a460df10)
# Step 2 Create A subnets 
  
![image](https://github.com/user-attachments/assets/dddaed29-abbb-4b4c-898a-e0beccaaf19a)

# step 3 create iGW 
![image](https://github.com/user-attachments/assets/067639e4-3ee5-4e97-8f11-645363727b9f)

# step 4 create route tables 
![image](https://github.com/user-attachments/assets/71367b8d-84a1-433b-a6f0-5ad84cda2185)
![image](https://github.com/user-attachments/assets/4453cd00-29e2-458d-be35-5ae3f27f3fa8)

# step 5 we create a sg group (backend , application , ELB)

# SG FOR ELB

![image](https://github.com/user-attachments/assets/a40bc0c2-3b8f-4d0d-b645-e09566344c2d)
# 2 : SG FOR APP
![image](https://github.com/user-attachments/assets/4588bde4-cccc-419a-8e36-49815bef1832)

# 3 : SG FOR Backend

![image](https://github.com/user-attachments/assets/25520c55-35d9-4947-a964-81825d36f2ad)

## Oh, after creating the entire network and the security group,
## we are now taking a special step. We will enter the create aws services
#########################################################################
# step 6 create Backend Services 
#step 1 create RDS 

![image](https://github.com/user-attachments/assets/1ae46a6f-f2d6-4600-befd-e67df4e6d7b0)

After install, you must do DB Initialization on any instance, and after it works, clear the instance or leave it optional. 

# ElastiCache  And Amazon MQ 

![image](https://github.com/user-attachments/assets/27e851ae-cb3e-47eb-881c-9012f3a79144)


# instance for my app

![image](https://github.com/user-attachments/assets/e538c0be-7b9b-4f07-8812-4e9c71fd1346)

#  Create Target group
![image](https://github.com/user-attachments/assets/3a6575b8-63c4-45a7-b672-584f1beae2fa)

# Create Load Balancer

![image](https://github.com/user-attachments/assets/c01f6268-1281-4955-85ef-d201d283c5ed)

 # Attach Target Group to Load Balancer 
 
 ![image](https://github.com/user-attachments/assets/d543561b-c1e3-4f0f-8dac-0b3951e8bc56)

# Attach Instance to Target Group
![image](https://github.com/user-attachments/assets/0139bc3a-08bf-42ea-94fe-f586d8f4afbb)



# After you finish writing the project, write 

terraform init 
terraform plan
terraform apply

# What problems am I fighting and what is the solution to them 

 # First of all you should do DB Initialization 
    After install RDS , you must do DB Initialization  on any instance, and after it works, clear the instance or leave it optional. 

    logging in to RDS

    mysql -h ##endpointrds -u admin -p
and intialize ok 


# go to security group backend add 
  Make the back and connect for each other  
  
![image](https://github.com/user-attachments/assets/7b83fb10-ce0d-4acc-9f94-59557540d053)



# done this app

![image](https://github.com/user-attachments/assets/b698328b-da07-4704-9295-c15131d1e7eb)

![image](https://github.com/user-attachments/assets/ee40d0de-1139-42fb-bbbe-25b634649d33)







