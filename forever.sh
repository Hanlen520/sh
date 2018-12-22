#!/bin/bash

#参数1项目名：cms / qc / wx / cloud-1/2 / config-1/2 /api-1/2
jobname=$1
#参数2端口号：8500 / 8081 / 8600 / 8700 / 8888 / 8650
portnum=$2
#参数3分支：alpha / beta
whichone=$3
#参数4参数：test / prod
active=$4

kill_forever(){
	job_pid=$(ps -ef | grep publish.sh | awk '{print $2}')
	if [ ${job_pid} ]
	then
		kill -9 ${job_pid}
		sleep 5
	fi
}
kill_forever
echo "开始部署"
nohup sh /website/sh/publish.sh ${jobname} ${portnum} ${whichone} ${active}  > /website/sh/foever.out 2>&1 &
tail -f /website/sh/foever.out