# Create Database
CREATE DATABASE HouseSales;

# Use the Database
USE HouseSales;

# import the dataset in the database

rename table raw_sales to saleinfo;
describe saleinfo;

# Data exploration should be done in before finding the patterns in the data

			#Basic Details
select count(*) from saleinfo; # 29580 records exist
select distinct(postcode) from saleinfo; # 27 unique post codes
select distinct bedrooms from saleinfo;# there are min of 0 to max of 5 bedrooms
select distinct year(str_to_date(datesold, "%Y-%m-%d %H:%i:%s")) as DateSold from saleinfo; # year of sales is from 2007 to 2019

			#Property Details
select distinct propertytype from saleinfo;# house and unit are 2 types of properties
select count(*) from saleinfo where bedrooms = 0; # 30 0 bedrooms
select count(*) from saleinfo where bedrooms = 1; #1627 1 bedrooms
select count(*) from saleinfo where bedrooms = 2; #3598 2 bedrooms
select count(*) from saleinfo where bedrooms = 3; #11933 3 bedrooms
select count(*) from saleinfo where bedrooms = 4; #10442 4 bedrooms
select count(*) from saleinfo where bedrooms = 5; #1950 5 bedrooms
# most of the houses sold have 3 and 4 bedrooms and the least sold houses are zero bedrooms

select postcode from saleinfo where length(postcode) > 4;
# the length of post code is 4 no null values

# avg,min and max prices of house sold
select max(price) from saleinfo;#800000
select min(price) from saleinfo;#56500
select avg(price) from saleinfo;#609736.2622

			# Geography Details
select avg(price) as avg_price, postcode from saleinfo group by postcode;# avg price with respect to post code
select max(price) as max_price, postcode from saleinfo group by postcode;# max price with respect to post code
select min(price) as min_price, postcode from saleinfo group by postcode;# min price with respect to post code
select max(price) as max_price, postcode from saleinfo group by postcode order by max(price) desc limit 1;# 2611 postcode has the maximum price
select min(price) as min_price, postcode from saleinfo group by postcode order by max(price)  limit 1;# 2609 postcode has the minimum price
select count(propertytype) as no_of_properties_sold,postcode from saleinfo group by postcode; # count of properties sold with respect to postcode
select count(propertytype) as max_no_of_properties_sold,postcode from saleinfo group by postcode order by count(propertytype) desc limit 1;#2615 post code has most number of properties sold
select count(propertytype) as min_no_of_properties_sold,postcode from saleinfo group by postcode order by count(propertytype)  limit 1;#2618 post code has min number of properties sold
select count(propertytype) as house_type from saleinfo where propertytype like "%house%";#24522 houses sold of type house
select count(propertytype) as unit_type from saleinfo where propertytype like "%unit%";#5028 houses sold of type unit

			#Time based Analysis
# How many properties were sold in each year or month?
select count(*) as countofproperty,  year(str_to_date(datesold, "%Y-%m-%d %H:%i:%s")) as year from saleinfo group by year(str_to_date(datesold, "%Y-%m-%d %H:%i:%s"));

# How many house type sold in each year
select count(propertytype) as house_type, year(str_to_date(datesold, "%Y-%m-%d %H:%i:%s")) as year  from saleinfo where propertytype like "%house%" 
group by year(str_to_date(datesold, "%Y-%m-%d %H:%i:%s"));

# How many unit type sold in each year
select count(propertytype) as unit_type, year(str_to_date(datesold, "%Y-%m-%d %H:%i:%s")) as year  from saleinfo where propertytype like "%unit%" 
group by year(str_to_date(datesold, "%Y-%m-%d %H:%i:%s"));

# which type of property are sold more with respect to year
select (count(propertytype)) as max_sold_propertytype, propertytype, year(str_to_date(datesold, "%Y-%m-%d %H:%i:%s")) as year 
from saleinfo group by propertytype, year(str_to_date(datesold, "%Y-%m-%d %H:%i:%s")) order by (count(propertytype)) desc limit 1  ;

# house type of property is sold out in which year
select (count(propertytype)) as max_sold_propertytype, propertytype, year(str_to_date(datesold, "%Y-%m-%d %H:%i:%s")) as year 
from saleinfo where propertytype like "%house%" 
group by propertytype, year(str_to_date(datesold, "%Y-%m-%d %H:%i:%s")) order by (count(propertytype)) desc limit 1  ;

# unit type of property is sold out in which year
select (count(propertytype)) as max_sold_propertytype, propertytype, year(str_to_date(datesold, "%Y-%m-%d %H:%i:%s")) as year 
from saleinfo where propertytype like "%unit%" 
group by propertytype, year(str_to_date(datesold, "%Y-%m-%d %H:%i:%s")) order by (count(propertytype)) desc limit 1  ;

#Compare the average sale prices of different property types.
select propertytype, avg(price)
from saleinfo
group by propertytype;
# average price of house type is more than the average price of unit type

#Compare the average sale prices in different postcodes.
select postcode, propertytype, avg(price)
from saleinfo
group by propertytype,postcode;

# Which date corresponds to the highest number of sales?
select count(*) as count_of_sales, str_to_date(datesold, "%Y-%m-%d %H:%i:%s") as DateSold
from saleinfo group by str_to_date(datesold, "%Y-%m-%d %H:%i:%s") order by count_of_sales desc limit 1;

# Find out the postcode with the highest average price per sale? (Using Aggregate Functions)
select postcode, avg(price) as highest_average_price
from saleinfo
group by postcode
order by highest_average_price desc limit 1;

# Which year witnessed the lowest number of sales?
select count(*) as count_of_sales, year(str_to_date(datesold, "%Y-%m-%d %H:%i:%s")) as YearSold
from saleinfo
group by YearSold
order by count_of_sales limit 1;

# Use the window function to deduce the top six postcodes by year's price.
with subquery as(
select postcode, price,year(str_to_date(datesold, "%Y-%m-%d %H:%i:%s")) as YearSold,
dense_rank() over (partition by year(str_to_date(datesold, "%Y-%m-%d %H:%i:%s")) order by price desc) as rnk
from saleinfo)
select * from subquery 
where rnk <= 6;