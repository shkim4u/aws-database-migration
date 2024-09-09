1. 프론트엔드 사용자 인터페이스 분리 (React.js 등), 백엔드 도메인 주소의 TTL 값을 미리 축소해 둠 -> ```HotelSpecials``` 데이터베이스 스키마 전환 -> 애플리케이션의 리플랫폼 (EC2 -> EKS)을 통한 ```HotelSpecials``` 백엔드 애플리케이션 마이그레이션 및 실행 -> ALB Request Routing 설정 -> [애플리케이션 트래픽 유입 중단] -> ```HotelSpecials``` 데이터 마이그레이션 -> 프론트엔드 To 백엔드 접속 DNS를 ALB로 변경 (최초 일회) -> [넓은 지역으로 DNS 전파가 확인되면 트래픽 유입 재개] -> ```HotelSpecials``` 데이터의 SSOT 클라우드 전환 완료, ```FlightSpecials``` 트래픽은 기존 온프레미스로 유입 -> ```FlightSpecials``` 데이터베이스 스키마 전환 -> [애플리케이션 트래피 유입 중단] -> ```FlightSpecials``` 서비스 마이그레이션 및 실행 -> ```FlightSpecials``` 데이터 마이그레이션 -> ALB 요청 라우팅 설정 -> [애플리케이션 트래픽 유입 재개] -> ```HotelSpecials``` 데이터 SSOT 클라우드 전환 완료 -> 데이터베이스 역동기화

* [(소스) 레거시 애플리케이션/데이터베이스 구성 및 실행](./Configure-and-Launch-Legacy-Application-and-Database.md)
* [(타겟) 신규 데이터베이스 및 애플리케이션 인프라 구성](./Configure-New-Database-and-Application-Infrastructure.md)
* [사용자 인터페이스 (프론트엔드) 분리](./Separate-Frontend.md)
* [```HotelSpecials``` 데이터베이스 스키마 전환](./Convert-HotelSpecials-Database-Schema.md)
* [```HotelSpecials``` 서비스 마이그레이션 및 구동](./Migrate-HotelSpecials-Service.md)
* [```Application Load Balancer (ALB)``` 요청 라우팅 설정](./Configure-ALB-Request-Routing.md)
* [애플리케이션 트래픽 유입 중단](./Stop-Application-Traffic-Inflow.md)
* [```HotelSpecials``` 데이터 마이그레이션](./Migrate-HotelSpecials-Data.md)
* [프론트엔드의 백엔드 접속 엔드포인트 (DNS)를 ALB로 변경](./Change-Frontend-Backend-ALB.md)
* [넓은 지역으로 DNS 전파 확인](./Check-DNS-Propagation.md)
* [프론트엔드로 트래픽 유입 재개](./Resume-Frontend-Traffic.md)
* [```HotelSpecials``` 데이터의 SSOT 클라우드 전환 완료 선언](./Declare-HotelSpecials-SSOT-Cloud-Transition-Complete.md)
* [```FlightSpecials``` 데이터베이스 스키마 전환](./Convert-FlightSpecials-Database-Schema.md)
* [애플리케이션 트래픽 유입 중단](./Stop-Application-Traffic-Inflow.md)
* [```FlightSpecials``` 서비스 마이그레이션](./Migrate-FlightSpecials-Service.md)
* [```FlightSpecials``` 데이터 마이그레이션](./Migrate-FlightSpecials-Data.md)
* [프론트엔드로 트래픽 유입 재개](./Resume-Frontend-Traffic.md)
* [```FlightSpecials``` 데이터의 SSOT 클라우드 전환 완료 선언](./Declare-FlightSpecials-SSOT-Cloud-Transition-Complete.md)
* [데이터베이스 역동기화](./Database-Reverse-Synchronization.md)