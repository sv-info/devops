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

mkdir -p LOG_FOLDER
echo "Script started executing at : $(date)"

if [ $USER_ID -eq 0 ]
then
echo -e " $G Running as root user $N"
else
echo -e "$R Permission denied.. $N"
exit 0
fi

echo "Enter password..."
read -s $RABBIT_PASSWORD

VALIDATE(){
	if [ $1 -eq 0 ] 
	then
	echo -e " $2 is .... $G SUCCESS $N "
	else
	echo -e " $2 is .... $R FAILED $N "
	exit 0
	fi
}

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$LOG_FILE
VALIDATE $? "Copying RabbitMQ repo..."

dnf install rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Install RabittMQ..."

systemctl enable rabbitmq-server


systemctl start rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Enabling and Starting RabbitMQ..."

rabbbitmqctl add_user roboshop $RABBIT_PASSWORD
rabbbitmqctl set_permission -p / roboshop ".*" ".*" ".*"

END=$(date +%s)

TIME= $(( $END - $START )) 
echo -e "Script executed in $TIME seconds..." 