#!/bin/bash

source ./common.sh

CHECK_ROOT_USER

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying Mongo Repo" 

dnf install mongodb-org -y &>>$LOGS_FILE
VALIDATE $? "Installing MongoDB Server"

systemctl enable mongod &>>$LOGS_FILE
VALIDATE $? "Enabling MongoDB Server"

systemctl start mongod &>>$LOGS_FILE
VALIDATE $? "Starting MongoDB Server"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing remote connections"

systemctl restart mongod &>>$LOGS_FILE
VALIDATE $? "Restarting MongoDB Server"

PRINT_TOTAL_TIME