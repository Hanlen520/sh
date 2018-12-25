#!/bin/bash
#参数1项目名：cms / qc / wx / cloud-1/2/3 / config-1/2/3 /api-1/2/3 message-1/2
jobname=$1
#参数2端口号：8500 / 8081 / 8600 / 8700 / 8888 / 8650 / 8350
portnum=$2
#参数3分支：alpha / beta
whichone=$3
#参数4参数：test / prod
active=$4

# 变量初始化
VAR_INIT(){
	date_str=$(date +%Y-%m-%d__%H-%M-%S)
	jenkins_dir=/website/jenkins/$jobname
	job_dir=/website/$whichone/$jobname
	backup_dir=/website/backup/$jobname
	java_home=/usr/local/java/jdk1.8.0_191/bin/java
}
# 日至备份
LOG_BAK(){
	echo "备份日志 - - - - - cp -rf $job_dir/$active-$jobname.out $job_dir/$active-$jobname-date_str.out"
	if [ -f "$job_dir/$active-$jobname.out" ]
	then
		cp -rf $job_dir/$active-$jobname.out $job_dir/$active-$jobname-date_str.out
	fi
}
# 启动进程
RUN_JOB(){
	echo "重新启动 - - - - - JAVA项目:$jobname，使用端口:$portnum，启动环境:$active"
	case $jobname in
	'cms')
	date_str=$(date +%Y%m%d-%H%M%S)
	nohup $java_home -jar $job_dir/$jobname.jar --server=127.0.0.1 --server.port=$portnum --spring.profiles.active=$active > $job_dir/$active-$jobname.out 2>&1 &
	echo "nohup $java_home -jar $job_dir/$jobname.jar --server=127.0.0.1 --server.port=$portnum --spring.profiles.active=$active > $job_dir/$active-$jobname.out 2>&1 &"
	sleep 120
	;;
	'qc')
	date_str=$(date +%Y%m%d-%H%M%S)
	nohup $java_home -jar $job_dir/$jobname.jar --server=127.0.0.1 --server.port=$portnum --spring.profiles.active=$active > $job_dir/$active-$jobname.out 2>&1 &
	echo "nohup $java_home -jar $job_dir/$jobname.jar --server=127.0.0.1 --server.port=$portnum --spring.profiles.active=$active > $job_dir/$active-$jobname.out 2>&1 &"
	sleep 120
	;;
	'wx')
	date_str=$(date +%Y%m%d-%H%M%S)
	nohup $java_home -jar $job_dir/$jobname.jar --server=127.0.0.1 --server.port=$portnum --spring.profiles.active=$active > $job_dir/$active-$jobname.out 2>&1 &
	echo "nohup $java_home -jar $job_dir/$jobname.jar --server=127.0.0.1 --server.port=$portnum --spring.profiles.active=$active > $job_dir/$active-$jobname.out 2>&1 &"
	sleep 120
	;;
	'cloud'|'cloud-1'|'cloud-2'|'cloud-3')
	date_str=$(date +%Y%m%d-%H%M%S)
	nohup $java_home -jar $job_dir/$jobname.jar --server=0.0.0.0 --server.port=$portnum --spring.profiles.active=$active > $job_dir/$active-$jobname.out 2>&1 &
	echo "nohup $java_home -jar $job_dir/$jobname.jar --server=0.0.0.0 --server.port=$portnum --spring.profiles.active=$active > $job_dir/$active-$jobname.out 2>&1 &"
	sleep 120
	;;
	'config'|'config-1'|'config-2'|'config-3')
	date_str=$(date +%Y%m%d-%H%M%S)
	nohup $java_home -jar $job_dir/$jobname.jar --server=0.0.0.0 --server.port=$portnum --spring.profiles.active=$active,jdbc > $job_dir/$active-$jobname.out 2>&1 &
	echo "nohup $java_home -jar $job_dir/$jobname.jar --server=0.0.0.0 --server.port=$portnum --spring.profiles.active=$active,jdbc > $job_dir/$active-$jobname.out 2>&1 &"
	sleep 120
	;;
	'api'|'api-1'|'api-2'|'api-3')
	date_str=$(date +%Y%m%d-%H%M%S)
	nohup $java_home -jar $job_dir/$jobname.jar --server=0.0.0.0 --server.port=$portnum --spring.profiles.active=$active > $job_dir/$active-$jobname.out 2>&1 &
	echo "nohup $java_home -jar $job_dir/$jobname.jar --server=0.0.0.0 --server.port=$portnum --spring.profiles.active=$active > $job_dir/$active-$jobname.out 2>&1 &"
	sleep 120
	;;
	*)
	ERROR_INFO
	;;
	esac
}
# 状态复查
FOREVER_CHECK(){
	job_pid=$(netstat -ntlp | grep $portnum | awk '{print $7}' | awk -F"/" '{ print $1 }')
	job_etime=$(ps -eo pid,lstart,etime | grep $job_pid | awk '{print $7}')
	if [ $job_pid ];then
		echo "===== JAVA项目$jobname端口$portnum所在PID$job_pid已续存$job_etime"
		echo "$date_str - - - - - 检测完成，启动正确，180 s 后再次轮询 <<<<<"
	else
		echo "端口$portnum未监听，备份日志，准备尝试启动进程..."
		LOG_BAK
		RUN_JOB
		FOREVER_CHECK
	fi
}
# 端口守护
FOREVER(){
	echo "- - - - -守护进程启动...守护项目$jobname...守护端口$portnum...启动分支$whichone...启动环境$active... 180 s 后第一次检测- - - - -"
	while true
	do
		sleep 180
		VAR_INIT
		echo "$date_str - - - - - 开始检测 >>>>>"
		# 获取端口的进程号
		job_pid=$(netstat -ntlp | grep -v grep | grep $portnum | awk '{print $7}' | awk -F"/" '{ print $1 }')
		job_etime=$(ps -eo pid,lstart,etime | grep $job_pid | awk '{print $7}')
		# 如果进程号为空，重启服务
		if [ $pid ]
		then
			echo "===== JAVA项目$jobname端口$portnum所在PID$job_pid已续存$job_etime"
			echo "$date_str - - - - - 检测完成，启动正确，180 s 后再次轮询 <<<<<"
		else
			echo "ERROR--!--!--$date_str- - - - -检测不到JAVA项目$jobname的端口$portnum，准备再次检测确认"
			FOREVER_CHECK
		fi
	done
}
# 开启守护进程
FOREVER

