#import and read data
train= read.csv('analysisData.csv')
test = read.csv('scoringData.csv')

str(train)
dim(train)
names(train)


######Combine test and train data
######test$price <- NA
######data <- bind_rows(train, test)
######train.row <- 1:nrow(train)
######test.row <- (1 + nrow(train)):(nrow(train) + nrow(test))


#explore missing value on train data
temp <- sapply(train, function(x)  sum(is.na(x)))
miss <- sort(temp, decreasing=T)
miss[miss>0]
summary(train[,names(miss)[miss>0]])

#after knowing which variable has NA values, see if we can input manualy or remove it
library(dplyr)
train%>%
  summarize(mode(beds))

#first step, remove obvious dirty/unusable variables
library(tidyr)
library(dplyr)
train <- select(train, -listing_url,-scrape_id,-last_scraped,-name,-summary,
                -space,-description,-experiences_offered,-neighborhood_overview,
                -notes,-transit,-access,-interaction,-house_rules,-thumbnail_url,
                -medium_url,-xl_picture_url,-host_id,-host_url,-host_name,-host_since,
                -host_about,-jurisdiction_names,-picture_url,-host_acceptance_rate,
                -host_thumbnail_url,-host_picture_url,-amenities,-first_review,
                -last_review,-requires_license,-license,-country,-country_code,
                -has_availability,-calendar_last_scraped)


#variable street and smart_location too dirty, remove them
as.data.frame(table(train$street))
as.data.frame(table(test$street))

as.data.frame(table(train$smart_location))
as.data.frame(table(test$smart_location))
##### or use train$market == NULL
##### or use train$street == NULL
train <- select(train, -market, -street, -smart_location,-state,-host_neighbourhood,
                -weekly_price, -monthly_price,-square_feet,-host_verifications,
                -host_has_profile_pic,-require_guest_profile_picture,
                -require_guest_phone_verification, -city, -host_location)

##### remove unusable features in test set too

#see the class of features in train data
table(sapply(train,class))

# make some changes to description variable
####train$description = as.character(train$description)
####train$charCountDescription = nchar(train$description) 
####train$noDescription = as.numeric(!train$description=="") 
####train$description = NULL

library(dplyr)
library(ggplot2)
library(Formula)
library(lattice)
library(Hmisc)
library(caret)

###impute missing value using Hmisc(example)
###train$host_response_rate = as.numeric(train$host_response_rate)
###impute(train$host_response_rate, median(train$host_response_rate))--->not working???
###summary(train$host_response_rate)

#impute "1" to all NA values to beds
as.data.frame(table(train$beds)) #to see the most frequent number
train$beds[is.na(train$beds)] <- "1" #now we got all NA imputed except cleaning_fee and security_deposit
### or: train$beds[is.na(train$beds)] <- mean(train$beds, na.rm = T)
test$beds[is.na(test$beds)] <- "1"
train$beds <- as.numeric(train$beds)
test$beds <- as.numeric(test$beds)

####remember to impute NA values for beds in test data too

#do the same for test data
temp1 <- sapply(test, function(x)  sum(is.na(x)))
miss <- sort(temp1, decreasing=T)
miss[miss>0]
summary(test[,names(miss)[miss>0]])
###variables with NAs: urls, license,monthly_price,square_feet,weekly_price,security_deposit
###cleaning_fee,zipcode,reviews_per_month

#impute NA values in variable cleaning_fee and security_deposit, similarly
summary(train$cleaning_fee)
train$cleaning_fee[is.na(train$cleaning_fee)] <- "50"
summary(test$cleaning_fee)
test$cleaning_fee[is.na(test$cleaning_fee)] <- "50"
train$cleaning_fee <- as.numeric(train$cleaning_fee)
test$cleaning_fee <- as.numeric(test$cleaning_fee)

summary(train$security_deposit)
train$security_deposit[is.na(train$security_deposit)] <- median(train$security_deposit,na.rm = T)
summary(test$security_deposit)
test$security_deposit[is.na(test$security_deposit)] <- median(test$security_deposit,na.rm = T)


#impute data for NAs in reviews_per_month in test dataset
summary(test$reviews_per_month)
test$reviews_per_month[is.na(test$reviews_per_month)] <- "0.72"
test$reviews_per_month <- as.numeric(test$reviews_per_month)

#make some plots to see the corrolation between variables
library(corrplot)
subset_1  <- train[,c('price','bedrooms','beds','cleaning_fee','guests_included','extra_people')]
corrplot(cor(subset_1),method = 'square',type = 'full',diag = F)

# Change color and display only lower trianglgular matrix 
col2 = colorRampPalette(c('#d73027', '#fc8d59','#fee08b','#ffffbf','#d9ef8b','#91cf60','#1a9850'))
corrplot(cor(subset_1),method = 'square',type = 'lower',diag = F, col=col2(7))


#Build linear models

model1 = lm(price~bathrooms+bedrooms+room_type+review_scores_location
            +longitude+latitude+beds+cleaning_fee,data=train)
summary(model1)
pred = predict(model1,newdata=test)


