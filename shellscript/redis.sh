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

dnf module disable redis -y&>>$LOG_FILE
VALIDATE $? "Disabling Exusting redis..."

dnf module enable redis -y &>>$LOG_FILE
VALIDATE $? "Enabling Exusting redis..."

dnf install redis -y  &>>$LOG_FILE
VALIDATE $? "Installing redis..."

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf  &>>$LOG_FILE
VALIDATE $? "changing port ip"

systemctl  enable redis  &>>$LOG_FILE
systemctl  start redis
VALIDATE $? "Enabling and Starting..."
END=$(date +%s)

TIME= $(( $END - $START )) &>>$LOG_FILE
echo -e "Script executed in $TIME seconds" 