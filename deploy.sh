#!/bin/bash

echo "****************** Checking PM2 Running Processes *****************"

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

echo "****************** Updating & Installing Dependencies *****************"
cd /home/${GITHUB_REF_NAME}/server
npm install

cd /home/${GITHUB_REF_NAME}/client
npm install
npm run build  # Build React frontend

echo "****************** Starting Applications with PM2 *****************"
npm install -g pm2  # Ensure pm2 is installed

# Start Express backend on dynamically assigned port
cd /home/${GITHUB_REF_NAME}/server
PORT=$EXPRESS_PORT pm2 start npm --name "backend-$EXPRESS_PORT" -- start

# Start React frontend with serve on dynamically assigned port
cd /home/${GITHUB_REF_NAME}/client
pm2 serve build/ $REACT_PORT --name "frontend-$REACT_PORT" --spa

# Save PM2 process list to restart on reboot
pm2 save
pm2 startup
