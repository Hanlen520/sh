kill_foever(){
	kill -9 $(ps -ef | grep "publish.sh" | awk '{print $2}')
}
