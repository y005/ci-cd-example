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
`Spring Boot` `Github Action` `AWS EC2` `AWS S3` `AWS CodeDeploy` `AWS CodePipeline`

### CI/CD 파이프라인 동작 과정
1. main branch에 push 이벤트 감지
2. Github action에서 테스트와 빌드를 수행할 수 있는 환경 세팅
3. 테스트가 성공적으로 수행되면 빌드를 수행하고 .zip 형태로 압축
4. AWS S3 접근 권한과 관련된 설정 정보와 AWS CLI를 사용하여 압축된 파일을 S3에 업로드
5. AWS CodePipeline에서 S3의 배포 프로젝트의 변화 감지
6. Build 과정은 건너뛰고 Deploy 과정 수행
7. CodeDeploy에서 지정한 EC2에 빌드된 프로젝트 반영

### 프로젝트 세팅 과정

#### 1. [AWS CLI access key 발급](https://docs.aws.amazon.com/accounts/latest/reference/root-user-access-key.html)
#### 2. [AWS S3 버킷 생성](https://docs.aws.amazon.com/codepipeline/latest/userguide/tutorials-simple-s3.html#s3-create-s3-bucket)
#### 3. [AWS EC2 생성](https://docs.aws.amazon.com/codepipeline/latest/userguide/tutorials-simple-codecommit.html#codecommit-create-deployment)
- AmazonEC2RoleforAWSCodeDeploy 역할를 생성한 인스턴스에 부여해야 한다.
- 생성한 인스턴스에 접속하여 CodeDeploy agent를 [설치](https://docs.aws.amazon.com/codedeploy/latest/userguide/codedeploy-agent-operations-install-linux.html)한다.

```cmd
sudo yum update
sudo yum install ruby
sudo yum install wget
wget https://aws-codedeploy-ap-northeast-2.s3.ap-northeast-2.amazonaws.com/latest/install
sudo yum install java-11-openjdk
chmod +x ./install
sudo ./install auto
```
  
#### 4. [AWS CodeDeploy 세팅](https://docs.aws.amazon.com/codepipeline/latest/userguide/tutorials-simple-s3.html#S3-create-deployment)
- Amazon EC2를 설정하고 Name의 Key에는 3에서 생성한 인스턴스의 이름을 입력한다.
#### 5. [AWS CodePipeline 세팅](https://docs.aws.amazon.com/codepipeline/latest/userguide/tutorials-simple-s3.html#s3-create-pipeline)
- Source Provider로 S3를 선택한 후 2의 버킷 이름과 배포할 프로젝트 이름을 입력한다.
- Deploy Provider로 4의 CodeDeploy 애플리케이션 이름를 입력한다.
#### 6. Github action .yml 작성
```yml
name: Java CI with Gradle & Upload to AWS S3 & Slack Notification

//workflow가 시작되는 조건 정보
on:
  push:
    branches: [ "main" ]

//수행할 job 목록
jobs:

  //빌드와 업로드를 수행하는 job
  build_upload:

    //workflow를 수행할 서버의 운영체재 설정
    runs-on: ubuntu-latest

    steps:
    - name: setting checkout
      uses: actions/checkout@v3
      
    //자바 개발 환경 설정      
    - name: Set up JDK 11
      uses: actions/setup-java@v3
      with:
        java-version: '11'
        distribution: 'temurin'

    //gradlew에 대한 실행 권한 부여
    - name: execution permission for gradlew
      run: chmod +x gradlew
      shell: bash
      
    - name: Build with Gradle
      run: ./gradlew build
      shell: bash
      
    //S3에 .zip 형태로 올려야 배포가 됨  
    - name: Make zip file
      run: zip -qq -r ./${{secrets.PROJECT}}.zip .
      shell: bash
      
    //aws cli 사용을 위한 액세스 키 설정
    - name: Configure AWS
      uses: aws-actions/configure-aws-credentials@v1
      with:
        aws-access-key-id: ${{ secrets.KEY }}
        aws-secret-access-key: ${{ secrets.SECRETE }}
        aws-region: ${{ secrets.REGION }}
        
    - name: Upload to S3
      run: aws s3 cp --region ${{ secrets.REGION }} ./${{ secrets.PROJECT }}.zip s3://${{ secrets.BUCKET }}/${{secrets.PROJECT}}.zip

    //slack 웹훅 이용
    - name: Slack Webhook
      uses: 8398a7/action-slack@v3
      with:
        status: ${{ job.status }}
        author_name: Github Action Test
        fields: repo,message,commit,author,action,eventName,ref,workflow,job,took
      env:
        SLACK_WEBHOOK_URL: ${{ secrets.SLACK }}
      if: always()

```
#### 7. appspec.yml & deploy.sh 작성
EC2로 배포된 후 실행되어야 하는 동작을 정의한 스크립트를 작성해야 한다.
```yml
version: 0.0
os: linux

files:
  - source: /
    destination: /product
permissions:
  - object: /product/
    owner: ec2-user
    group: ec2-user
    mode: 755
hooks:
  AfterInstall:
    - location: deploy.sh
      timeout: 300
      runas: root
```
```bash
#!/usr/bin/env bash

REPOSITORY=/product
cd $REPOSITORY

JAR_NAME=$(ls $REPOSITORY/build/libs/ | grep '.jar' | head -n 1)
JAR_PATH=$REPOSITORY/build/libs/$JAR_NAME

#현재 실행되고 있는 어플리케이션 pid 확인
CURRENT_PID = $(sudo netstat -tnlp | grep 8080 | gawk '{ print $7 }' | grep -o '[0-9]*')

if [ -z $CURRENT_PID ]
then
  echo '프로그램 발견 안됨'
else
  echo '프로그램 발견됨'
  kill -15 $CURRENT_PID
  sleep 5
fi

#배포된 파일을 백그라운드 모드로 실행하면서 로그아웃 후에도 프로세스가 죽지 않고 진행되고
#실행 파일에 의해 발생되는 출력을 화면에 보이지 않게 하는 명령어
nohup java -jar $REPOSITORY/$JAR_NAME 2>&1 &

```

---

[Tutorial: Create a simple pipeline (S3 bucket)](https://docs.aws.amazon.com/codepipeline/latest/userguide/tutorials-simple-s3.html)

[Create an Amazon EC2 Linux instance and install the CodeDeploy agent](https://docs.aws.amazon.com/codepipeline/latest/userguide/tutorials-simple-codecommit.html#codecommit-create-deployment)

[github action과 aws code deploy를 이용하여 spring boot 배포하기](https://isntyet.github.io/deploy/github-action%EA%B3%BC-aws-code-deploy%EB%A5%BC-%EC%9D%B4%EC%9A%A9%ED%95%98%EC%97%AC-spring-boot-%EB%B0%B0%ED%8F%AC%ED%95%98%EA%B8%B0(1)/)
