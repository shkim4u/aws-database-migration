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

(TODO: 정렬됨)
```json
{
  "rules": [
     {
        "rule-type": "selection",
        "rule-id": "1",
        "rule-name": "SelectionRule",
        "object-locator": {
           "schema-name": "travelbuddy",
           "table-name": "flightspecial"
        },
        "rule-action": "include",
        "filters": []
     },
     {
        "rule-type": "transformation",
        "rule-id": "2",
        "rule-name": "UppercaseSchema",
        "rule-target": "schema",
        "object-locator": {
           "schema-name": "travelbuddy"
        },
        "rule-action": "convert-uppercase",
        "value": null,
        "old-value": null
     },
     {
        "rule-type": "transformation",
        "rule-id": "3",
        "rule-name": "UppercaseTable",
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
        "rule-id": "4",
        "rule-name": "UppercaseColumns",
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
        "rule-id": "5",
        "rule-name": "RenameOriginCode",
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
        "rule-id": "6",
        "rule-name": "RenameDestinationCode",
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
        "rule-id": "7",
        "rule-name": "RenameExpireDate",
        "rule-target": "column",
        "object-locator": {
           "schema-name": "travelbuddy",
           "table-name": "flightspecial",
           "column-name": "expiry_date"
        },
        "rule-action": "rename",
        "value": "EXPIRYDATE",
        "old-value": null
     }
  ]
}
```

(컬럼값 변환 실험 by ChatGPT)

Yes, in **AWS DMS** (Database Migration Service), you can apply a formula or transformation to a column from the source data and replicate the transformed value to the target database. This can be achieved using **transformation rules** within AWS DMS. Transformation rules allow you to modify the source data before it is applied to the target database.

### How to apply a formula or transformation to a column in AWS DMS:

1. **Transformation Rules**:
   AWS DMS provides the ability to apply transformation rules to columns. These rules allow you to manipulate the source data by renaming columns, modifying column values (e.g., applying calculations or formulas), and excluding columns from replication.

2. **Using Transformation Rules for Custom Calculations**:
    - You can create transformation rules that modify the column value using SQL expressions or logic. However, AWS DMS itself does not support custom SQL expressions natively. In this case, you might need to handle the transformation within the target database after the data is replicated, or use AWS Lambda functions as part of a more advanced pipeline to handle transformations.

    - Alternatively, **Post-Migration Transformation**: After the initial data replication (full load), you can perform transformations directly in the target database by running custom SQL queries or stored procedures.

### Example:

If you want to apply a formula such as multiplying a source column value by 10 before replicating it to the target database, you can use transformation rules like the following:

#### Example JSON Transformation Rule (within the DMS task JSON):
```json
{
  "rule-type": "transformation",
  "rule-id": "1",
  "rule-name": "multiply-source-column",
  "rule-target": "column",
  "object-locator": {
    "schema-name": "source_schema",
    "table-name": "source_table",
    "column-name": "source_column"
  },
  "rule-action": "convert-column",
  "expression": "%c * 10",
  "column-type": "number",
  "target-column-name": "target_column"
}
```

- **expression**: This is the mathematical transformation you want to apply. `%c` represents the column value.
- **rule-action**: The `convert-column` action allows modification of the column value before it is applied to the target.
- **target-column-name**: Specifies the name of the target column in which the transformed value will be stored.

### Conclusion:
AWS DMS can apply transformations to source data using **transformation rules**. You can perform basic transformations like mathematical operations, but more complex logic may require external handling, such as through Lambda or by applying the transformations directly in the target database after migration.


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

---

## 진정으로 무중단 데이터 마이그레이션을 어렵게 만드는 요인
1. 데이터의 크기
2. Entrenched Data & IT Culture
3. DNS Propagation
