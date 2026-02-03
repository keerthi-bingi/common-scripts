#!/bin/bash
APP_NAME="redis"

source ./common.sh

CHECK_ROOT_USER

dnf module disable redis -y &>>$LOGS_FILE
VALIDATE $? "Disabling Latest redis Server"

dnf module enable redis:7 -y &>>$LOGS_FILE
VALIDATE $? "Enabling redis 7"

dnf install redis -y &>>$LOGS_FILE
VALIDATE $? "Installing redis 7"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf
VALIDATE $? "Allowing remote connections"

sed -i 's/yes/no/g' /etc/redis/redis.conf
VALIDATE $? "Disabling protection Mode"

systemctl enable redis &>>$LOGS_FILE
VALIDATE $? "Enabling redis"

systemctl start redis &>>$LOGS_FILE
VALIDATE $? "Starting redis"

PRINT_TOTAL_TIME