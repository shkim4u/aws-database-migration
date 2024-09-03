AWS DMS(AWS Database Migration Service)를 사용하여 Oracle에서 MySQL로 데이터베이스를 마이그레이션할 때, Oracle의 `IDENTITY` 컬럼(또는 자동 증가 기능)을 MySQL에서 올바르게 처리하려면 몇 가지 사항을 고려해야 합니다. Oracle의 `IDENTITY` 컬럼은 MySQL의 `AUTO_INCREMENT` 컬럼과 유사한 기능을 제공하지만, 두 시스템 간의 동작 방식과 사용법에 차이가 있습니다.

### Oracle의 IDENTITY 컬럼과 MySQL의 AUTO_INCREMENT

- **Oracle IDENTITY 컬럼**:
    - Oracle 12c 이상에서 도입된 `IDENTITY` 컬럼은 자동 증가 숫자를 생성하는 기능을 제공합니다. 이를 통해 자동으로 증가하는 숫자를 기본 키로 사용할 수 있습니다.
    - 이전 버전에서는 SEQUENCE와 트리거를 조합하여 비슷한 기능을 구현하였습니다.

- **MySQL AUTO_INCREMENT 컬럼**:
    - MySQL의 `AUTO_INCREMENT`는 기본 키 또는 고유 인덱스가 있는 컬럼에서 자동 증가 값을 생성하는 데 사용됩니다.
    - 테이블에서 하나의 `AUTO_INCREMENT` 컬럼만 있을 수 있습니다.

### AWS DMS를 이용한 마이그레이션에서의 IDENTITY 컬럼 처리

AWS DMS는 기본적으로 소스 데이터베이스의 `IDENTITY` 특성을 타겟 데이터베이스의 대응되는 특성으로 변환하려고 시도합니다. 하지만 정확한 변환을 위해서는 몇 가지 수동 설정이 필요할 수 있습니다.

#### 1. **AWS Schema Conversion Tool(AWS SCT) 사용**

AWS SCT는 스키마 변환을 자동으로 처리해주는 도구로, Oracle의 `IDENTITY` 컬럼을 MySQL의 `AUTO_INCREMENT` 컬럼으로 변환하는 데 사용할 수 있습니다. SCT는 Oracle 스키마를 MySQL 스키마로 변환하면서 `IDENTITY` 컬럼을 자동으로 MySQL의 `AUTO_INCREMENT`로 설정합니다.

1. **AWS SCT에서 Oracle 소스 스키마 분석**:
    - AWS SCT에서 Oracle 데이터베이스에 연결하여 스키마를 분석합니다.

2. **변환 규칙 설정**:
    - Oracle의 `IDENTITY` 컬럼이 포함된 테이블을 변환할 때, AWS SCT는 기본적으로 해당 컬럼을 MySQL의 `AUTO_INCREMENT`로 변환합니다. 필요한 경우 사용자 지정 변환 규칙을 추가할 수 있습니다.

3. **변환된 스키마 검토**:
    - 변환 후, 생성된 MySQL DDL 스크립트를 검토하여 `AUTO_INCREMENT`가 올바르게 설정되었는지 확인합니다.

4. **변환된 스키마 적용**:
    - 변환된 MySQL 스키마를 대상 MySQL 데이터베이스에 적용합니다.

#### 2. **AWS DMS 작업 설정**

AWS DMS 작업에서 테이블의 데이터와 구조를 복제할 때, `IDENTITY` 컬럼이 MySQL에서 자동으로 `AUTO_INCREMENT`로 매핑되도록 몇 가지 설정을 검토해야 합니다.

1. **테이블 매핑 규칙**:
    - DMS 작업을 생성할 때, 테이블 매핑 규칙을 설정하여 특정 테이블이나 컬럼에 대해 특별한 동작을 정의할 수 있습니다. IDENTITY 컬럼이 있는 테이블에 대해 별도의 매핑 규칙을 정의하여 해당 컬럼이 `AUTO_INCREMENT`로 설정되도록 할 수 있습니다.

2. **스키마 변환 전략**:
    - DMS는 데이터 전송 작업에서 스키마를 자동으로 변환할 수 있지만, 스키마 변환은 더 복잡한 경우 SCT를 통해 미리 처리하는 것이 좋습니다. DMS 작업에서는 주로 데이터 복제에 집중합니다.

#### 3. **수동으로 IDENTITY 컬럼 설정**

마이그레이션 후 MySQL에서 테이블 구조를 검토하고, IDENTITY 컬럼이 제대로 설정되지 않았거나 추가적인 조정이 필요한 경우, 수동으로 `AUTO_INCREMENT`를 설정할 수 있습니다.

```sql
ALTER TABLE table_name MODIFY id_column_name INT AUTO_INCREMENT;
```

```sql
ALTER TABLE hotelspecial MODIFY id int(11) unsigned NOT NULL AUTO_INCREMENT;
```

이 명령은 MySQL에서 해당 컬럼을 자동 증가 컬럼으로 변환합니다.

### 결론

Oracle의 IDENTITY 컬럼을 MySQL로 이전할 때는 다음과 같은 절차를 따르는 것이 일반적입니다:

1. **AWS SCT를 사용하여 스키마 변환 수행**: Oracle의 `IDENTITY` 컬럼을 MySQL의 `AUTO_INCREMENT`로 변환하는 스키마 변환 작업을 수행합니다.
2. **AWS DMS를 사용하여 데이터 복제 수행**: 변환된 스키마에 따라 데이터 복제 작업을 수행하여 데이터가 올바르게 마이그레이션되도록 합니다.
3. **결과 검토 및 수동 수정**: 마이그레이션 후 MySQL의 테이블 구조를 검토하고 필요에 따라 수동으로 `AUTO_INCREMENT`를 설정합니다.

이러한 절차를 통해 Oracle에서 MySQL로 데이터베이스를 마이그레이션할 때 IDENTITY 컬럼을 올바르게 처리할 수 있습니다.
