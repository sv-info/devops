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
echo -e " $G Running as root user $N"
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

cp mongo.repo  /etc/yum.repos.d/mongodb.repo &>>$LOG_FILE
VALIDATE $? "Copying MongoDB Repo..."

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "Install MongoDB..."

systemctl start mongod
systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "Starting and Enabling MongoDB..."

sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mongod.conf &>>$LOG_FILE
VALIDATE $? "Changing port ip..."

systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "Restarting MongoDB..."


