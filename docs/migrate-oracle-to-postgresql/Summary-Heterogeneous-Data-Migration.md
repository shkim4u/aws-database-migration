# ***이기종 데이터 마이그레이션 요약***

첫 번째 부분에서는 ```AWS SCT (AWS Schema Conversion Tool)```를 사용하여 소스 데이터베이스의 데이터베이스 스키마를 ```Amazon Aurora (PostgreSQL)```로 비교적 쉽게 변환하는 작업을 수행해 보았습니다.

두 번째 부분에서는 ```AWS Database Migration Service (AWS DMS)```를 사용하여 소스에서 대상 데이터베이스로 데이터를 마이그레이션했습니다. 마찬가지로 DMS가 소스의 새 트랜잭션을 대상 데이터베이스에 자동으로 복제하는 방법을 관찰했습니다.

동일한 단계에 따라 SQL Server 및 Oracle 워크로드를 PostgreSQL 및 MySQL을 포함한 다른 RDS 엔진으로 마이그레이션할 수 있습니다.
