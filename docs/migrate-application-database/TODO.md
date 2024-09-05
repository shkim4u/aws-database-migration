* PostgreSQL to Oracle 역동기화 (동작함)

```json
{
  "rules": [
    {
      "rule-type": "transformation",
      "rule-id": "556134354",
      "rule-name": "556134354",
      "rule-target": "column",
      "object-locator": {
        "schema-name": "travelbuddy",
        "table-name": "flightspecial",
        "column-name": "expiry_date"
      },
      "rule-action": "rename",
      "value": "EXPIRYDATE",
      "old-value": null
    },
    {
      "rule-type": "transformation",
      "rule-id": "556002807",
      "rule-name": "556002807",
      "rule-target": "column",
      "object-locator": {
        "schema-name": "travelbuddy",
        "table-name": "flightspecial",
        "column-name": "detination_code"
      },
      "rule-action": "rename",
      "value": "DESTINATIONCODE",
      "old-value": null
    },
    {
      "rule-type": "transformation",
      "rule-id": "555920505",
      "rule-name": "555920505",
      "rule-target": "column",
      "object-locator": {
        "schema-name": "travelbuddy",
        "table-name": "flightspecial",
        "column-name": "origin_code"
      },
      "rule-action": "rename",
      "value": "ORIGINCODE",
      "old-value": null
    },
    {
      "rule-type": "transformation",
      "rule-id": "555867091",
      "rule-name": "555867091",
      "rule-target": "column",
      "object-locator": {
        "schema-name": "travelbuddy",
        "table-name": "flightspecial",
        "column-name": "%"
      },
      "rule-action": "convert-uppercase",
      "value": null,
      "old-value": null
    },
    {
      "rule-type": "transformation",
      "rule-id": "555830387",
      "rule-name": "555830387",
      "rule-target": "table",
      "object-locator": {
        "schema-name": "travelbuddy",
        "table-name": "flightspecial"
      },
      "rule-action": "convert-uppercase",
      "value": null,
      "old-value": null
    },
    {
      "rule-type": "transformation",
      "rule-id": "555805535",
      "rule-name": "555805535",
      "rule-target": "schema",
      "object-locator": {
        "schema-name": "travelbuddy"
      },
      "rule-action": "convert-uppercase",
      "value": null,
      "old-value": null
    },
    {
      "rule-type": "selection",
      "rule-id": "555776470",
      "rule-name": "555776470",
      "object-locator": {
        "schema-name": "travelbuddy",
        "table-name": "flightspecial"
      },
      "rule-action": "include",
      "filters": []
    }
  ]
}
```


(동작 안함)
```json
{
    "rules": [
        {
            "rule-type": "transformation",
            "rule-id": "524022257",
            "rule-name": "524022257",
            "rule-target": "column",
            "object-locator": {
                "schema-name": "travelbuddy",
                "table-name": "flightspecial",
                "column-name": "header"
            },
            "rule-action": "convert-uppercase",
            "value": null,
            "old-value": null
        },
        {
            "rule-type": "transformation",
            "rule-id": "524002394",
            "rule-name": "524002394",
            "rule-target": "column",
            "object-locator": {
                "schema-name": "travelbuddy",
                "table-name": "flightspecial",
                "column-name": "header"
            },
            "rule-action": "include-column",
            "value": null,
            "old-value": null
        },
        {
            "rule-type": "transformation",
            "rule-id": "523979103",
            "rule-name": "523979103",
            "rule-target": "column",
            "object-locator": {
                "schema-name": "travelbuddy",
                "table-name": "flightspecial",
                "column-name": "id"
            },
            "rule-action": "convert-uppercase",
            "value": null,
            "old-value": null
        },
        {
            "rule-type": "transformation",
            "rule-id": "523895997",
            "rule-name": "523895997",
            "rule-target": "column",
            "object-locator": {
                "schema-name": "travelbuddy",
                "table-name": "flightspecial",
                "column-name": "id"
            },
            "rule-action": "include-column",
            "value": null,
            "old-value": null
        },
        {
            "rule-type": "transformation",
            "rule-id": "523790536",
            "rule-name": "523790536",
            "rule-target": "table",
            "object-locator": {
                "schema-name": "travelbuddy",
                "table-name": "flightspecial"
            },
            "rule-action": "convert-uppercase",
            "value": null,
            "old-value": null
        },
        {
            "rule-type": "transformation",
            "rule-id": "523732844",
            "rule-name": "523732844",
            "rule-target": "schema",
            "object-locator": {
                "schema-name": "travelbuddy"
            },
            "rule-action": "convert-uppercase",
            "value": null,
            "old-value": null
        },
        {
            "rule-type": "selection",
            "rule-id": "523711142",
            "rule-name": "523711142",
            "object-locator": {
                "schema-name": "travelbuddy",
                "table-name": "flightspecial"
            },
            "rule-action": "include",
            "filters": []
        }
    ]
}
```

* 특정 태그를 가진 CloudFront의 배포 도메인 이름 확인
```bash
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output=text) && echo $AWS_ACCOUNT_ID

for distribution in $(aws cloudfront list-distributions --query "DistributionList.Items[].Id" --output text); do
tags=$(aws cloudfront list-tags-for-resource --resource arn:aws:cloudfront::${AWS_ACCOUNT_ID}:distribution/$distribution --query "Tags.Items[?Key=='Product'].Value" --output text)
if [ "$tags" == "TravelBuddy" ]; then
export FRONTEND_DOMAIN_NAME=`aws cloudfront list-distributions --query "DistributionList.Items[?Id=='$distribution'].DomainName" --output text`
fi
done

echo $FRONTEND_DOMAIN_NAME
```
