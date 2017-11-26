sed -i "" 's/localhost/db/' endpoints/src/main/resources/application.properties
sed -i "" 's/localhost/db/' scheduler/src/main/resources/application.properties
mvn clean install -Pweb; mvn eclipse:clean eclipse:eclipse -Pweb
mvn clean install -Pscheduler; mvn eclipse:clean eclipse:eclipse -Pscheduler
docker build -t postgres:taskmanager -f dockerfiles/postgres/Dockerfile .
docker build -t endpoint:latest -f dockerfiles/endpoint/Dockerfile .
docker build -t scheduler:latest -f dockerfiles/scheduler/Dockerfile .
docker-compose -f docker-compose.yml up -d
