# ***데이터베이스 역동기화 (Reverse Synchronization)***

---

## **Agenda**
1. 개요
2. 복제 인스턴스 확인
3. 소스 및 타겟 엔드포인스 생성
4. `DMS 마이그레이션 태스크` 생성

---

## **1. 개요**

우리는 이제까지 `TravelBuddy` 애플리케이션과 데이터베이스를 클라우드로 마이그레이션하는 과정을 살펴보았습니다.

하지만 `TravelBuddy` 애플리케이션의 모든 운영 인프라가 한번에 새로운 환경으로 옮겨오는 것은 매우 복잡하고 위험하며 많은 시간이 소요되는 작업이므로, 기존 운영 환경의 일부와 병행 운영하는 기간이 필요할 수 있습니다 (```Parallel Run```).

이러한 기존 운영 환경의 예로서는 다음과 같은 것들이 있습니다.
* `BI (Business Intelligence)` 시스템이 연전히 기존 데이터베이스를 참조
* 제3자 결제 관련 정산 (Settlement) 및 대사 (Reconciliation) 시스템
* SAP와 같은 ERP 시스템
* 기타 외부 시스템과의 연동

따라 실제 프로젝트에서는 이러한 작업을 주된 마일스톤 단위로 나누고 각 단계별로 안정성을 검증하며 진행합니다. 그리고 우리는 이러한 단계 중 많은 부분을 순서대로 접해 보았습니다.

이제 마지막 작업으로 위의 기존 운영 환경과의 병행 운영을 감안하여 (예: 기존 데이터베이스를 참조하는 `BI` 시스템) 신규 시스템에서의 데이터 변경 사항을 기존 운영 환경으로 역동기화하는 작업을 수행해 보겠습니다.

---

## **2. 복제 인스턴스 확인**

우리는 아래 그림과 같이 소스 데이터베이스 (`FlightSpecials` PostgreSQL)로부터 타겟 데이터베이스 (`TravelBuddy` Oracle)로 데이터를 복제할 예정입니다.

주목할 사항은 다음과 같습니다.
* 기존의 정방향 마이그레이션과 달리, 이번에는 이제까지 타겟으로 삼았던 데이터베이스의 변경된 데이터를 기존의 소스 데이터베이스로 역동기화하는 작업입니다. 즉, 방향이 반대가 되어 소스가 타겟이 되고 타겟이 소스로 되는 것입니다.
* `FlightSpecials` 서비스 데이터의 `SSoT`는 신규 클라우드 환경으로 옮겨 왔으므로 새로운 데이터는 이제 클라우드의 `PostgreSQL` 데이터베이스에 저장됩니다. 이러한 새로운 데이터만을 기존 `Oracle` 데이터베이스로 역동기화할 것이므로 <u>***변경분만 복제***</u>하도록 합니다.

환경 설정과정에서 생성되었던 ```DMS 복제 인스턴스 (Replication Instance)```를 그대로 사용하도록 하겠습니다.

![DMS 복제 인스턴스](../../images/dms-replication-instance-no-tx-processing.png)

1. ```DMS > 데이터 마이그레이션 > 복제 인스턴스```로 이동합니다.

2. 이미 환경 설정 과정에서 생성된 복제 인스턴스 (```dmsworkshop-target-dmsrepl```)가 존재할 것입니다. 이번에는 이 복제 인스턴스를 사용합니다.

   ![DMS 복제 인스턴스 확인](../../images/dms-replication-instance-oracle-to-mysql-there.png)

---

## **3. 소스 및 타겟 엔드포인스 생성**

### **3.1. 소스 엔드프인트 생성**

1. ```DMS > 데이터 마이그레이션 > 엔드포인트```로 이동한  후 오른쪽 상단의 ```엔드포인트 생성```을 클릭합니다.

   ![DMS 엔드포인트 화면](../../images/reverse-synchronization/reverse-sync-dms-endpoint-create.png)

