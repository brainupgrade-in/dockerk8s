# DynamoDB
Table: rajesh-products
Primary Key: id
# Lambda
Name: rajesh-products
Code: index.js
# API GW
Name: rajesh-products

# To create routes
- GET /products/{id}
- GET /products
- PUT /products
- DELETE /products/{id}

# Integration Mapping
With lambda having lambda execution role

# To insert items
 curl  -X "PUT" -H "Content-Type: application/json" -d "{\"id\": \"1301\", \"price\": 10015, \"name\": \"sportswheel\"}" https://execute-api.ap-south-1.amazonaws.com/products

# To get all items
curl  https://execute-api.ap-south-1.amazonaws.com/products
# To get one item
curl  https://execute-api.ap-south-1.amazonaws.com/products
# To delete an item
curl -X DELETE  https://execute-api.ap-south-1.amazonaws.com/products



