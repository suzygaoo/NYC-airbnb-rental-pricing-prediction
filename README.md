# Content: Supervised Learning
## Project: Airbnb Rental Price Prediction 

### Introduction:

This is an individual project for Airbnb NYC rental price prediction using over 90 vairables on the property, host, and past reviews. I will use Linear Regression and Trees to create models predicting Airbnb rental price using attributes in the given dataset. At the end of this report, I will be comparing the prediction result based on different techniques, and a list of submission will be attached for reference.

### Enviorment

R Studio


### Data 
The NYC airbnb rental data is included as a selection of over 25,000 data points collected on data for Airbnb rental information in NYC. More information can be found on the kaggel website: https://www.kaggle.com/c/airbnblala1


### Features
id <br/>
listing_url <br/>
scrape_id<br/>
last_scraped<br/>
name<br/>
summary<br/>
space<br/>
description<br/>
experiences_offered<br/>
neighborhood_overview<br/>
notes<br/>
transit<br/>
access<br/>
interaction<br/>
house_rules<br/>
thumbnail_url<br/>
medium_url<br/>
picture_url<br/>
xl_picture_url<br/>
host_id<br/>
host_url<br/>
host_name<br/>
host_location<br/>
host_about<br/>
host_response_time<br/>
host_response_rate<br/>
host_acceptance_rate<br/>
host_is_superhost<br/>
host_thumbnail_url<br/>
host_picture_url<br/>
host_neighbourhood<br/>
host_listings_count<br/>
host_total_listings_count<br/>
host_verifications<br/>
host_has_profile_pic<br/>
host_identity_verified<br/>
street<br/>
neighbourhood<br/>
neighbourhood_cleansed<br/>
neighbourhood_group_cleansed<br/>
city<br/>
state<br/>
zipcode<br/>
market<br/>
smart_location<br/>
country_code<br/>
country<br/>
latitude<br/>
longitude<br/>
is_location_exact<br/>
property_type<br/>
room_type<br/>
accommodates<br/>
bathrooms<br/>
bedrooms<br/>
beds<br/>
bed_type<br/>
amenities<br/>
square_feet<br/>
price<br/>
weekly_price<br/>
monthly_price<br/>
security_deposit<br/>
cleaning_fee<br/>
guests_included<br/>
extra_people<br/>
minimum_nights<br/>
maximum_nights<br/>
calendar_updated<br/>
has_availability<br/>
availability_30<br/>
availability_60<br/>
availability_90<br/>
availability_365<br/>
calendar_last_scraped<br/>
number_of_reviews<br/>
first_review<br/>
last_review<br/>
review_scores_rating<br/>
review_scores_accuracy<br/>
review_scores_cleanliness<br/>
review_scores_checkin<br/>
review_scores_communication<br/>
review_scores_location<br/>
review_scores_value<br/>
requires_license<br/>
license<br/>
jurisdiction_names<br/>
instant_bookable<br/>
is_business_travel_ready<br/>
cancellation_policy<br/>
require_guest_profile_picture<br/>
require_guest_phone_verification<br/>
calculated_host_listings_count<br/>
reviews_per_month
