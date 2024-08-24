# ***환경 설정***

자신의 AWS 계정을 사용하고 있거나 AWS 진행자로부터 별도의 워크숍 환경을 부여받은 경우 워크샵을 수행하는 데 사용할 일부 리소스를 AWS에 설정해야 합니다. 이 섹션에서는 이 데이터베이스 마이그레이션 체험에 필요한 AWS 리소스를 프로비저닝하는 단계를 설명합니다.

우리는 여기서  ```AWS CloudFormation``` 사용하여 인프라 프로비저닝을 단순화하므로 데이터 마이그레이션과 관련된 작업에 집중할 수 있습니다.

또한 소스와 타겟을 완전히 분리된 환경에서 (AWS 어카운트) 구성한 후 소스 데이터베이스를 타겟 환경으로 마이그레이션하는 것을 체험해 봄으로써 현실성을 높이고자 합니다. 이는 온프레미스 혹은 다른 클라우드 CSP로부터 AWS 클라우드로의 이관을 직접 다루어야 하는 싦무 마이그레이션 프로젝트에서 유용한 경험이 될 것입니다.

> ⚠️ 2인 1조 진행<br>
> - 위에서 말씀드린 대로 실제 마이그레이션 사례와 유사한 경험을 위하여 소스 데이터베이스를 위한 환경과 타겟 데이터베이스를 위한 환경을 분리하여 구성합니다. 이를 위해 2인 1조로 진행하며, 각 팀원은 각 환경을 구성하고 마이그레이션을 수행합니다.
> - 소스 환경은 온프레미스 혹은 타 클라우드 프라바이더 환경을 시뮬레이션합니다.
> - 타겟 환경은 ```AWS RDS``` 데이터베이스를 호스팅하는 AWS 클라우드입니다.
> - 소스 환경과 타겟 환경의 연결은 개방형 표준인 IPSEC 기반 VPN을 사용하여 구성함으로써 실제 현장에서 구성되는 기반 구조 위에서 데이터베이스 마이그레이션을 체험해 봅니다.

```CloudForamtion 템플릿```을 사용하여 다음과 같은 자원이 구성될 것입니다.

1. 소스 환경
   - Amazon Elastic Compute Cloud (EC2) 인스턴스 (윈도우)
     - 마이그레이션에 사용하는 데이터베이스 도구 및 AWS SCT (AWS Schema Conversion Tool) 포함 
   - (옵션) Microsoft SQL Server 마이그레이션 워크숍에서는 이 EC2 인스턴스를 사용하여 소스 데이터베이스
     - 소스 데이터베이스를 시뮬레이션하기 위해 사용하는 오라클 데이터베이스 인스턴스 (```Amazon RDS```)
     - 예제 애플리케이션을 호스팅하기 위한 애플리케이션 서버 (리눅스)
     - 클라우드 환경과의 연결을 위한 VPN 게이트웨이 역할을 하는 EC2 인스턴스 (리눅스)

2. 타겟 환경
   - 3개의 퍼블릭 서브넷이 있는 Amazon Virtual Private Cloud (Amazon VPC)와 기본 네트워크 토폴로지
   - 위 VPC에 위치하는 ```AWS Database Migration Service (AWS DMS)``` 복제 인스턴스
   - 타겟 데이터베이스
   - Amazon Elastic Compute Cloud (EC2) 인스턴스 (윈도우)
     - 마이그레이션에 사용하는 데이터베이스 도구 및 AWS SCT (AWS Schema Conversion Tool) 포함


> 📕 참고<br>
> IPsec (Internet Protocol Security) VPN은 인터넷 프로토콜(IP) 통신을 보호하기 위한 프로토콜 모음입니다. IPsec은 데이터 무결성, 인증, 암호화를 통해 IP 네트워크에서 안전한 통신을 보장합니다. IPsec VPN은 주로 두 가지 모드로 작동합니다:
> 1. **터널 모드 (Tunnel Mode)**: IP 패킷 전체를 암호화하여 새로운 IP 헤더를 추가합니다. 주로 네트워크 간의 VPN 연결에 사용됩니다.
> 2. **전송 모드 (Transport Mode)**: IP 패킷의 페이로드만 암호화하고 원래 IP 헤더는 그대로 둡니다. 주로 호스트 간의 통신에 사용됩니다.
> 
> IPsec은 개방형 표준으로, 다양한 벤더와 플랫폼에서 지원됩니다. IPsec은 IETF (Internet Engineering Task Force)에서 정의한 여러 RFC (Request for Comments) 문서에 의해 표준화되어 있습니다.

---

다음 단계로 진행하세요.

- [공통 설정](./Setup-Common-Configuration.md)
- [소스 환경 구성](./Setup-Source-Environment.md)
- [타겟 환경 구성](./Setup-Target-Environment.md)
- [소스/타겟 연결 구성](./Setup-Source-Target-Connectivity.md)