2. ```소스 엔드포인트```를 선택한 후 다음 정보를 입력한 후 ```연결 테스트```을 클릭합니다. 상태가 **성공**으로 바뀌면 **엔드포인트 생성**을 클릭합니다.

   | **파라미터**                    | **값**                                           |
            |-----------------------------|-------------------------------------------------|
   | **엔드포인트 유형**                | ```소스 엔드포인트```                                  |
   | **RDS DB 인스턴스 선택**          | ```체크```                                        |
   | **RDS DB 인스턴스**             | ```flightspecials-test-postgres-db```           |
   | **엔드포인트 식별자**               | ```flightspecials-postgresql-rsync-source```    |
   | **대상 엔진**                   | ```PostgreSQL```                                |
   | **엔드포인트 데이터베이스 액세스**        | ```수동으로 액세스 정보 제공```                            |
   | **서버 이름**                   | ```(자동으로 설정)```                                 |
   | **포트**                      | ```5432```                                      |
   | **사용자 이름**                  | ```dmsuser```                                   |
   | **비밀번호**                    | ```dmsuser123```                                |
   | **SSL 모드**                  | ```없음```                                        | 
   | **데이터베이스 이름**               | ```dso```                                       | 
   | **엔드포인트 연결 테스트 -> VPC**     | ```이름에 DmsVpc가 포함된 VPC ID```                    |
   | **엔드포인트 연결 테스트 -> 복제 인스턴스** | ```dmsworkshop-target-dmsrepl```                |

   ![```FlightSpecials``` PostgreSQL 소스 엔드포인트 1](../../images/reverse-synchronization/flightspecials-postgresql-source-rsync-1.png)

   ![```FlightSpecials``` PostgreSQL 소스 엔드포인트 2](../../images/reverse-synchronization/flightspecials-postgresql-source-rsync-2.png)

   ![```FlightSpecials``` PostgreSQL 소스 엔드포인트 3](../../images/reverse-synchronization/flightspecials-postgresql-source-rsync-3.png)

   ![```FlightSpecials``` PostgreSQL 소스 엔드포인트 4](../../images/reverse-synchronization/flightspecials-postgresql-source-rsync-4.png)

   > 📌 **참고**<br>
   > * 사실 우리는 앞선 과정에서 이미 동일한 `PostgreSQL` 데이터베이스에 대한 엔드포인트를 생성하였습니다. `AWS DMS 마이그레이션 태스크`는 동일한 엔드포인트 설정이라면 소스와 타겟에 관계없이 엔드포인트를 재사용할 수 있으므로 엔드포인트를 새로 생성하지 않고 이전에 생성한 엔드포인트를 그대로 사용할 수 있습니다.
   > * 하지만 소스와 타겟에 따라 `Read-only` 속성이나 `Extra Connection Attributes (ECA)` 등이 다를 수 있으므로, 그 때는 새로운 엔드포인트를 생성하여 사용하는 것이 좋습니다.
   > * 대표적인 예가 앞서 수행했던 `PostgreSQL` 타겟 엔드포인트에서 추가 연결 속성을 지정했던 부분입니다 (`truncateTrailingZerosForPlainNumeric=true`). 

### **3.2. 타겟 엔드포인트 생성**

1. ```DMS > 데이터 마이그레이션 > 엔드포인트```로 이동한  후 오른쪽 상단의 ```엔드포인트 생성```을 클릭합니다.

   ![DMS 엔드포인트 화면](../../images/dms-endpoint-create.png)

2. 다음 값들을 사용하여 소스 ```TravelBuddy``` 데이터베이스에 대한 엔드포인트를 생성합니다.

3. ```소스 엔드포인트```를 선택한 후 다음 정보를 입력한 후 ```연결 테스트```을 클릭합니다. 상태가 **성공**으로 바뀌면 **엔드포인트 생성**을 클릭합니다.

   | **파라미터**                | **값**                                                     |
            |-------------------------|-----------------------------------------------------------|
   | **엔드포인트 유형**            | ```타겟 엔드포인트```                                            |
   | **RDS DB 인스턴스 선택**      | ```체크 해제 (선택하지 않음)```                                     |
   | **엔드포인트 식별자**           | ```travelbuddy-oracle-target```                           |
   | **소스 엔진**               | ```Oracle```                                              |
   | **엔드포인트 데이터베이스 액세스**    | ```수동으로 액세스 정보 제공```                                      |
   | **서버 이름**               | ```(소스 측 담당자분 확인) 소스 측에서 생성된 오라클 데이터베이스 주소 (애플리케이션 서버)``` |
   | **포트**                  | ```1521```                                                |
   | **SSL 모드**              | ```없음```                                                  |
   | **사용자 이름**              | ```dmsuser```                                             |
   | **비밀번호**                | ```dmsuser123```                                          |
   | **SID/Service Name**    | ```XE```                                                  |   
   | **엔드포인트 연결 테스트 -> VPC** | ```이름에 DmsVpc가 포함된 VPC ID```                              |
   | **엔드포인트 연결 테스트 -> 복제 인스턴스**             | ```dmsworkshop-target-dmsrepl```                          |

   ![```TravelBuddy``` 오라클 타겟 엔드포인트 1](../../images/reverse-synchronization/travelbuddy-oracle-target-endpoint1.png)

   ![```TravelBuddy``` 오라클 타겟 엔드포인트 2](../../images/reverse-synchronization/travelbuddy-oracle-target-endpoint2.png)

   ![```TravelBuddy``` 오라클 타겟 엔드포인트 3](../../images/reverse-synchronization/travelbuddy-oracle-target-endpoint3.png)

   ![```TravelBuddy``` 오라클 타겟 엔드포인트 4](../../images/reverse-synchronization/travelbuddy-oracle-target-endpoint4.png)

