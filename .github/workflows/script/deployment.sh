#!/bin/bash

echo "Deployment started..."

echo "****************** Checking PM2 Running Processes *****************"

# Check if a PM2 process for the current feature branch exists
BACKEND_PM2_ID=$(pm2 id "server-$ref_name")
FRONTEND_PM2_ID=$(pm2 id "client-$ref_name")

if [ -z "$BACKEND_PM2_ID" ]; then
    echo "No existing process found for this feature branch. Assigning new ports."

    # Count all PM2 processes (not just online ones)
    PROCESS_COUNT=$(pm2 list | grep -cE "(online|stopped|errored)")

    echo "Total PM2 processes (all states): $PROCESS_COUNT"

    # Ensure PROCESS_COUNT is a valid number
    if [ -z "$PROCESS_COUNT" ] || [ "$PROCESS_COUNT" -lt 0 ]; then
        PROCESS_COUNT=0
    fi

    # Prevent division issues by ensuring integer division
    if [ "$PROCESS_COUNT" -eq 0 ]; then
        REACT_PORT=3000
        EXPRESS_PORT=4000
    else
        REACT_PORT=$((3000 + PROCESS_COUNT / 2))
        EXPRESS_PORT=$((4000 + PROCESS_COUNT / 2))
    fi

    echo "Setting React to run on port $REACT_PORT"
    echo "Setting Express to run on port $EXPRESS_PORT"
else
    echo "Existing process found for feature branch. Reusing existing port and deleting the existing instances"

    # Retrieve existing PORT value from the existing PM2 process
    EXPRESS_PORT=$(pm2 env "$BACKEND_PM2_ID" | grep "PORT" | sed 's/.*PORT: \([0-9]*\).*/\1/')
    REACT_PORT=$(pm2 env "$FRONTEND_PM2_ID" | grep "PORT" | sed 's/.*PORT: \([0-9]*\).*/\1/')
    pm2 delete "server-$ref_name"
    pm2 delete "client-$ref_name"
    echo "Reusing existing Express PORT: $EXPRESS_PORT"
fi

echo "****************** Creating .env Files *****************"

# Create .env file for the server
echo "PORT=$EXPRESS_PORT" > /home/$ref_name/server/.env
echo "ALLOWED_ORIGINS=http://$secret_host:$REACT_PORT,http://165.232.190.41:$REACT_PORT" >> /home/$ref_name/server/.env

# Create .env file for the client
echo "REACT_APP_API_URL=http://$secret_host:$EXPRESS_PORT" > /home/$ref_name/client/.env

echo "****************** Updating & Installing Dependencies *****************"
cd /home/$ref_name/server
npm install
PORT=$EXPRESS_PORT pm2 start npm --name "server-$ref_name" -- start

cd /home/$ref_name/client
export NODE_OPTIONS="--max-old-space-size=1024"
npm cache clean --force
npm install
npm run build  # Build React frontend
pm2 serve build/ $REACT_PORT --name "client-$ref_name" --spa

echo "****************** Starting Applications with PM2 *****************"

pm2 save
pm2 startup