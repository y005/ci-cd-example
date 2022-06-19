#!/usr/bin/env bash

REPOSITORY=/product
cd $REPOSITORY

JAR_NAME=$(ls $REPOSITORY/build/libs/ | grep '.jar' | head -n 1)
JAR_PATH=$REPOSITORY/build/libs/$JAR_NAME

#현재 실행되고 있는 어플리케이션 pid 확인
sudo kill -15 `sudo netstat -tnlp|grep 8080 |gawk '{ print $7 }'|grep -o '[0-9]*'`

#배포된 파일을 백그라운드 모드로 실행하면서 로그아웃 후에도 프로세스가 죽지 않고 진행되고
#실행 파일에 의해 발생되는 출력을 화면에 보이지 않게 하는 명령어
nohup java -jar $JAR_PATH 2>&1 &
