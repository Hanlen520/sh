#!/bin/bash
# 参数1项目名：cms / qc / wx / cloud-1/2 / config-1/2 /api-1/2
jobname=$1
# 参数2端口号：8500 / 8081 / 8600 / 8700 / 8888 / 8650
portnum=$2
# 参数3分支：alpha / beta
whichone=$3
# 参数4参数：test / prod
active=$4

# 初始化
VAR_INIT(){
	date_str=$(date +%Y-%m-%d__%H-%M-%S)
	jenkins_dir=/website/jenkins/${jobname}
	job_dir=/website/${whichone}/${jobname}
	backup_dir=/website/backup/${jobname}
	java_home=/usr/local/java/jdk1.8.0_191/bin/java
	ip_local=$(ifconfig eth0 | grep "inet" | awk '{ print $2}')
	echo -e "--------------------变量初始化--------------------"
	echo -e "----------时    间：${date_str} \n "
	echo -e "----------接收目录：${jenkins_dir} \n "
	echo -e "----------工作目录：${job_dir} \n "
	echo -e "----------备份目录：${backup_dir} \n "
	echo -e "----------JAVAHOME：${java_home} \n "
	echo -e "----------内网IP：${ip_local} \n "
	#目录初始化，已存在则忽略，不存在则创建
	mkdir -p ${job_dir}
	mkdir -p ${backup_dir}/${date_str}
}
# 成功信息
SUCCESS_INFO(){
	date_str=$(date +%Y-%m-%d__%H-%M-%S)
	echo "${jobname}更新成功!!!!!!!!!!!!!"
	printf "%-16s %-16s %-16s %-16s %-16s\n" 项目 端口 CASE 日期 时间
	printf "%-16s %-16s %-16s %-16s %-16s\n" $jobname $portnum $whichone `date '+%Y-%m-%d %H:%M:%S'`
	echo "##########   查看日志： http://showlog.dev.qiancangkeji.cn/   ##########"
	echo "最后一步，备份守护进程日志，启动进程守护>>>>>>"
	mv /website/sh/forever.out /website/sh/forever_${date_str}.out
	nohup sh /website/sh/forever.sh ${jobname} ${portnum} ${whichone} ${active} > /website/sh/forever.out 2>&1 &
	echo -e " mv /website/sh/forever.out /website/sh/forever_${date_str}.out \n nohup sh /website/sh/forever.sh ${jobname} ${portnum} ${whichone} ${active} > /website/sh/forever.out 2>&1 &"
}
# 错误信息
ERROR_INFO(){
	printf "%-16s %-16s %-16s\n" 项目 日期 时间
	printf "%-16s %-16s %-16s\n" 错误$jobname `date '+%Y-%m-%d %H:%M:%S'`
	echo -e "错误${jobname} !!!!!!!!!!!!!\n检查启动参数\n参数1项目名：cms / qc / wx / cloud-1/2 / config-1/2 /api-1/2\n# 参数2端口号：8500 / 8081 / 8600 / 8700 / 8888 / 8650\n# 参数3分支：alpha / beta\n# 参数4参数：test / prod"
}
# 文件管理
FILE_MANAGE(){
	echo -e "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n已接收jenkins远程传输包：\n$(stat ${jenkins_dir}/*.jar)\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
	mv ${job_dir}/${jobname}.jar ${job_dir}/${active}-${jobname}-${date_str}.jar &&
	mv ${job_dir}/${active}-${jobname}.out ${job_dir}/${active}-${jobname}-${date_str}.out &&
	mv ${job_dir}/* ${backup_dir}/${date_str}/ &&
	echo -e "1.旧版jar及日志备份，成功：\n"ls -l ${backup_dir}/${date_str}/"\n`ls -l ${backup_dir}/${date_str}/*`"
	cp ${jenkins_dir}/*.jar ${job_dir}/${jobname}.jar && rm -rf ${jenkins_dir}/*
	echo -e "2.替换新版jar包，成功：${job_dir}/${jobname}.jar"
	echo -e "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n更新包信息:\n$(stat ${job_dir}/$jobname.jar)\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
	sleep 1
}
# 杀死守护进程
KILL_FOREVER(){
	forever_pid=$(ps -ef | grep forever.sh | grep -v grep | grep ${jobname} | grep ${portnum} | grep ${whichone} | grep ${active} | awk '{print $2}')
	forever_etime=$(ps -eo pid,lstart,etime | grep $forever_pid | awk '{print $7}')
	if [ ${forever_pid} ]; then
		echo -e "3.JAVA项目${jobname}存在守护进程PID${forever_pid}，已续存时间${forever_etime} \n-----验明正身，准备杀死-----"
		while [ $(ps -ef | grep forever.sh | grep -v grep | grep ${jobname} | grep ${portnum} | grep ${whichone} | grep ${active} | awk '{print $2}') ]
		do
			kill -9 $(ps -ef | grep forever.sh | grep -v grep | grep ${jobname} | grep ${portnum} | grep ${whichone} | grep ${active} | awk '{print $2}')
			sleep 3
		done
		echo -e "-----下一行返回：“No such process” 或 “没有那个进程”，则成功杀死守护进程 "
		kill -9 $forever_pid
		echo -e "-----进入下一步操作-----"
	else
		echo -e "3.JAVA项目${jobname}的守护进程$(ps -ef | grep forever.sh | grep ${jobname} | grep -v grep | awk '{print $2}')不存在，进入下一步操作"
		kill -9 $(ps -ef | grep forever.sh | grep -v grep | grep ${jobname} | grep ${portnum} | grep ${whichone} | grep ${active} | awk '{print $2}')
	fi
	sleep 2
}

# 杀死JAVA进程
KILL_JOB(){
	# 检查端口号是否存在，存在则杀死
	job_pid=$(netstat -ntlp | grep -v grep | grep $portnum | awk '{print $7}' | awk -F"/" '{ print $1 }')
	job_etime=$(ps -eo pid,lstart,etime | grep $job_pid | awk '{print $7}')
	if [ ${job_pid} ]; then
		echo "4.JAVA项目${jobname}端口${portnum}已占用，PID${job_pid}已续存${job_etime}，准备杀死"
		while [ $(netstat -ntlp | grep -v grep | grep $portnum | awk '{print $7}' | awk -F"/" '{ print $1 }') ]
		do
			kill -9 $(netstat -ntlp | grep -v grep | grep $portnum | awk '{print $7}' | awk -F"/" '{ print $1 }')
			sleep 3
		done
		echo -e "-----下一行返回：“No such process” 或 “没有那个进程”，则成功杀死守护进程 "
		kill -9 $job_pid
		echo -e "-----进入下一步操作-----"
	else
		echo -e "4.JAVA项目${jobname}的${portnum}端口未占用或已杀死，进程$(netstat -ntlp | grep $portnum | awk '{print $7}' | awk -F"/" '{ print $1 }')不存在，进入下一步操作"
		kill -9 $(netstat -ntlp | grep -v grep | grep $portnum | awk '{print $7}' | awk -F"/" '{ print $1 }')
	fi
	sleep 2
}
# 启动进程
RUN_JOB(){
	echo "5.重新启动JAVA项目:${jobname}，使用端口:${portnum}，启动环境:${active}"
	case $jobname in
	'cms')
		date_str=$(date +%Y%m%d-%H%M%S)
		nohup ${java_home} -jar ${job_dir}/$jobname.jar --server=127.0.0.1 --server.port=$portnum --spring.profiles.active=$active > ${job_dir}/$active-$jobname.out 2>&1 &
		echo "nohup ${java_home} -jar ${job_dir}/$jobname.jar --server=127.0.0.1 --server.port=$portnum --spring.profiles.active=$active > ${job_dir}/$active-$jobname.out 2>&1 &"
		sleep 120
	;;
	'qc') 
		date_str=$(date +%Y%m%d-%H%M%S)
		nohup ${java_home} -jar ${job_dir}/$jobname.jar --server=127.0.0.1 --server.port=$portnum --spring.profiles.active=$active > ${job_dir}/$active-$jobname.out 2>&1 &
		echo "nohup ${java_home} -jar ${job_dir}/$jobname.jar --server=127.0.0.1 --server.port=$portnum --spring.profiles.active=$active > ${job_dir}/$active-$jobname.out 2>&1 &"
		sleep 120
	;;
	'wx')
		date_str=$(date +%Y%m%d-%H%M%S)
		nohup ${java_home} -jar ${job_dir}/$jobname.jar --server=127.0.0.1 --server.port=$portnum --spring.profiles.active=$active > ${job_dir}/$active-$jobname.out 2>&1 &
		echo "nohup ${java_home} -jar ${job_dir}/$jobname.jar --server=127.0.0.1 --server.port=$portnum --spring.profiles.active=$active > ${job_dir}/$active-$jobname.out 2>&1 &"
		sleep 120
	;;
	'cloud'|'cloud-1'|'cloud-2'|'cloud-3')
		date_str=$(date +%Y%m%d-%H%M%S)
		nohup ${java_home} -jar ${job_dir}/$jobname.jar --server=0.0.0.0 --server.port=$portnum --spring.profiles.active=$active > ${job_dir}/$active-$jobname.out 2>&1 &
		echo "nohup ${java_home} -jar ${job_dir}/$jobname.jar --server=0.0.0.0 --server.port=$portnum --spring.profiles.active=$active > ${job_dir}/$active-$jobname.out 2>&1 &"
		sleep 120
	;;
	'config'|'config-1'|'config-2'|'config-3')
		date_str=$(date +%Y%m%d-%H%M%S)
		nohup ${java_home} -jar ${job_dir}/$jobname.jar --server=0.0.0.0 --server.port=$portnum --spring.profiles.active=$active,jdbc > ${job_dir}/$active-$jobname.out 2>&1 &
		echo "nohup ${java_home} -jar ${job_dir}/$jobname.jar --server=0.0.0.0 --server.port=$portnum --spring.profiles.active=$active,jdbc > ${job_dir}/$active-$jobname.out 2>&1 &"
		sleep 120
	;;
	'api'|'api-1'|'api-2'|'api-3')
		date_str=$(date +%Y%m%d-%H%M%S)
		nohup ${java_home} -jar ${job_dir}/$jobname.jar --server=0.0.0.0 --server.port=$portnum --spring.profiles.active=$active > ${job_dir}/$active-$jobname.out 2>&1 &
		echo "nohup ${java_home} -jar ${job_dir}/$jobname.jar --server=0.0.0.0 --server.port=$portnum --spring.profiles.active=$active > ${job_dir}/$active-$jobname.out 2>&1 &"
		sleep 120
	;;
	*)
		ERROR_INFO
	;;
	esac
}
# 运行状态复查
RUN_CHECK(){
	echo "6.检测启动状态"
	job_pid=$(netstat -ntlp | grep -v grep | grep $portnum | awk '{print $7}' | awk -F"/" '{ print $1 }')
	if [ ${job_pid} ]; then
		job_etime=$(ps -eo pid,lstart,etime | grep $job_pid | awk '{print $7}')
		job_etime_array=(${job_etime//:/ })
		echo "-----检测到进程存在，PID是${job_pid}，持续时间${job_etime}-----"
		if [ ${job_etime_array[2]} ] || [ ${job_etime_array[0]} -gt 3 ];then
			echo "-----存在旧版本进程没有杀死，重新杀死进程并重新启动...-----"
			KILL_JOB
			RUN_JOB
			RUN_CHECK
		else if [ -z ${job_etime_array[2]} ] && [ ${job_etime_array[0]} -le 3 ];then
			echo "-----检测完成，启动正确!-----"
		fi
	else
		echo "-----端口${portnum}未在监听，再次尝试启动进程...-----"
		RUN_JOB
		RUN_CHECK
	fi
}
# cms前端静态文件替换 
CMSWEB(){
	echo -e "当前时间：`date` \n${date_str}\n1.接收构建包:\n$(stat ${jenkins_dir}/dist.tar.gz)"
	mv ${job_dir}/dist ${backup_dir}/dist-${date_str}
	echo -e "2.备份旧版本信息：\n${backup_dir}/dist-${date_str}\n$(ls -l ${backup_dir}/dist-${date_str})"
	echo -e "3.解压上线新版静态文件\n"
	tar xzvf ${jenkins_dir}/dist.tar.gz -C ${job_dir}/
	echo -e "4.查看目录确认\nls -l ${job_dir}/dist\n$(ls -l ${job_dir}/dist)"
}

# java项目
JAVA_JOB(){
	# 替换文件
    FILE_MANAGE
	# 杀死守护进程
	KILL_FOREVER
	# 杀死java项目进程
	KILL_JOB
	# 启动java项目
	RUN_JOB
	# 检查启动状态
	RUN_CHECK
	# 返回成功
	SUCCESS_INFO
}
#从这里开始
JOB_START(){
	printf "项目：${jobname}，端口：${portnum} \n"
	# 变量初始化
	VAR_INIT
	# 根据项目区分
	case $jobname in
	'cmsweb')
		CMSWEB
	;;
	'cms'|'qc'|'wx'|'cloud'|'cloud-1'|'cloud-2'|'cloud-3'|'config'|'config-1'|'config-2'|'config-3'|'api'|'api-1'|'api-2'|'api-3')
		JAVA_JOB
	;;
	*)
		ERROR_INFO
	;;
	esac
}

# 启动
echo -e "开始远程自动部署"
JOB_START
