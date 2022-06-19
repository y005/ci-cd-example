#!/usr/bin/env bash

REPOSITORY=/product
cd $REPOSITORY

JAR_NAME=$(ls $REPOSITORY/build/libs/ | grep '.jar' | tail -n 1)
JAR_PATH=$REPOSITORY/build/libs/$JAR_NAME

#현재 실행되고 있는 어플리케이션 pid 확인
CURRENT_PID=$(pgrep -fl action | grep java | awk '{print $1}')

if [ -z $CURRENT_PID ]
then
  echo '종료해야 하는 자바 프로그램 없음'
else
  echo '종료 시켜야 되는 자바 프로그램 발견'
  kill -15 $CURRENT_PID
  sleep 5
fi

#배포된 파일을 백그라운드 모드로 실행하면서 로그아웃 후에도 프로세스가 죽지 않고 진행되고
#실행 파일에 의해 발생되는 출력을 화면에 보이지 않게 하는 명령어
nohup java -jar $JAR_PATH &

mkdir moon
#nohup java -jar $JAR_PATH > /dev/null 2> /dev/null < /dev/null &
