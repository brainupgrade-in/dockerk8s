#1 Auth Microservice
k create deploy authdb --image mariadb:10.3
k set env deploy authdb --env MYSQL_ROOT_PASSWORD=auth --env  MYSQL_DATABASE=auth --env MYSQL_USER=auth --env MYSQL_PASSWORD=auth
k create svc clusterip authdb --tcp=3306:3306
k create deploy authentication --image brainupgrade/global-bank-authentication:1.0.0
k set env deploy authentication --env spring.datasource.url=jdbc:mariadb://authdb:3306/auth --env spring.datasource.driverClassName=org.mariadb.jdbc.Driver --env spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MariaDBDialect --env spring.datasource.username=auth --env spring.datasource.password=auth --env spring.jpa.hibernate.ddl-auto=create --env server.port=80
k create svc clusterip authentication --tcp=80:80

#2 Rules Microservice
k create deploy rules --image brainupgrade/global-bank-rules:1.0.0
k set env deploy rules --env feign.url-account-service=account/account --env feign.url-auth-service=authentication/auth --env server.port=80
k create svc clusterip rules --tcp=80:80

#3 Customer Microservice
k create deploy customerdb --image mariadb:10.3
k set env deploy customerdb --env MYSQL_ROOT_PASSWORD=customer --env  MYSQL_DATABASE=customer --env MYSQL_USER=customer --env MYSQL_PASSWORD=customer
k create svc clusterip customerdb --tcp=3306:3306
k create deploy customer --image brainupgrade/global-bank-customer:1.0.0
k set env deploy customer --env spring.datasource.url=jdbc:mariadb://customerdb:3306/customer --env spring.datasource.username=customer --env spring.datasource.password=customer  --env spring.datasource.driverClassName=org.mariadb.jdbc.Driver --env spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MariaDBDialect --env spring.jpa.hibernate.ddl-auto=create --env server.port=80 --env feign.url-account-service=account/account --env feign.url-auth-service=authentication/auth
k create svc clusterip customer --tcp=80:80

#4 Accounts Microservice
k create deploy accountdb --image mariadb:10.3
k set env deploy accountdb --env MYSQL_ROOT_PASSWORD=account --env  MYSQL_DATABASE=account --env MYSQL_USER=account --env MYSQL_PASSWORD=account
k create svc clusterip accountdb --tcp=3306:3306
k create deploy account --image brainupgrade/global-bank-account:1.0.0
k set env deploy account --env spring.datasource.url=jdbc:mariadb://accountdb:3306/account --env spring.datasource.username=account --env spring.datasource.password=account  --env spring.datasource.driverClassName=org.mariadb.jdbc.Driver --env spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MariaDBDialect --env spring.jpa.hibernate.ddl-auto=create --env server.port=80 --env feign.url-customer-service=customer/customer --env feign.url-auth-service=authentication/auth --env feign.url-transaction-service=transaction/transaction
k create svc clusterip account --tcp=80:80

#5 Transaction Microservice
k create deploy transactiondb --image mariadb:10.3
k set env deploy transactiondb --env MYSQL_ROOT_PASSWORD=transaction --env  MYSQL_DATABASE=transaction --env MYSQL_USER=transaction --env MYSQL_PASSWORD=transaction
k create svc clusterip transactiondb --tcp=3306:3306
k create deploy transaction --image brainupgrade/global-bank-transaction:1.0.0
k set env deploy transaction --env spring.datasource.url=jdbc:mariadb://transactiondb:3306/transaction --env spring.datasource.username=transaction --env spring.datasource.password=transaction  --env spring.datasource.driverClassName=org.mariadb.jdbc.Driver --env spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MariaDBDialect --env spring.jpa.hibernate.ddl-auto=create --env server.port=80 --env feign.url-account-service=account/account --env feign.url-rule-service=rules/rules
k create svc clusterip transaction --tcp=80:80

#6 Frontend
k create deploy frontend --image brainupgrade/global-bank-frontend:2.0.0
k create svc clusterip frontend --tcp=80:80