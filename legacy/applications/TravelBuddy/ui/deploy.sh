#!/bin/bash
npm install
npm run build
#cd build
aws s3 sync build s3://travelbuddy-frontend-537682470830
