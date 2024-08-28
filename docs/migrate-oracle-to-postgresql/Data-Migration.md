# ***파트 2: 데이터 마이그레이션***

이 부분을 진행하려면 [스키마변환](./Convert-Schema.md) 섹션에 설명된 단계를 완료해야 합니다.

이 섹션에서는 ```AWS Database Migration Service```를 사용하여 데이터를 ```Amazon Aurora (PostgreSQL)``` 인스턴스로 마이그레이션하는 방법을 보여줍니다. 또한 ```AWS DMS```를 사용하여 소스 데이터베이스에서 대상 데이터베이스로 데이터베이스 변경 사항을 지속적으로 복제합니다. 이 작업은 두 단계로 수행됩니다.

1. 먼저 ```AWS DMS```를 사용하여 대상 ```Aurora PostgreSQL``` 데이터베이스로 소스의 전체 로드 마이그레이션을 수행합니다.

2. 그런 다음 소스에서 데이터 변경 사항 (CDC)을 캡처하고 ```AWS DMS```를 사용하여 ```Aurora PostgreSQL``` 인스턴스에 자동으로 복제합니다.

AWS DMS는 대상 데이터베이스 테이블만을 구축합니다. 데이터 마이그레이션과 특별히 관련되지 않은 보조 인덱스, 시퀀스, 기본값, 저장 프로시저, 트리거, 동의어, 뷰 및 기타 스키마 개체는 마이그레이션하지 않습니다. 이러한 객체를 ```Aurora (PostgreSQL)``` 대상으로 마이그레이션하기 위해 이전 섹션에서 ```AWS Schema Conversion Tool```을 사용했습니다.

![Aurora PostgreSQL 데이터베이스로 마이그레이션](../../images/migrate-oracle-to-postgresql.png)

이 섹션에서는 다음 작업을 수행합니다:

- [타겟 데이터베이스 설정](./Configure-Target-Database.md)
- [DMS 복제 인스턴스 생성](./Create-DMS-Replication-Instance.md)
- [DMS 소스 및 타겟 엔드포인트 생성](./Create-DMS-Source-and-Target-Endpoints.md)
- [DMS 마이그레이션 태스크 생성](./Create-DMS-Migration-Tasks.md)
- [타겟 데이터베이스 데이터 검사](./Inspect-Target-Database-Content.md)
- [데이터 변경 복제](./Replicate-Data-Changes.md)

___
