docker pull nginx:alpine

# 2. Verify image is available
docker images nginx:alpine

# 3. Create and run the container
docker run -d --name nginx_2 nginx:alpine

# 4. Verify container is running
echo "Container Status:"
docker ps | grep nginx_2