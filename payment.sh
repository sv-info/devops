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
echo "Please enter root password to setup"
read -s MYSQL_ROOT_PASSWORD


VALIDATE(){
	if [ $1 -eq 0 ] 
	then
	echo -e " $2 is .... $G SUCCESS $N "
	else
	echo -e " $2 is .... $R FAILED $N "
	exit 0
	fi
}

dnf install python3 gcc python3-devel -y &>>$LOG_FILE
VALIDATE $? "Install Python3 packages"

id roboshop
if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating roboshop system user"
else
    echo -e "System user roboshop already created ... $Y SKIPPING $N"
fi

mkdir /app

curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip

cd /app
unzip /tmp/payment.zip

pip3 install -r requirements.txt &>>$LOG_FILE
VALIDATE $? "Installing dependencies"

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service &>>$LOG_FILE
VALIDATE $? "Creating service..."

systemctl daemon-reload
systemctl enable payment
systemctl start payment &>>$LOG_FILE
VALIDATE $? "Starting payment..."



