# ***AWS 데이터베이스 마이그레이션 워크샵***

![DMS Logo](../images/workshop-logo.png "AWS 데이터베이스 마이그레이션 워크샵")

데이터베이스 마이그레이션은 마이그레이션 전 평가, 데이터베이스 스키마 및 코드 변환, 데이터 마이그레이션, 기능 테스트, 성능 조정 및 기타 여러 단계를 포함하는 복잡한 다단계 프로세스일 수 있습니다. 이 프로세스에서 가장 많은 노력이 필요한 두 가지 기본 단계는 스키마 및 데이터베이스 코드 개체의 변환과 데이터 자체의 마이그레이션입니다. 다행히 AWS는 각 단계에 도움이 되는 도구를 제공합니다. 이 워크숍은 데이터베이스 마이그레이션 여정을 시작하기 전에 이러한 도구를 직접 사용해 보고 경험을 얻을 수 있는 방법을 제공합니다.

> ⚠️ 이 워크샵에서 사용된 AWS 콘솔 조작과 관련된 설명 및 스크린샷은 ```영어 (English (US))```로 설정된 것을 가정하고 작성되었습니다.

> 📕 (참고)<br>
> - 여기에 포함된 내용은 지속적으로 추가 및 업데이트될 예정입니다.
> - 이 글을 작성하는 현재 (2024-08-22) 시점에 적용된 AWS 서비스와 관련된 화면은 실제 워크샵 수행 시에는 다르게 보일 수 있습니다. 주목할 만한 사항이 있을 경우 진행자가 사전에 안내를 드릴 수 있도록 하겠습니다.

---

## 목차

* [AWS 데이터베이스 마이그레이션 소개 (현재 페이지)](README.md)
  * [스키마 전환](Schema-Conversion.md)
  * [데이터 마이그레이션](Data-Migration.md)
* [환경 설정](environment-setup/Environment-Setup-README.md)
  * [Amazon Bedrock 구성](prerequisites/3-Prerequisites-Owned-Account-1-Amazon-Bedrock-Setup.md)
  * [AWS Cloud9 구성](prerequisites/3-Prerequisites-Owned-Account-2-Cloud9-Setup.md)
  * [실습 환경 설정](prerequisites/3-Prerequisites-Owned-Account-3-Lab-Setup.md)
* [Amazon Bedrock 가드레일 실습](amazon-bedrock-guardrails/8-Amazon-Bedrock-Guardrails.md)
  * [Lab S-1: AWS 콘솔에서 가드레일 생성](amazon-bedrock-guardrails/8-Amazon-Bedrock-Guardrails-1-Create-Guardrails-Console.md)
  * [Lab S-2: 프로그램을 통해 가드레일 생성](amazon-bedrock-guardrails/8-Amazon-Bedrock-Guardrails-2-Create-Guardrails-API.md)
  * [Lab S-3: 가드레일과 함께 모델 호출](amazon-bedrock-guardrails/8-Amazon-Bedrock-Guardrails-3-Invoking-Guardrails.md)
  * [Lab S-4: 콘텐츠 차단](amazon-bedrock-guardrails/8-Amazon-Bedrock-Guardrails-4-Contents-Blocking.md)
  * [Lab S-5: PII 마스킹](amazon-bedrock-guardrails/8-Amazon-Bedrock-Guardrails-5-PII-Masking.md)

---

## 관련 프리젠테이션
[생성형 AI 및 보안 개요](https://shkim4u-generative-ai.s3.ap-northeast-2.amazonaws.com/amazon-bedrock-security-and-safeguards/Generative-AI-Security-Overview.pdf)