---

## **4. ```DMS 마이그레이션 태스크``` 생성**

1. ```DMS > 데이터 마이그레이션 > 데이터베이스 마이그레이션 태스크```로 이동한 다음 오른쪽 상단에서 ```태스크 생성``` 버튼을 클릭합니다.

   ![FlightSpecials DMS 마이그레이션 역동기화 태스크 생성](../../images/flightspecials-postgresql-target/create-dms-migration-task.png)

2. ```TRAVELBUDDY``` 스키마의 마이그레이션을 위해 다음 값을 사용하여 ```데이터베이스 마이그레이션 태스크```를 생성합니다. (아래 적히지 않은 값들은 기본값을 사용합니다)

   | **파라미터**                         | **값**                                                     |
         |----------------------------------|-----------------------------------------------------------|
   | **태스크 식별자**                      | ```flightspecials-postgresql-to-oracle-rsync-task```      |
   | **친숙한 Amazon 리소스 이름(ARN)**       | ```비워둠```                                                 |
   | **복제 인스턴스**                      | ```dmsworkshop-target-dmsrepl``` (혹은 별도로 생성한 복제 인스턴스의 이름) |
   | **소스 데이터베이스 엔드포인트**              | ```flightspecials-postgresql-rsync-source```              |
   | **대상 데이터베이스 엔드포인트**              | ```travelbuddy-oracle-target```                           |
   | **마이그레이션 유형**                    | ```데이터 변경 사항만 복제```                                       |
   | **대상 테이블 준비 모드**                 | ```아무 작업 안 함``` (기본값 아님)                                  |
   | **LOB 컬럼 설정**                    | ```제한된 LOB 모드```                                          |
   | **최대 LOB 크기(KB)**                | ```32```                                                  |
   | **데이터 검증**                       | ```끄기```                                                  |
   | **태스크 로그 / CloudWatch 로그 켜기**    | ```CloudWatch 로그 켜기 체크``` (기본값 아님)                        |
   | **로그 컨텍스트**                      | ```체크된 상태로 로깅의 기본 수준 사용```                                |

