# ***(타겟) 신규 데이터베이스 및 애플리케이션 인프라 구성***

---

## Agenda
1. ```Cloud9``` 통합 환경 (IDE) 생성 및 설정
2. 워크샵 소스 코드 (`aws-database-migration`) 다운로드
3. 데이터베이스 및 애플리케이션 인프라 구성

---

## 1. ```Cloud9``` 통합 환경 (IDE) 생성 및 설정


---

## 2. 워크샵 소스 코드 (`aws-database-migration`) 다운로드

이제부터 모든 작업은 `Cloud9` 상에서 이루어지며, 먼저 `aws-database-migration` (현재 워크샵) 소스를 아래와 같이 다운로드합니다.

```bash
cd ~/environment/
git clone https://github.com/shkim4u/aws-database-migration
cd aws-data-migration
```

해당 소스 코드에는 테라폼으로 작성된 IaC 코드도 포함되어 있으며 여기에는 ```Amazon EKS```, ```Amazon RDS```, ```Amazon MSK``` 등의 자원이 포함되어 있습니다.<br>
우선 이 테라폼 코드를 사용하여 자원을 배포하도록 합니다.


---

## 3. 데이터베이스 및 애플리케이션 인프라 구성


