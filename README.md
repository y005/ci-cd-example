## CI/CD

![](https://velog.velcdn.com/images/zakumann/post/57d88bed-ed95-4f9a-ad05-2487ca9549ec/image.svg)

### CI(Continuously Integration)
애플리케이션에 대한 새로운 코드 변경 사항이 정기적으로 빌드 및 테스트되어 공유 리포지토리에 통합하는 것
### CD(Continuously Deployment)
개발자의 변경 사항을 리포지토리에서 고객이 사용 가능한 프로덕션 환경까지 자동으로 릴리스하는 것
### Github Action
Git Repo 프로젝트의 빌드 테스트 및 배포 파이프라인을 자동화할 수 있는 CI/CD 플랫폼
### AWS CodePipline
소스의 변화를 감지하고 빌드한 다음 배포를 하는 과정을 자동으로 수행할 수 있게 하는 서비스
### AWS CodeDeploy
CodePipeLine의 배포 단계에서 선택하는 배포 제공자 서비스

---
### 프로젝트 설명
Github action과 AWS 서비스를 사용한 CI/CD 파이프라인 실습 프로젝트

### 사용기술
`Java` `Spring Boot` `Gradle` `Github Action` `AWS EC2` `AWS S3` `AWS CodeDeploy` `AWS CodePipeline`

### CI/CD 파이프라인 동작 과정
1. main branch에 push 이벤트 감지
2. Github action에서 테스트와 빌드를 수행할 수 있는 환경 세팅
3. 테스트가 성공적으로 수행되면 빌드를 수행하고 .zip 형태로 압축
4. AWS S3 접근 권한과 관련된 설정 정보와 AWS CLI를 사용하여 압축된 파일을 S3에 업로드
5. AWS CodePipeline에서 S3의 배포 프로젝트의 변화 감지
6. Build 과정은 건너뛰고 Deploy 과정 수행
7. CodeDeploy에서 지정한 EC2에 빌드된 프로젝트 반영

---

[Tutorial: Create a simple pipeline (S3 bucket)](https://docs.aws.amazon.com/codepipeline/latest/userguide/tutorials-simple-s3.html)

[Create an Amazon EC2 Linux instance and install the CodeDeploy agent](https://docs.aws.amazon.com/codepipeline/latest/userguide/tutorials-simple-codecommit.html#codecommit-create-deployment)
[github action과 aws code deploy를 이용하여 spring boot 배포하기](https://isntyet.github.io/deploy/github-action%EA%B3%BC-aws-code-deploy%EB%A5%BC-%EC%9D%B4%EC%9A%A9%ED%95%98%EC%97%AC-spring-boot-%EB%B0%B0%ED%8F%AC%ED%95%98%EA%B8%B0(1)/)
