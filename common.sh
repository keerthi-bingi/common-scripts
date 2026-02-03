#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-script"
LOGS_FILE="/var/log/shell-script/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR="$PWD"
MONGODB_HOST="mongodb.bingi.online"
START_TIME="$(date +%s)"

mkdir -p $LOGS_FOLDER

echo "$(date "+%Y-%m-%d %H:%M:%S") | Script started executing at: $(date)" | tee -a $LOGS_FILE

CHECK_ROOT_USER(){
    if [ $USERID -ne 0 ]; then 
    echo -e "$R Please run this script with root user access $N" | tee -a $LOGS_FILE
    exit 1
fi
}

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

NODE_JS_SETUP(){
    dnf module disable nodejs -y &>>$LOGS_FILE
    VALIDATE $? "Disabling nodejs latest version"

    dnf module enable nodejs:20 -y &>>$LOGS_FILE
    VALIDATE $? "Enabling nodejs 20"

    dnf install nodejs -y &>>$LOGS_FILE
    VALIDATE $? "Installing nodejs 20"

    npm install  &>>$LOGS_FILE
    VALIDATE $? "Installing dependencies"
}

APP_SETUP(){
    id roboshop &>>$LOGS_FILE
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
        VALIDATE $? "Creating system user"
    else
        echo -e "Roboshop user already exist ... $Y SKIPPING $N"
    fi

    mkdir -p /app 
    VALIDATE $? "Creating app directory"

    curl -o /tmp/$APP_NAME.zip https://roboshop-artifacts.s3.amazonaws.com/$APP_NAME-v3.zip  &>>$LOGS_FILE
    VALIDATE $? "Downloading $APP_NAME code"

    cd /app
    VALIDATE $? "Moving to app directory"

    rm -rf /app/*
    VALIDATE $? "Removing existing code"

    unzip /tmp/$APP_NAME.zip &>>$LOGS_FILE
    VALIDATE $? "Uzip $APP_NAME code"
}

SYSTEMD_SETUP(){
    cp $SCRIPT_DIR/$APP_NAME.service /etc/systemd/system/$APP_NAME.service
    VALIDATE $? "Created systemctl service"

    systemctl daemon-reload
    systemctl enable $APP_NAME  &>>$LOGS_FILE
    systemctl start $APP_NAME
    VALIDATE $? "Starting and enabling $APP_NAME"
}

APP_RESTART(){
    systemctl restart $APP_NAME
    VALIDATE $? "Restarting $APP_NAME"
}

PRINT_TOTAL_TIME(){
    END_TIME=$(date +%s)
    TOTAL_TIME=$(( $END_TIME - $START_TIME ))
    echo -e "$(date "+%Y-%m-%d %H:%M:%S") | Script execute in: $G $TOTAL_TIME seconds $N" | tee -a $LOGS_FILE
}