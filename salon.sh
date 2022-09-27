#!/bin/bash
# Salon appointment program

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  SERVICES_LIST=$($PSQL "select * from services;")
  echo "$SERVICES_LIST" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo -e "$SERVICE_ID) $SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # send to main menu
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    SERVICE_REQ_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED;")
    if [[ -z $SERVICE_REQ_NAME ]]
    then
      # send to main menu
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      SERVICE_MENU $SERVICE_ID_SELECTED $SERVICE_REQ_NAME
    fi
  fi
}

SERVICE_MENU() {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_ID=$($PSQL "SELECT customer_id from customers where phone='$CUSTOMER_PHONE';")
  if [[ -z $CUSTOMER_ID ]]
  then
    # get customer name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    # create customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) values('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
    # get customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id from customers where phone='$CUSTOMER_PHONE';")
  fi
  # get customer name
  CUSTOMER_NAME=$($PSQL "SELECT name from customers where customer_id='$CUSTOMER_ID';")
  # get service time
  echo -e "\nWhat time would you like your $2, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
  read SERVICE_TIME
  # set appointment
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) values($CUSTOMER_ID,$1,'$SERVICE_TIME');")
  # appointment info message
  echo -e "\nI have put you down for a $2 at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
}

MAIN_MENU
