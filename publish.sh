#!/bin/bash
#参数1项目名：cms / qc / wx / cloud-1/2 / config-1/2 /api-1/2
jobname=$1
#参数2端口号：8500 / 8081 / 8600 / 8700 / 8888 / 8650
portnum=$2
#参数3分支：alpha / beta
whichone=$3
#参数4参数：test / prod
active=$4

#成功信息
success_info(){
	echo "${jobname}更新成功"
	printf "%-16s %-16s %-16s %-16s %-16s\n" 项目 端口 CASE 日期 时间
	printf "%-16s %-16s %-16s %-16s %-16s\n" $jobname $portnum $whichone `date '+%Y-%m-%d %H:%M:%S'`
}
#错误信息
error_info(){
	printf "错误${jobname} \n"
	printf "%-16s %-16s %-16s\n" 项目 日期 时间
	printf "%-16s %-16s %-16s\n" 错误$jobname `date '+%Y-%m-%d %H:%M:%S'`
}

#文件管理
file_manage(){
	date_str=$(date +%Y%m%d-%H%M%S) && 
	
	#目录初始化，已存在则忽略，不存在则创建
	mkdir -p /website/${whichone}/${jobname}
	mkdir -p /website/backup/${jobname}/${date_str}
	
	echo -e "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n已接收jenkins远程传输包：\n$(stat /website/jenkins/${jobname}/*.jar)\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
	
	mv /website/${whichone}/${jobname}/* /website/backup/${jobname}/${date_str}/ &&
	echo "1.旧版jar及日志备份，成功：\n`ls -l /website/backup/${jobname}/${date_str}/*`"
	
	cp /website/jenkins/${jobname}/*.jar /website/${whichone}/${jobname}/${jobname}.jar && 
	echo "2.替换新版jar包，成功：/website/${whichone}/${jobname}/${jobname}.jar"
	rm -rf /website/jenkins/${jobname}/*

	echo -e "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n更新包信息:\n$(stat /website/$whichone/$jobname/$jobname.jar)\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"

	sleep 1
}

#杀死进程
kill_job(){
	# 检查端口号是否存在，存在则杀死
	echo "4.检查端口号${portnum}是否被占用，已占用则杀死进程"
	job_pid=$(netstat -ntlp | grep $portnum | awk '{print $7}' | awk -F"/" '{ print $1 }')
	if [ -n "$job_pid" ]; then
		job_etime=$(ps -eo pid,lstart,etime | grep $job_pid | awk '{print $7}')
		echo "5.端口${portnum}已占用，所在进程${job_pid}已持续运行${job_etime}，准备杀死"
		while [ $(netstat -ntlp | grep $portnum | awk '{print $7}' | awk -F"/" '{ print $1 }') ]
		do
			kill -9 $(netstat -ntlp | grep $portnum | awk '{print $7}' | awk -F"/" '{ print $1 }')
			sleep 3
		done
		echo "再杀一次，应返回：No such process！"
		kill -9 $job_pid
		sleep 2
	else
		echo "5.${portnum}端口未占用，进程$(netstat -ntlp | grep $portnum | awk '{print $7}' | awk -F"/" '{ print $1 }')不存在"
	fi
}

# 启动进程
run_job(){
	case $jobname in
	'cms')
		echo "6.准备启动/website/${whichone}/${jobname}/${jobname}.jar，端口${portnum}"
		date_str=$(date +%Y%m%d-%H%M%S)
		nohup /usr/local/java/jdk1.8.0_191/bin/java -jar /website/$whichone/$jobname/$jobname.jar --server=127.0.0.1 --server.port=$portnum --spring.profiles.active=$active > /website/$whichone/$jobname/$jobname-$active-$date_str.log 2>&1 &
		echo "nohup /usr/local/java/jdk1.8.0_191/bin/java -jar /website/$whichone/$jobname/$jobname.jar --server=127.0.0.1 --server.port=$portnum --spring.profiles.active=$active > /website/$whichone/$jobname/$jobname-$active-$date_str.log 2>&1 &"
		sleep 120
	;;
	'qc')
		echo "6.准备启动/website/${whichone}/${jobname}/${jobname}.jar，端口${portnum}"
		date_str=$(date +%Y%m%d-%H%M%S)
		nohup /usr/local/java/jdk1.8.0_191/bin/java -jar /website/$whichone/$jobname/$jobname.jar --server=127.0.0.1 --server.port=$portnum --spring.profiles.active=$active > /website/$whichone/$jobname/$jobname-$active-$date_str.log 2>&1 &
		echo "nohup /usr/local/java/jdk1.8.0_191/bin/java -jar /website/$whichone/$jobname/$jobname.jar --server=127.0.0.1 --server.port=$portnum --spring.profiles.active=$active > /website/$whichone/$jobname/$jobname-$active-$date_str.log 2>&1 &"
		sleep 120
	;;
	'wx')
		echo "6.准备启动/website/${whichone}/${jobname}/${jobname}.jar，端口${portnum}"
		date_str=$(date +%Y%m%d-%H%M%S)
		nohup /usr/local/java/jdk1.8.0_191/bin/java -jar /website/$whichone/$jobname/$jobname.jar --server=127.0.0.1 --server.port=$portnum --spring.profiles.active=$active > /website/$whichone/$jobname/$jobname-$active-$date_str.log 2>&1 &
		echo "nohup /usr/local/java/jdk1.8.0_191/bin/java -jar /website/$whichone/$jobname/$jobname.jar --server=127.0.0.1 --server.port=$portnum --spring.profiles.active=$active > /website/$whichone/$jobname/$jobname-$active-$date_str.log 2>&1 &"
		sleep 120
	;;
	'cloud-1'|'cloud-2')
		echo "6.准备启动/website/${whichone}/${jobname}/${jobname}.jar，端口${portnum}"
		date_str=$(date +%Y%m%d-%H%M%S)
		nohup /usr/local/java/jdk1.8.0_191/bin/java -jar /website/$whichone/$jobname/$jobname.jar --server=0.0.0.0 --server.port=$portnum --spring.profiles.active=$active > /website/$whichone/$jobname/$jobname-$active-$date_str.log 2>&1 &
		echo "nohup /usr/local/java/jdk1.8.0_191/bin/java -jar /website/$whichone/$jobname/$jobname.jar --server=0.0.0.0 --server.port=$portnum --spring.profiles.active=$active > /website/$whichone/$jobname/$jobname-$active-$date_str.log 2>&1 &"
		sleep 120
	;;
	'config-1'|'config-2')
		echo "6.准备启动/website/${whichone}/${jobname}/${jobname}.jar，端口${portnum}"
		date_str=$(date +%Y%m%d-%H%M%S)
		nohup /usr/local/java/jdk1.8.0_191/bin/java -jar /website/$whichone/$jobname/$jobname.jar --server=0.0.0.0 --server.port=$portnum --spring.profiles.active=$active,jdbc > /website/$whichone/$jobname/$jobname-$active-$date_str.log 2>&1 &
		echo "nohup /usr/local/java/jdk1.8.0_191/bin/java -jar /website/$whichone/$jobname/$jobname.jar --server=0.0.0.0 --server.port=$portnum --spring.profiles.active=$active,jdbc > /website/$whichone/$jobname/$jobname-$active-$date_str.log 2>&1 &"
		sleep 120
	;;
	'api-1'|'api-2')
		echo "6.准备启动/website/${whichone}/${jobname}/${jobname}.jar，端口${portnum}"
		date_str=$(date +%Y%m%d-%H%M%S)
		nohup /usr/local/java/jdk1.8.0_191/bin/java -jar /website/$whichone/$jobname/$jobname.jar --server=0.0.0.0 --server.port=$portnum --spring.profiles.active=$active > /website/$whichone/$jobname/$jobname-$active-$date_str.log 2>&1 &
		echo "nohup /usr/local/java/jdk1.8.0_191/bin/java -jar /website/$whichone/$jobname/$jobname.jar --server=0.0.0.0 --server.port=$portnum --spring.profiles.active=$active > /website/$whichone/$jobname/$jobname-$active-$date_str.log 2>&1 &"
		sleep 120
	;;
	*)
		error_info
	;;
	esac
}

# 状态复查
check_job(){
	echo "7.准备检测"
	job_pid=$(netstat -ntlp | grep $portnum | awk '{print $7}' | awk -F"/" '{ print $1 }')
	if [ -n "$job_pid" ];then
		echo "PID是${job_pid}"
		job_etime=$(ps -eo pid,lstart,etime | grep $job_pid | awk '{print $7}')
		job_etime_array=(${job_etime//:/ })
		echo "持续时间${job_etime}"
		if [ ${job_etime_array[2]} ] || [ ${job_etime_array[0]} -gt 3 ];then
			echo "旧版本进程没有杀死，重试"
			kill_job
			run_job
			check_job
		fi
		
		if [ -z ${job_etime_array[2]} ] && [ ${job_etime_array[0]} -le 3 ];then
			echo "检测完成，启动正确!"
		fi
		
	else
		echo "端口${portnum}未开启，再次尝试启动进程..."
		run_job
		check_job
	fi
	
}
cmsweb(){
# cms前端静态文件替换
	date_str=$(date +%Y%m%d-%H%M%S) && 
	echo -e "当前时间：`date` \n${date_str}\n1.接收构建包:\n$(stat /website/jenkins/cmsweb/dist.tar.gz)"
	mv /website/${whichone}/cmsweb/dist /website/backup/cmsweb/dist-${date_str}
	echo -e "2.备份旧版本信息：\n/website/backup/cmsweb/dist-${date_str}\n$(ls -l /website/backup/cmsweb/dist-${date_str})"
	echo -e "3.解压上线新版静态文件\n"
	tar xzvf /website/jenkins/cmsweb/dist.tar.gz -C /website/${whichone}/cmsweb/
	echo -e "4.查看目录确认\nls -l /website/${whichone}/cmsweb/dist\n$(ls -l /website/${whichone}/cmsweb/dist)"
}
# cms后台
cms(){
    file_manage
	kill_job
	run_job
	check_job
	success_info
}
# qc服务
qc(){
	file_manage
	kill_job
	run_job
	check_job
	success_info
}
# 微信服务
wx(){
    file_manage
	kill_job
	run_job
	check_job
	success_info
}
# cloud注册中心
cloud(){
	file_manage
	kill_job
	run_job
	check_job
	success_info
}
# cloud注册中心
config(){
	file_manage
	kill_job
	run_job
	check_job
	success_info
}
# cloud注册中心
api(){
	file_manage
	kill_job
	run_job
	check_job
	success_info
}

#从这里开始
job_start(){
	printf "项目：${jobname}，端口：${portnum} \n"
	case $jobname in
	'cmsweb')
		cmsweb
	;;
	'cms')
		cms
	;;
	'qc')
		qc
	;;
	'wx')
		wx
	;;
	'cloud-1'|'cloud-2')
		cloud
	;;
	'config-1'|'config-2')
		config
	;;
	'api-1'|'api-2')
		api
	;;
	*)
		error_info
	;;
	esac
}

# 启动
job_start
