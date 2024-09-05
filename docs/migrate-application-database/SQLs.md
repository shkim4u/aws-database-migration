* (미사용) Epoch 값이 입력될 때 이를 PostgreSQL의 timestamp 값으로 저장하는 트리거
```sql
-- 타겟 PostgreSQL에서 트리거 함수 정의
CREATE OR REPLACE FUNCTION convert_expirydate()
RETURNS TRIGGER AS $$
BEGIN
    NEW.expiry_date = TO_TIMESTAMP(NEW.expiry_date / 1000);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 트리거 설정: 타겟 테이블에 데이터 삽입 시 호출
CREATE TRIGGER convert_expirydate_trigger
BEFORE INSERT OR UPDATE ON travelbuddy.flightspecial
FOR EACH ROW
EXECUTE FUNCTION convert_expirydate();
```

* Epoch 값을 timestamp 및 timestamptz 형식으로 저장하는 쿼리
```sql
-- Oracle 소스의 밀리초 Epoch 값을 초단위 Epoch값으로 변환: No timezone
UPDATE travelbuddy.flightspecial
SET expiry_date = to_timestamp(expiry_date_num / 1000);

-- With timezone at Asia/Seoul - No effect
UPDATE travelbuddy.flightspecial
SET expiry_date = (to_timestamp(expiry_date_num / 1000) AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Seoul');

-- Effective!
UPDATE travelbuddy.flightspecial
SET expiry_date = (to_timestamp(expiry_date_num / 1000) AT TIME ZONE 'Asia/Seoul');
```

* PostgreSQL timestamp 컬럼을 timestamptz 형식으로 변환하는 쿼리
```sql
ALTER TABLE travelbuddy.flightspecial
ALTER COLUMN expiry_date
TYPE timestamptz
USING expiry_date AT TIME ZONE 'Asia/Seoul';
```