# ***```Application Load Balancer```의 요청 라우팅 설정***

## **Agenda**
1. 개요
2. 기존 요청 트래픽에 대한 ```대상 그룹 (Target Group)``` 설정
3. ```Application Load Balancer (ALB)```에 ```대상 그룹``` 설정
4. 요청 라우팅 테스트

---

## **1. 개요**
우리는 ```HotelSpecials``` 서비스를 새로운 타겟 환경의 ```쿠버네테스``` 서비스인 ```Amazon EKS 클러스터```에 성공적으로 배포하였고, 비록 아직 데이터를 옮겨오지는 못하였지만 복제한 데이터베이스의 스키마가 정상적으로 동작하는 것을 확인하였습니다. 

```HotelSpecials``` 서비스의 데이터가 옮겨지더라도 여전히 다른 기능들은 온프레미스 소스 환경에서 수행 중이므로 ```Application Load Balancer```로 유입되는 트래픽을 아래와 같은 형태로 분기해야 합니다.

* ```HotelSpecials``` 서비스: 요청 경로 ```/travelbuddy/hotelspecials```
  * 사용자 -> ```CloudFront 프론트엔드``` -> ```ALB``` -> ```HotelSpecials``` 서비스 -> ```HotelSpecials``` Pod -> ```Amazon Aurora MySQL```
* 그 외 서비스 (```FlightSpecials``` 서비스 포함): 요청 경로 ```/*```
  * 사용자 -> ```CloudFront 프론트엔드``` -> ```ALB``` -> ```Transit Gateway``` -> ```Site-to-Site VPN``` (Customer Gateway) -> 온프레미스 VPN 장비 (Bastion) -> 레거시 ```TravelBuddy``` 애플리케이션 서버 -> ```Oracle 11gR2```

---

## **2. 기존 요청 트래픽에 대한 ```대상 그룹 (Target Group)``` 설정**

1. ```EC2 > 로드 밸런싱 > 대상 그룹```으로 이동하여 ```대상 그룹 생성``` 버튼을 클릭합니다.

    ![대상 그룹 생성](../../images/1-1-add-larget-group-legacy.png)

2. 아래와 같이 설정하고 ```다음```을 클릭합니다. (아래에 나열되지 않은 사항은 기본값을 사용합니다.)

    * **대상 유형 선택**: ```IP 주소```
    * **대상 그룹 이름**: ```Legacy-TravelBuddy-TargetGroup```
    * **프로토콜**: ```HTTP```
    * **포트**: ```8080```
    * **VPC**: ```M2M-VPC```
    * **상태 검사 경로**: ```/``` (기본값)
    * **고급 상태 검사 설정 > 성공 코드**: ```200,301,302,404```

    ![대상 그룹 설정 1](../../images/1-2-legacy-target-group-detail-1.png)

   ![대상 그룹 설정 2](../../images/1-2-legacy-target-group-detail-2.png)

   ![대상 그룹 설정 3](../../images/1-2-legacy-target-group-detail-3.png)

3. ```대상 등록``` 페이지에서 아래와 같이 설정하고 ```대상 그룹 등록```을 클릭합니다.

    * **1단계: 네트워크 선택**
      * **네트워크**: ```다른 프라이빗 IP 주소```
      * **가용 영역**: ```모두```
    * **2단계: IP 지정 및 포트 정의**
      * **프라이빗 IP 주소 입력**: ```(소스 측 담당자분께 확인) 애플리케이션 서버의 프라이빗 IP 주소```
      * **포트**: ```8080```
    * ```아래에 보류 중인 것으로 포함``` 버튼 클릭 

    ![대상 등록 1](../../images/1-3-legacy-target-group-ip.png)

---

## **3. ```Application Load Balancer (ALB)```에 ```대상 그룹``` 설정**

1. ```EC2 > 로드 밸런싱 > 로드 밸런서```로 이동하여 ```로드 밸런서 필터링``` 검색란에 ```travelbuddy```를 입력하고 표시되는 항목을 선택합니다.

    ![로드 밸런서 필터링](../../images/2-0-filter-alb.png)

    ![로드 밸런서 필터 결과](../../images/2-0-filtered-alb.png)

