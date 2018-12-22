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
	echo "${jobname}更新成功!!!!!!!!!!!!!"
	printf "%-16s %-16s %-16s %-16s %-16s\n" 项目 端口 CASE 日期 时间
	printf "%-16s %-16s %-16s %-16s %-16s\n" $jobname $portnum $whichone `date '+%Y-%m-%d %H:%M:%S'`
	echo "##########   查看日志： http://showlog.dev.qiancangkeji.cn/   ##########"
}
#错误信息
error_info(){
	printf "错误${jobname} !!!!!!!!!!!!!\n"
	printf "%-16s %-16s %-16s\n" 项目 日期 时间
	printf "%-16s %-16s %-16s\n" 错误$jobname `date '+%Y-%m-%d %H:%M:%S'`
}

#文件管理
file_manage(){
	#目录初始化，已存在则忽略，不存在则创建
	mkdir -p ${job_dir}
	mkdir -p ${backup_dir}/${date_str}
	echo -e "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n已接收jenkins远程传输包：\n$(stat ${jenkins_dir}/*.jar)\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"

	mv ${job_dir}/${jobname}.jar ${job_dir}/${active}-${jobname}-${date_str}.jar &&
	mv ${job_dir}/${active}-${jobname}.out ${job_dir}/${active}-${jobname}-${date_str}.out &&
	mv ${job_dir}/* ${backup_dir}/${date_str}/ &&
	echo -e "1.旧版jar及日志备份，成功：\n"ls -l ${backup_dir}/${date_str}/"\n`ls -l ${backup_dir}/${date_str}/*`"
	cp ${jenkins_dir}/*.jar ${job_dir}/${jobname}.jar && 
	echo "2.替换新版jar包，成功：${job_dir}/${jobname}.jar"
	rm -rf ${jenkins_dir}/*
	echo -e "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n更新包信息:\n$(stat ${job_dir}/$jobname.jar)\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
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
		echo "再杀一次，应返回：“No such process！” 或 “没有那个进程” "
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
		echo "6.准备启动${job_dir}/${jobname}.jar，端口${portnum}"
		date_str=$(date +%Y%m%d-%H%M%S)
		nohup ${java_home} -jar ${job_dir}/$jobname.jar --server=127.0.0.1 --server.port=$portnum --spring.profiles.active=$active > ${job_dir}/$active-$jobname.out 2>&1 &
		echo "nohup ${java_home} -jar ${job_dir}/$jobname.jar --server=127.0.0.1 --server.port=$portnum --spring.profiles.active=$active > ${job_dir}/$active-$jobname.out 2>&1 &"
		sleep 120
	;;
	'qc')
		echo "6.准备启动${job_dir}/${jobname}.jar，端口${portnum}"
		date_str=$(date +%Y%m%d-%H%M%S)
		nohup ${java_home} -jar ${job_dir}/$jobname.jar --server=127.0.0.1 --server.port=$portnum --spring.profiles.active=$active > ${job_dir}/$active-$jobname.out 2>&1 &
		echo "nohup ${java_home} -jar ${job_dir}/$jobname.jar --server=127.0.0.1 --server.port=$portnum --spring.profiles.active=$active > ${job_dir}/$active-$jobname.out 2>&1 &"
		sleep 120
	;;
	'wx')
		echo "6.准备启动${job_dir}/${jobname}.jar，端口${portnum}"
		date_str=$(date +%Y%m%d-%H%M%S)
		nohup ${java_home} -jar ${job_dir}/$jobname.jar --server=127.0.0.1 --server.port=$portnum --spring.profiles.active=$active > ${job_dir}/$active-$jobname.out 2>&1 &
		echo "nohup ${java_home} -jar ${job_dir}/$jobname.jar --server=127.0.0.1 --server.port=$portnum --spring.profiles.active=$active > ${job_dir}/$active-$jobname.out 2>&1 &"
		sleep 120
	;;
	'cloud'|'cloud-1'|'cloud-2'|'cloud-3')
		echo "6.准备启动${job_dir}/${jobname}.jar，端口${portnum}"
		date_str=$(date +%Y%m%d-%H%M%S)
		nohup ${java_home} -jar ${job_dir}/$jobname.jar --server=0.0.0.0 --server.port=$portnum --spring.profiles.active=$active > ${job_dir}/$active-$jobname.out 2>&1 &
		echo "nohup ${java_home} -jar ${job_dir}/$jobname.jar --server=0.0.0.0 --server.port=$portnum --spring.profiles.active=$active > ${job_dir}/$active-$jobname.out 2>&1 &"
		sleep 120
	;;
	'config'|'config-1'|'config-2'|'config-3')
		echo "6.准备启动${job_dir}/${jobname}.jar，端口${portnum}"
		date_str=$(date +%Y%m%d-%H%M%S)
		nohup ${java_home} -jar ${job_dir}/$jobname.jar --server=0.0.0.0 --server.port=$portnum --spring.profiles.active=$active,jdbc > ${job_dir}/$active-$jobname.out 2>&1 &
		echo "nohup ${java_home} -jar ${job_dir}/$jobname.jar --server=0.0.0.0 --server.port=$portnum --spring.profiles.active=$active,jdbc > ${job_dir}/$active-$jobname.out 2>&1 &"
		sleep 120
	;;
	'api'|'api-1'|'api-2'|'api-3')
		echo "6.准备启动${job_dir}/${jobname}.jar，端口${portnum}"
		date_str=$(date +%Y%m%d-%H%M%S)
		nohup ${java_home} -jar ${job_dir}/$jobname.jar --server=0.0.0.0 --server.port=$portnum --spring.profiles.active=$active > ${job_dir}/$active-$jobname.out 2>&1 &
		echo "nohup ${java_home} -jar ${job_dir}/$jobname.jar --server=0.0.0.0 --server.port=$portnum --spring.profiles.active=$active > ${job_dir}/$active-$jobname.out 2>&1 &"
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

# 端口守护
forever(){
	while true
	do
	sleep 300
	date_str=$(date +%Y%m%d-%H%M%S)
	# 获取端口的进程号
	job_pid=$(netstat -ntlp | grep $port_num | awk '{print $7}' | awk -F"/" '{ print $1 }')
	echo "${date_str}------------进程号${pid}---------------"
	# 如果进程号为空，重启服务
	if [ "${pid}"=="" ] 
	then
	echo "ERROR>>>>>>>>>>>>>>>>>>>>>检测不到端口，准备再次检测"
	check_job
	fi
	done
}

# cms前端静态文件替换 
cmsweb(){
	echo -e "当前时间：`date` \n${date_str}\n1.接收构建包:\n$(stat ${jenkins_dir}/dist.tar.gz)"
	mv ${job_dir}/dist ${backup_dir}/dist-${date_str}
	echo -e "2.备份旧版本信息：\n${backup_dir}/dist-${date_str}\n$(ls -l ${backup_dir}/dist-${date_str})"
	echo -e "3.解压上线新版静态文件\n"
	tar xzvf ${jenkins_dir}/dist.tar.gz -C ${job_dir}/
	echo -e "4.查看目录确认\nls -l ${job_dir}/dist\n$(ls -l ${job_dir}/dist)"
}
# java项目
java_job(){
    file_manage
	kill_job
	run_job
	check_job
	success_info
}
# 初始化变量
var_init(){
	date_str=$(date +%Y%m%d-%H%M%S)
	jenkins_dir=/website/jenkins/${jobname}
	job_dir=/website/${whichone}/${jobname}
	backup_dir=/website/backup/${jobname}
	java_home=/usr/local/java/jdk1.8.0_191/bin/java
}
#从这里开始
job_start(){
	var_init
	printf "项目：${jobname}，端口：${portnum} \n"
	case $jobname in
	'cmsweb')
		cmsweb
	;;
	'cms'|'qc'|'wx'|'cloud'|'cloud-1'|'cloud-2'|'cloud-3'|'config'|'config-1'|'config-2'|'config-3'|'api'|'api-1'|'api-2'|'api-3')
		java_job
	;;
	*)
		error_info
	;;
	esac
}

# 启动
job_start

