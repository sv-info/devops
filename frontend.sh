#!/bin/bash
START=$(date +%s)
USER_ID=$(id -u)
 R="\e[31m"
 G="\e[32m"
 Y="\e[33m"
 N="\e[0m"
LOG_FOLDER="/var/logs/shell-log"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE=$LOG_FOLDER/$SCRIPT_NAME.log
SCRIPT_DIR=$PWD

mkdir -p LOG_FOLDER
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

dnf module disable nginx -y &>>LOG_FILE
VALIDATE $? "Disabling nginx..."

dnf module enable nginx:1.24 -y &>>LOG_FILE
VALIDATE $? "Enabling nginx..."

dnf install nginx -y &>>LOG_FILE
VALIDATE $? "Install Nodejs..."

systemctl enable nginx
systemctl start nginx &>>LOG_FILE
VALIDATE $? "Enabling and Starting ..."

rm -rf /usr/share/nginx/html/* &>>LOG_FILE
VALIDATE $? "Removing existing contnet..."

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>LOG_FILE
VALIDATE $? "Downloading code..."

rm -rf /etc/nginx/nginx.conf

cp nginx.conf /etc/nginx/nginx.conf &>>LOG_FILE
VALIDATE $? "Copying nginx.conf..."


systemctl restart nginx &>>LOG_FILE
VALIDATE $? "Restarting nginx..."

END=$(date +%s)

TIME= $(( $END - $START )) 
echo -e "Script executed in $TIME seconds..." 