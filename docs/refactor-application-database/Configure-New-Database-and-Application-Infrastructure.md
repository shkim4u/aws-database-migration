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
cd aws-database-migration
```

해당 소스 코드에는 테라폼으로 작성된 IaC 코드도 포함되어 있으며 여기에는 우리가 이번 과정에서 목표로 하는 타겟 데이터베이스 자원인 ```Amazon RDS```, 관리형 컨테이너 오케스트레이션 서비스인 ```Amazon EKS```, 프론트엔드 호스팅을 위한 ```Amazon CloudFront```, 그리고 이벤트 드리븐 아키텍처를 구성하는 ```Amazon MSK``` 등의 자원이 포함되어 있습니다.

우선 이 테라폼 코드를 사용하여 자원을 배포하도록 합니다.

---

## 3. 데이터베이스 및 애플리케이션 인프라 구성

본격적으로 자원을 생성하기 앞서, 우선 아래 명령을 실행하여 몇몇 ALB (애플리케이션, ```ArgoCD```, ```Argo Rollouts``` 등에 접속하기 위한 엔드포인트 역할)에서 사용하기 위한 ```Amazon Certificate Manager (ACM)``` 사설 (Private) CA를 생성하고 Self-signed Root CA 인증서를 설치합니다.


```bash
hash -d aws

cd ~/environment/aws-database-migration/infrastructure/terraform

# 1. Configure Terraform workspace and Private Certificate Authority.
. ./configure.sh aws-database-migration ap-northeast-2

env | grep TF_VAR

cat <<EOF >> terraform.tfvars
ca_arn = "${TF_VAR_ca_arn}"
eks_cluster_production_name = "${TF_VAR_eks_cluster_production_name}"
eks_cluster_staging_name = "${TF_VAR_eks_cluster_staging_name}"
EOF
```
