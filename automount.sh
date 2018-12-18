#!/bin/bash
config(){
	#配置
	echo "LOCKD_TCPPORT=50001" >> /etc/sysconfig/nfs
	echo "LOCKD_UDPPORT=50001" >> /etc/sysconfig/nfs
	echo "MOUNTD_PORT=50002" >> /etc/sysconfig/nfs
	echo "STATD_PORT=50003" >> /etc/sysconfig/nfs
	echo "STATD_OUTGOING_PORT=50004" >> /etc/sysconfig/nfs
	#共享
	echo "/website/alpha 172.27.240.12 (ro sync)" > /etc/exports
	cat /etc/exports
	service nfs restart
	showmount -e
	}
test_server(){
	config
	#test1 cms cmsweb 
	172.27.0.10	
	#test2 qc wx
	172.27.0.2   
	}
prod_server(){
	config
	server2/cms/cmsweb
	172.27.0.6  
	server3/qcService/wxService
	172.27.0.15  
	Alen_1_cloud1_config1
	172.27.0.8  	
	Alen_2_config2_api1 
	172.27.0.16  	
	Alen_3_cloud2_api2
	172.27.0.17  	
	}
test_mount(){
	#172.27.240.12
	mount 172.27.0.10:/website/alpha/cms /website/logs/test/cms
	mount 172.27.0.10:/website/alpha/cmsweb /website/logs/test/cmsweb
	mount 172.27.0.2:/website/alpha/qc /website/logs/test/qc
	mount 172.27.0.2:/website/alpha/wx /website/logs/test/wx
	ln -sfn /website/alpha/cloud /website/logs/test/cloud
	ln -sfn /website/alpha/config /website/logs/test/config
	ln -sfn /website/alpha/api /website/logs/test/api
	}		
prod_mount(){
	#172.27.240.12
	mount 172.27.0.6:/website/alpha/cms /website/logs/prod/cms
	mount 172.27.0.6:/website/alpha/cmsweb /website/logs/prod/cmsweb
	mount 172.27.0.15:/website/alpha/qc /website/logs/prod/qc
	mount 172.27.0.15:/website/alpha/wx /website/logs/prod/wx
	mount 172.27.0.8:/website/alpha/cloud-1 /website/logs/prod/cloud-1
	mount 172.27.0.8:/website/alpha/config-1 /website/logs/prod/config-1
	mount 172.27.0.16:/website/alpha/api-1 /website/logs/prod/api-1
	mount 172.27.0.16:/website/alpha/config-2 /website/logs/prod/config-2
	mount 172.27.0.17:/website/alpha/api-2 /website/logs/prod/api-2
	mount 172.27.0.17:/website/alpha/cloud-2 /website/logs/prod/cloud-2
	}
#*.*.*.107 
#echo "/website/sh/automount.sh >/website/sh/automount.log 2>&1" >> /etc/rc.d/rc.local
#开机自动挂载日志目录
mount 172.27.0.10:/website/alpha/cms /website/logs/test/cms
mount 172.27.0.10:/website/alpha/cmsweb /website/logs/test/cmsweb
mount 172.27.0.2:/website/alpha/qc /website/logs/test/qc
mount 172.27.0.2:/website/alpha/wx /website/logs/test/wx
mount 172.27.0.6:/website/alpha/cms /website/logs/prod/cms
mount 172.27.0.6:/website/alpha/cmsweb /website/logs/prod/cmsweb
mount 172.27.0.15:/website/alpha/qc /website/logs/prod/qc
mount 172.27.0.15:/website/alpha/wx /website/logs/prod/wx
mount 172.27.0.8:/website/alpha/cloud-1 /website/logs/prod/cloud-1
mount 172.27.0.8:/website/alpha/config-1 /website/logs/prod/config-1
mount 172.27.0.16:/website/alpha/api-1 /website/logs/prod/api-1
mount 172.27.0.16:/website/alpha/config-2 /website/logs/prod/config-2
mount 172.27.0.17:/website/alpha/api-2 /website/logs/prod/api-2
mount 172.27.0.17:/website/alpha/cloud-2 /website/logs/prod/cloud-2
