kill_foever(){
	kill -9 $(ps -ef | grep "publish.sh" | awk '{print $2}')
	sleep 5
}
kill_foever