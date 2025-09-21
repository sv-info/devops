#!/bin/bash
START=$(date +%s)
USER_ID=$(id -u)
 R="\e[31m"
 G="\e[32m"
 Y="\e[33m"
 N="\e[0m"
LOG_FOLDER="/var/log/shell-log"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p $LOG_FOLDER
echo "Script started executing at : $(date)"

if [ $USER_ID -eq 0 ]
then
echo -e "$G Running as root user $N"
else
echo -e "$R Permission denied.. $N"
exit 0
fi

VALIDATE(){
	if [ $1 -eq 0 ] 
	then
	echo -e " $2 is .... $G SUCCESS $N "
	else
	echo -e " $2 is .... $R FAILED $N "
	exit 0
	fi
}

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling existing nodes"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabling nodejs:20 to install"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing nodejs..."

id roboshop
if [ $? -ne 0 ]
then 
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
VALIDATE $? "Creating user to run roboshop"
else
echo -e "System user roboshop already existed.....$Y SKIPPING $N"
fi

mkdir -p /app 
VALIDATE $? "Creating Dir..."

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
VALIDATE $? "Downloading Catalogue"

rm -rf /app/* &>>$LOG_FILE
cd /app 
unzip /tmp/catalogue.zip
VALIDATE $? "Downloaded and extracted..."

npm install  


cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service &>>$LOG_FILE
VALIDATE $? "Copying service properties...."

systemctl daemon-reload
systemctl enable catalogue 
systemctl start catalogue
VALIDATE $? "service started...."

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongodb.repo 
dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Installing MongoDB Client"

STATUS=$(mongosh --host mongodb.svdvps.online --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $STATUS -lt 0 ]
then
    mongosh --host mongodb.svdvps.online </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Loading data into MongoDB"
else
    echo -e "Data is already loaded ... $Y SKIPPING $N"
fi