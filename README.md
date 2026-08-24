# GoExplore-data-analytics-project
End-to-end data analytics project —  Google Sheets → BigQuery → Data Studio —  building a self-service CEO dashboard  for GoExplore outdoor sports supplier  covering revenue, profit, European expansion  and retailer performance across 21 markets

# GoExplore Data Description

## Source
Raw data provided as CSV files
Uploaded to Google Sheets first
Then connected to BigQuery

## Tables

### daily_sales
- 149,257 rows
- Columns: Date, Retailer_code, 
  Product_number, Order_method_code,
  Quantity, Unit_price, Unit_sale_price
- Date range: 2015 to 2018

### Products  
- 244 products
- Columns: Product_number, Product,
  Product_line, Product_type,
  Product_brand, Product_color,
  Unit_cost, Unit_price
- 5 product lines:
  - Camping Equipment
  - Golf Equipment
  - Personal Accessories
  - Mountaineering Equipment
  - Outdoor Protection

### Retailers
- 289 retailers
- Columns: Retailer_code, Retailer_name,
  Type, Country
- 21 countries
- 8 retailer types:
  - Department Store
  - Outdoors Shop
  - Golf Shop
  - Sports Store
  - Warehouse Store
  - Eyewear Store
  - Direct Marketing
  - Equipment Rental Store

### Methods
- 7 order methods
- Columns: Order_method_code,
  Order_method_type
- Methods: Web, Telephone, E-mail,
  Sales visit, Mail, Special, Fax
