#!/bin/bash
npm install
npm run build

export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output=text) && echo $AWS_ACCOUNT_ID

aws s3 sync build s3://travelbuddy-frontend-${AWS_ACCOUNT_ID}
