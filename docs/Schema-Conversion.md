# ***스키마 전환 (Schema Conversion)***

데이터베이스 스키마와 코드 개체를 변환하는 작업은 일반적으로 이기종 데이터베이스 마이그레이션에서 가장 시간이 많이 걸리는 작업입니다. 스키마를 적절하게 변환하면 마이그레이션의 주요 이정표를 달성할 수 있습니다. [[AWS 스키마 변환 도구 (SCT)]](https://docs.aws.amazon.com/SchemaConversionTool/latest/userguide/CHAP_Installing.html)는 로컬 컴퓨터나 Amazon에 설치할 수 있는 사용하기 쉬운 애플리케이션입니다. EC2 인스턴스. ReInvent 2022에서 AWS는 DMS 서비스의 변환 및 마이그레이션 (Convert and Migrate) 섹션에 콘솔 환경도 추가했습니다. SCT의 기능은 시간을 두고 콘솔 환경으로 전환할 예정입니다.

SCT 및 AWS 콘솔의 변환 및 마이그레이션은 소스 데이터베이스 스키마를 검사하고 뷰, 저장 프로시저 및 함수를 포함한 대부분의 데이터베이스 코드 개체를 새 대상 데이터베이스와 호환되는 형식으로 자동 변환하여 이기종 데이터베이스 마이그레이션을 단순화하는 데 도움이 됩니다. SCT가 자동으로 변환할 수 없는 모든 개체에는 수동으로 변환하는 데 사용할 수 있는 자세한 정보가 표시됩니다.

![[schema-conversion]](../images/intro01.png)