3. ```테이블 매핑``` 섹션을 확장하고 편집 모드로 ```JSON 편집기```를 선택하고 아래 JSON 텍스트를 붙여넣습니다. 종종 많은 변환 규칙을 정의할 때는 ```JSON``` 형태로 정의된 템플릿을 사용하는 것이 편리하게 작업할 수 있으며, ```DMS```가 데이터를 변환하는 방법을 세밀하게 제어할 수 있습니다.

   > 📌 **참고 1**<br>
   > * ```AWS DMS```는 스키마, 테이블, 컬럼과 같은 객체의 메타 정보의 변경과 함께 데이터 타입의 변환을 지원합니다 (예: 컬럼의 이름 변경, ```NUMBER``` -> ```BIGINT``` 타입으로 컬럼 데이터 타입 변경).
   > * 하지만 이런 메타 정보의 변경과 동시에 데이터 자체를 정교하게 변경하는 작업은 지원하지 않습니다. 이런 경우에는 ```DMS```를 통해 데이터를 마이그레이션하면서 임시 컬럼에 소스 데이터를 적재한 후, 데이터를 정제하는 작업을 수행할 수 있습니다.
   > * 우리는 여기서 이러한 작업을 수행해 보고자 합니다.
       >   1. ```Oracle 11gR2```에서 ```Sequence``` 및 ```Trigger```로 구현되었던 ```Identity``` 컬럼을 ```GENERATED BY DEFAULT AS IDENTITY```로 변경
   >   2. 그리고 이 과정에서 컬럼의 데이터 타입을 ```NUMBER```에서 ```BIGINT```로 변경
   >   3. ```Epoch``` 타임스탬프 데이터를 담고 있던 ```EXPIRYDATE``` 컬럼을 ```NUMERIC``` 타입에서 ```TIMESTAMP``` 타입으로 변경
   >   4. 그리고 컬럼의 이름을 변경: 대문자를 소문자 Snake Case로 변경 (예: ```EXPIRYDATE``` -> ```expiry_case```)
   > * 참조
       >   1. [[변환 규칙 표현식을 사용하여 열 내용 정의]](https://docs.aws.amazon.com/ko_kr/dms/latest/userguide/CHAP_Tasks.CustomizingTasks.TableMapping.SelectionTransformation.Expressions.html)
   >   2. [[Convert the NUMBER data type from Oracle to PostgreSQL – Part 2
          ]](https://aws.amazon.com/blogs/database/convert-the-number-data-type-from-oracle-to-postgresql-part-2/)

   ```json
   {
      "rules": [
         {
            "rule-type": "selection",
            "rule-id": "1",
            "rule-name": "SelectFlightspecial",
            "object-locator": {
               "schema-name": "TRAVELBUDDY",
               "table-name": "FLIGHTSPECIAL"
            },
            "rule-action": "include",
            "filters": []
         },
         {
            "rule-type": "transformation",
            "rule-id": "2",
            "rule-name": "SchemaLower",
            "rule-action": "convert-lowercase",
            "rule-target": "schema",
            "object-locator": {
               "schema-name": "TRAVELBUDDY"
            }
         },
         {
            "rule-type": "transformation",
            "rule-id": "3",
            "rule-name": "TableLower",
            "rule-action": "convert-lowercase",
            "rule-target": "table",
            "object-locator": {
               "schema-name": "TRAVELBUDDY",
               "table-name": "FLIGHTSPECIAL"
            }
         },
         {
            "rule-type": "transformation",
            "rule-id": "4",
            "rule-name": "IdLower",
            "rule-action": "convert-lowercase",
            "rule-target": "column",
            "object-locator": {
               "schema-name": "TRAVELBUDDY",
               "table-name": "FLIGHTSPECIAL",
               "column-name": "ID"
            }
         },
         {
            "rule-type": "transformation",
            "rule-id": "5",
            "rule-name": "IdChangeDataType",
            "rule-target": "column",
            "object-locator": {
               "schema-name": "TRAVELBUDDY",
               "table-name": "FLIGHTSPECIAL",
               "column-name": "ID"
            },
            "rule-action": "change-data-type",
            "data-type": {
               "type": "int8"
            },
            "expression": "CAST(ID AS bigint)"
         },
         {
            "rule-type": "transformation",
            "rule-id": "6",
            "rule-name": "HeaderLower",
            "rule-action": "convert-lowercase",
            "rule-target": "column",
            "object-locator": {
               "schema-name": "TRAVELBUDDY",
               "table-name": "FLIGHTSPECIAL",
               "column-name": "HEADER"
            }
         },
         {
            "rule-type": "transformation",
            "rule-id": "7",
            "rule-name": "BodyLower",
            "rule-action": "convert-lowercase",
            "rule-target": "column",
            "object-locator": {
               "schema-name": "TRAVELBUDDY",
               "table-name": "FLIGHTSPECIAL",
               "column-name": "BODY"
            }
         },
         {
            "rule-type": "transformation",
            "rule-id": "8",
            "rule-name": "OriginLower",
            "rule-action": "convert-lowercase",
            "rule-target": "column",
            "object-locator": {
               "schema-name": "TRAVELBUDDY",
               "table-name": "FLIGHTSPECIAL",
               "column-name": "ORIGIN"
            }
         },
         {
            "rule-type": "transformation",
            "rule-id": "9",
            "rule-name": "OriginCodeRename",
            "rule-action": "rename",
            "rule-target": "column",
            "object-locator": {
               "schema-name": "TRAVELBUDDY",
               "table-name": "FLIGHTSPECIAL",
               "column-name": "ORIGINCODE"
            },
            "value": "origin_code"
         },
         {
            "rule-type": "transformation",
            "rule-id": "10",
            "rule-name": "DestinationLower",
            "rule-action": "convert-lowercase",
            "rule-target": "column",
            "object-locator": {
               "schema-name": "TRAVELBUDDY",
               "table-name": "FLIGHTSPECIAL",
               "column-name": "DESTINATION"
            }
         },
         {
            "rule-type": "transformation",
            "rule-id": "11",
            "rule-name": "DestinationCodeRename",
            "rule-action": "rename",
            "rule-target": "column",
            "object-locator": {
               "schema-name": "TRAVELBUDDY",
               "table-name": "FLIGHTSPECIAL",
               "column-name": "DESTINATIONCODE"
            },
            "value": "destination_code"
         },
         {
            "rule-type": "transformation",
            "rule-id": "12",
            "rule-name": "CostLower",
            "rule-action": "convert-lowercase",
            "rule-target": "column",
            "object-locator": {
               "schema-name": "TRAVELBUDDY",
               "table-name": "FLIGHTSPECIAL",
               "column-name": "COST"
            }
         },
         {
            "rule-type": "transformation",
            "rule-id": "13",
            "rule-name": "ExpiryDateRename",
            "rule-action": "remove-column",
            "rule-target": "column",
            "object-locator": {
               "schema-name": "TRAVELBUDDY",
               "table-name": "FLIGHTSPECIAL",
               "column-name": "EXPIRYDATE"
            }
         },
         {
            "rule-type": "transformation",
            "rule-id": "14",
            "rule-name": "458497515",
            "rule-target": "column",
            "object-locator": {
               "schema-name": "TRAVELBUDDY",
               "table-name": "FLIGHTSPECIAL"
            },
            "rule-action": "add-column",
            "value": "expiry_date_num",
            "old-value": null,
            "data-type": {
               "type": "numeric",
               "precision": "38",
               "scale": "10"
            },
            "expression": "$EXPIRYDATE"
         }
      ]
   }
   ```

   > 📌 **참고 2**<br>
   > Oracle, MySQL, PostgreSQL은 객체 이름에 대소문자를 다루는 방식이 조금씩 다릅니다. 이에 대한 내용은 아래 보충 문서를 참고하세요.<br>
   > [Oracle, MySQL, PostgreSQL의 대소문자 구분](https://docs.aws.amazon.com/ko_kr/dms/latest/userguide/CHAP_Source.Oracle.html#CHAP_Source.Oracle.CaseSensitivity)
   > [TODO: 보충 설명](./Case-Sensitivity-for-Oracle-PostgreSQL-MySQL.md)


4. ```태스크 생성```을 클릭합니다.

   * ⚠️ 시간 여유가 있다면 이번에는 진행자의 안내를 받아 (S3 및 IAM Role 설정) ```마이그레이션 전 평가 켜기```는 활성화하여 어떤 평가 보고서가 생성되는지 살펴보는 것도 좋습니다.

   * ```마이그레이션 태스크 시작 구성``` 아래 ```생성 시 자동으로 시작```이 선택되어 있는지 확인한 다음 ```태스크 생성```을 클릭합니다.

   * 설정된 화면은 아래와 유사합니다.

   ![FlightSpecials DMS 마이그레이션 태스크 생성 화면 1](../../images/flightspecials-postgresql-target/creat-hotelspecials-dms-migration-task-parameters-1-new.png)

   ![FlightSpecials DMS 마이그레이션 태스크 생성 화면 2](../../images/flightspecials-postgresql-target/creat-hotelspecials-dms-migration-task-parameters-2-new.png)

   ![FlightSpecials DMS 마이그레이션 태스크 생성 화면 3](../../images/flightspecials-postgresql-target/creat-hotelspecials-dms-migration-task-parameters-3-new.png)

   ![FlightSpecials DMS 마이그레이션 태스크 생성 화면 4](../../images/flightspecials-postgresql-target/creat-hotelspecials-dms-migration-task-parameters-4-new.png)


5. ```마이그레이션 태스크``` 실행이 시작되고 소스의 ```TRAVELBUDDY``` 스키마의 데이터가 ```Amazon RDS PostgreSQL``` 인스턴스로 복제되기 시작합니다. 데이터의 복제가 완료되면 아래와 같이 표시됩니다.

   ![FlightSpecials DMS 마이그레이션 태스크 생성료](../../images/flightspecials-postgresql-target/flightspecials-dms-migration-task-created.png)

   ![FlightSpecials DMS 마이그레이션 태스크 실행 완료](../../images/flightspecials-postgresql-target/flightspecials-dms-migration-task-completed.png)

6. ```마이그레이션 태스크 (source-to-aupg-migration-task)```를 클릭하고 ```테이블 통계``` 탭으로 이동하여 테이블 통계를 보고 이동된 행 수를 확인합니다.

   ![FlightSpecials DMS 마이그레이션 태스크 테이블 통계](../../images/flightspecials-postgresql-target/flightspecials-dms-migration-task-table-stats.png)

7. 오류가 발생하면 상태 색상이 녹색에서 빨간색으로 변경됩니다. 디버그할 로그에 대해 로그 보기 링크를 클릭합니다.


8. ```윈도우 인스턴스 (DMSWorkshop-Target-EC2Instance)```의 ```Fleet Manager``` RDP 세션으로 돌아와 ```pgAdmin4``` 화면에서 ```dso``` 데이터베이스를 선택하고 ```travelbuddy``` 스키마의 ```flightspecial``` 테이블을 선택하여 데이터가 정상적으로 마이그레이션되었는지 확인합니다.

   ![FlightSpecials DMS 마이그레이션 데이터 확인 1](../../images/flightspecials-postgresql-target/flightspecials-dms-migration-data-check1.png)

   ![FlightSpecials DMS 마이그레이션 데이터 확인 2](../../images/flightspecials-postgresql-target/flightspecials-dms-migration-data-check2.png)

   * 특히 ```id``` 컬럼이 ```Identity``` 값으로 채워졌는지, ```expiry_date```는 ```null```인지, ```expiry_date_num``` 컬럼이 ```NUMERIC``` 타입으로 채워졌는지 확인합니다.

   ![FlightSpecials DMS 마이그레이션 데이터 확인 3](../../images/flightspecials-postgresql-target/flightspecials-dms-migration-data-check3.png)

9. ```expiry_dae_num``` 컬럼의 ```Epoch``` 값으로부터 ```expiry_date``` (```Timestamp``` 타입) 컬럼을 유도하여 채워넣으면 전체 마이그레이션은 완료됩니다.

   ```sql
   -- Oracle 소스의 밀리초 Epoch 값을 초단위 Epoch값으로 변환
   UPDATE travelbuddy.flightspecial
   SET expiry_date = (to_timestamp(expiry_date_num / 1000) AT TIME ZONE 'Asia/Seoul');
   ```

   ![FlightSpecials DMS 마이그레이션 Expiry Datetime 설정](../../images/flightspecials-postgresql-target/flightspecials-dms-migration-set-expiry-datetime.png)

   ![FlightSpecials DMS 마이그레이션 Expiry Datetime 설정 결과](../../images/flightspecials-postgresql-target/flightspecials-dms-migration-set-expiry-datetime-result.png)

10. 이제 ```FlightSpecials``` 서비스의 데이터 마이그레이션이 완료되었습니다. 프론트엔드에 브라우저로 접속하여 데이터가 정상적으로 조회되는지 확인합니다.

![FlightSpecials DMS 마이그레이션 프론트엔드 확인](../../images/flightspecials-postgresql-target/flightspecials-dms-migration-data-check-frontend.png)

[//]: # (   > **잠깐!**<br>)

[//]: # (   > * 동작 환경에 따라 조금씩 다를 수 있지만 위의 프론트엔드 화면에서 조금 이상한 점을 눈치채지 못하셨나요? 이는 ```PostgreSQL```이 지원하는 ```timestamp``` 데이터 타입에서 기인하는데 결론적으로 말씀드리면, 위에서 ```expiry_date``` 컬럼에 값을 채워 넣을 때 Timezone Offset을 고려하거나, ```timestamptz``` 데이터 타입을 사용하면 됩니다.)

[//]: # (   > * 이 부분에 대해 관심이 있으시면 각자 개인적으로 살펴보시면 좋을 것 같습니다.)

---

## 🎉🎉🎉 축하합니다! 🎉🎉🎉

### - ```FlightSpecials``` 서비스의 데이터 마이그레이션이 성공적으로 완료되었고, 프론트엔드를 통해서도 성공적으로 서비스되고 있음을 확인하였습니다.

### - 이로서 앞서 진행한 ```HotelSpecials``` 서비스의 데이터 마이그레이션과 함께 ```TravelBuddy``` 애플리케이션의 모든 데이터베이스와 서비스의 마이그레이션이 성공적으로 완료되었습니다.

### - 이제 모든 데이터의 ```SSoT```가 신규 클라우드 환경에 있음을 선언하고 전체 서비스 트래픽을 신규 환경으로 재개하면 됩니다.



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