model2 = lm(price ~ bathrooms*bedrooms*room_type*beds+
                      review_scores_location*longitude*latitude+host_listings_count
                      +minimum_nights+reviews_per_month
                      +guests_included+accommodates+cleaning_fee+security_deposit
                      +review_scores_value+review_scores_location
                      +review_scores_cleanliness,data = train)
summary(model2)
pred = predict(model2,newdata=test)


model3 = lm(price ~ bathrooms*bedrooms*beds*room_type+property_type + 
              longitude*latitude*neighbourhood+minimum_nights*cleaning_fee*accommodates 
              +review_scores_rating*number_of_reviews + 
              guests_included + availability_60 + availability_365+
              review_scores_checkin+review_scores_location, 
              data = train)
  
summary(model3)  
pred = predict(model3,newdata=test)


model4 = lm(price~ bathrooms+bedrooms*beds*cleaning_fee*guests_included+room_type+property_type 
            +longitude*latitude+neighbourhood+minimum_nights+cleaning_fee+accommodates 
            +review_scores_rating+number_of_reviews+review_scores_communication
            +availability_60+availability_365+host_identity_verified
              +review_scores_checkin+review_scores_location+calendar_updated,data = train)
  
summary(model4)
pred = predict(model4,newdata=test)

#stepforward model
start_mod = lm(quality~1,data=train)
empty_mod = lm(quality~1,data=train)
full_mod = lm(quality~id,data=train)
forwardStepwise = step(start_mod,scope=list(upper=full_mod,lower=empty_mod),direction='forward')
summary(forwardStepwise)
pred = predict(forwardStepwise,newdata=test)


#Lasso regression
library(glmnet)
LASSO_formula <- as.formula(price~ .-id )
x <- model.matrix(LASSO_formula, train)
y <- train$price
set.seed(1234)
lm.lasso <- cv.glmnet(x, y, alpha=1)
coef(lm.lasso)
### don't quite understand???
###test$price <- 1
###formula <- as.formula(class ~.)
###test_x <- model.matrix(formula, test)
###lm.pred <- predict(lm.lasso, newx = test_x, s = "lambda.min")


#Boosting model(too slow, maybe our dataset is too large??)
library(gbm)
library(caret)
set.seed(1234)
ctrl <- trainControl(method = "cv", number = 10, repeats = 20, verboseIter = TRUE)
lm.gbm <- train(price~ .-id, data = train,  method = "gbm",  trControl = ctrl)
lm.pred <- predict(lm.gbm, test)
submissionFile = data.frame(id= test$id, price = lm.pred) 
write.csv(submissionFile, 'sample_submission.csv',row.names = F)


# construct submision from predictions
submissionFile = data.frame(id= test$id, price = pred) 
write.csv(submissionFile, 'sample_submission.csv',row.names = F)


#since there are new levels in the test set, write the loop as below 
#to set new levels to the most frequent levels of neighbourhood in test set
for(i in 1:length(test[["neighbourhood"]])){
  if (test[["neighbourhood"]][i] == "Castleton Corners"|test[["neighbourhood"]][i] == "Marine Park"){
    test[["neighbourhood"]][i] <- levels(test[["neighbourhood"]])[which.max(table(test[["neighbourhood"]]))]
  }
  
}

#similarly, for property_type
for(i in 1:length(test[["property_type"]])){
  if (test[["property_type"]][i] == "Cottage"|test[["property_type"]][i] == "Hut"){
    test[["property_type"]][i] <- levels(test[["property_type"]])[which.max(table(test[["property_type"]]))]
  }
  
}

# Similar for calendar_updated
for(i in 1:length(test[["calendar_updated"]])){
  if (test[["calendar_updated"]][i] == "46 months ago"|test[["calendar_updated"]][i] == "47 months ago"|test[["calendar_updated"]][i] == "60 months ago"){
    test[["calendar_updated"]][i] <- levels(test[["calendar_updated"]])[which.max(table(test[["calendar_updated"]]))]
  }
  
}

##### ERROR: empty row in data???? ----- need to input NA in test data first
for(i in 1:length(test[["zipcode"]])){
  if (test[["zipcode"]][i] == "10080"|test[["zipcode"]][i] == "10550"|test[["zipcode"]][i] == "11363"){
    test[["zipcode"]][i] <- levels(test[["zipcode"]])[which.max(table(test[["zipcode"]]))]
  }
  
}
#input NA for test data
summary(test$zipcode)
test$zipcode[is.na(test$zipcode)] <- NULL #not working
test$zipcode[is.na(test$zipcode)] <- "None" #not working
test$zipcode[is.na(test$zipcode)] <- '11211' #using most frequent value, this worked,but not so reasonable


#reset levels in neighbourhood_cleased
for(i in 1:length(test[["neighbourhood_cleansed"]])){
  if (test[["neighbourhood_cleansed"]][i] == "Hollis Hills"|test[["neighbourhood_cleansed"]][i] == "Westerleigh"){
    test[["neighbourhood_cleansed"]][i] <- levels(test[["neighbourhood_cleansed"]])[which.max(table(test[["neighbourhood_cleansed"]]))]
  }
  
}

