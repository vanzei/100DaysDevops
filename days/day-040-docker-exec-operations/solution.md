docker exec -it kkloud bash
apt update

apt install apache2

# Replace port 80 with 8082 in ports.conf
sed -i 's/Listen 80/Listen 8082/g' /etc/apache2/ports.conf

# Replace port 80 with 8082 in default site
sed -i 's/:80>/:8082>/g' /etc/apache2/sites-available/000-default.conf

service apache2 status
netstat -tlnp | grep :8082
