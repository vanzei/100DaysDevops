# Day 018: Configure LAMP Server
xFusionCorp Industries is planning to host a WordPress website on their infra in Stratos Datacenter. They have already done infrastructure configuration—for example, on the storage server they already have a shared directory /vaw/www/html that is mounted on each app host under /var/www/html directory. Please perform the following steps to accomplish the task:



a. Install httpd, php and its dependencies on all app hosts.


b. Apache should serve on port 5000 within the apps.


c. Install/Configure MariaDB server on DB Server.


d. Create a database named kodekloud_db10 and create a database user named kodekloud_top identified as password BruCStnMT5. Further make sure this newly created user is able to perform all operation on the database you created.


e. Finally you should be able to access the website on LBR link, by clicking on the App button on the top bar. You should see a message like App is able to connect to the database using user kodekloud_top