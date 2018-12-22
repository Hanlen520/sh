#!/bin/bash
kill_foever(){
	job_pid=$(ps -ef | grep publish.sh | awk '{print $2}')
	if [ ${job_pid} ]
	then
		kill -9 ${job_pid}
		sleep 5
	fi
}
kill_foever