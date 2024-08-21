#!/bin/bash

# Check if the execution role exists.
# Troubleshooting Reference: https://stackoverflow.com/questions/66405794/not-authorized-to-perform-stsassumerolewithwebidentity-403
aws iam get-role --role-name $TRAVELBUDDY_POD_ROLE_NAME
if [ $? -eq 0 ]; then
  echo "TravelBuddy Pod role $TRAVELBUDDY_POD_ROLE_NAME exists. No need to create it."
else
  echo "TravelBuddy Pod role $TRAVELBUDDY_POD_ROLE_NAME does not exist. Now creating it."
  aws iam create-role --role-name $TRAVELBUDDY_POD_ROLE_NAME --assume-role-policy-document file://travelbuddy_pod_service_account_role_trust_policy.json
  aws iam put-role-policy --role-name $TRAVELBUDDY_POD_ROLE_NAME --policy-name TravelBuddyPodRolePermissionPolicy --policy-document file://travelbuddy_pod_role_policy.json
fi

