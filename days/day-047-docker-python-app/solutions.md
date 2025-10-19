docker build -t nautilus/python-app .

docker run -d \
  --name pythonapp_nautilus \
  -p 8091:8082 \
  nautilus/python-app