#!/bin/bash
kill_foever(){
	job_pid=$(netstat -ntlp | grep $portnum | awk '{print $7}' | awk -F"/" '{ print $1 }')
	if [ ${job_pid} ]
	then
		kill -9 ${job_pid}
		sleep 5
	fi
}
kill_foever