2. ```리스터 및 규칙``` 탭에서 ```HTTP:80```에 해당하는 ```2개 규칙``` 링크를 클릭하고 ```규칙 추가``` 버튼을 클릭합니다.

    ![규칙 추가 1](../../images/2-1-alb-add-http-80-rule-1.png)

    ![규칙 추가 2](../../images/2-1-alb-add-http-80-rule-2.png)

3. 다음 값을 설정하여 규칙 추가 과정을 진행하고 규칙을 생성합니다.

   * **이름**: ```Legacy-TravelBuddy-Route-Rule```
   * **규칙 조건 정의**
     * ```조건 추가``` 버튼 클릭
     * **규칙 조건 유형**: ```경로```
     * **경로**: ```/*```
   * **작업**:
     * **라우팅 액션**: ```대상 그룹으로 전달```
     * **대상 그룹**: ```Legacy-TravelBuddy-TargetGroup```
   * **규칙 우선 순위**: ```2```

   ![규칙 추가 값 1](../../images/2-1-alb-add-http-80-rule-params-1.png)

   ![규칙 추가 값 2](../../images/2-1-alb-add-http-80-rule-params-2.png)

   ![규칙 추가 값 3](../../images/2-1-alb-add-http-80-rule-params-3.png)

   ![규칙 추가 값 4](../../images/2-1-alb-add-http-80-rule-params-4.png)

   ![규칙 추가 값 5](../../images/2-1-alb-add-http-80-rule-params-5.png)

   ![규칙 추가 값 6](../../images/2-1-alb-add-http-80-rule-params-6.png)

   ![규칙 추가 값 7](../../images/2-1-alb-add-http-80-rule-params-7.png)

   ![규칙 추가 값 8](../../images/2-1-alb-add-http-80-rule-params-8.png)

4. ```EC2 > 대상 그룹 > Legacy-TravelBuddy-TargetGroup > 대상``` 탭에서 ```상태```가 ```healthy```로 표시되는지 확인합니다.

    ![대상 그룹 상태 확인](../../images/2-2-check-target-status.png)

---

## **4. 요청 라우팅 테스트**

이제 브라우저에서 ```Application Load Balancer```의 ```DNS 이름```을 사용하여 ```/travelbuddy/hotelspecials``` 경로와 (클라우드 타겟) ```/travelbuddy/flightspecials``` 경로 (온프레미스 소스) 모두 서비스그ㅏ 정상적으로 동작하는지 확인합니다.

1. ```Application Load Balancer```의 ```DNS 이름```을 복사합니다.

    ![ALB DNS 이름](../../images/2-3-alb-dns-name.png)

2. 브라우저에서 ```http://<위에서 확인한 ALB DNS 이름>/travelbuddy/hotelspecials```로 접속해 봅니다.

    ![HotelSpecials 서비스 접속](../../images/2-4-alb-hotel-service.png)

   > **참고**: 앞에서 언급된 대로 ```HotelSpecials``` 서비스의 데이터는 아직 마이그레이션되지 않았으므로 아무 데이터도 표시되지 않습니다. (정상)

3. 이번에는 브라우저에서 ```http://<ALB DNS 이름>/travelbuddy/flightspecials```로 접속하여 소스 측 서비스와 데이터베이스가 잘 접속되는지 확인합니다.

   ![FlightSpecials 서비스 접속](../../images/2-4-alb-flight-service.png)

---

## **마무리**

### 축하합니다! 이제 소스 데이터베이스와 이를 사용하는 애플리케이션을 실험을 거듭하면서 클라우드로 전환할 수 있는 기본적인 구조를 마련하였습니다.

### 이제 이를 바탕으로 데이터 마이그레이션을 수행하고, 이후에는 ```FlightSpecials``` 서비스를 마이그레이션하는 작업을 수행할 차례입니다.
