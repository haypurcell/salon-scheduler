#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~ The Salon ~~~\n"

#get service list
SERVICES=$($PSQL "select service_id, name from services order by service_id")

SERVICE_LIST() {
  #show services available
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do 
    echo "$SERVICE_ID) $NAME"
  done
}

echo -e "Welcome to the Salon, how may I help you?\n"
echo -e "Which service do you want?\n"

GET_SERVICE() {
  #ask which service
  SERVICE_LIST
  read SERVICE_ID_SELECTED

  #if input not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    #sent back to service list 
    echo -e "\nI could not find that service. What would you like today?"
    GET_SERVICE
  else
    GET_INFO
  fi
}

GET_INFO() {
  #get service_id
  SERVICE_ID=$($PSQL "select service_id from services where service_id=$SERVICE_ID_SELECTED")
  
  #if not valid input
  if [[ -z $SERVICE_ID ]]
  then
    #send to service list
    echo -e "\nI could not find that service. What would you like today?"
    GET_SERVICE
  else
    #ask for phone number
    echo -e "\nWhat is your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_ID=$($PSQL"select customer_id from customers where phone='$CUSTOMER_PHONE'")

    #if customer not in db
    if [[ -z $CUSTOMER_ID ]]
    then
      #get new customer name
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      #insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "insert into customers(name,phone) values('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
    fi

    #get customer_id service name
    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
    SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID")

    #ask for time
    echo -e "\nWhat time would you like your$SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME

    #insert appointment
    INSERT_APPOINTMENT_RESULT=$($PSQL "insert into appointments(customer_id,service_id,time) values($CUSTOMER_ID,$SERVICE_ID,'$SERVICE_TIME')")

    #exit
    echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}
GET_SERVICE
