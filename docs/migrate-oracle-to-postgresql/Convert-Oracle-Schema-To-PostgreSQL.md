# ***파트 1: 스키마 변환***

이 섹션에서는 PostgreSQL이 아닌 소스를 Amazon Aurora(PostgreSQL) 데이터베이스로 변환하기 위해 ```AWS Schema Conversion Tool```을 사용하는 방법을 알아봅니다. 또한 ```AWS SCT```가 이기종 데이터베이스 간의 차이점을 파악하는 데 어떻게 도움이 되는지 관찰하게 됩니다. 그리고 모든 데이터베이스 개체를 성공적으로 마이그레이션하기 위해서 수정이 필요한 부분에 대한 팁을 제공합니다.


![[소스 데이터베이스를 Aurora PostgreSQL 데이터베이스로 전환]](../../images/migrate-oracle-to-postgresql.png)

다음 작업을 수행합니다:

- [AWS 스키마 변환 도구 (AWS Schema Conversion Tool) 설치](./Install-AWS-Schema-Conversion-Tool.md)
- [데이터베이스 마이그레이션 프로젝트 생성](./Create-Database-Migration-Project.md)
- [스키마 변화](./Convert-Schema.md)
