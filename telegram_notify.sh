#! /bin/bash

token="123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11" # Replace it with your bot token
msg="$1"

show_usage() {
	local cmd=`basename $0`
	cat << EOF

USAGE: $cmd <MESSAGE>

NOTE: Please refer to the following guide to create a new bot and generate an authentication token for your new bot.
      https://core.telegram.org/bots/features#botfather

EOF
}

invoke_api() {
	local text="$1"
	local return=`curl --silent --request GET "https://api.telegram.org/bot${token}/getUpdates?limit=1"`

	local chk_return=`echo "${return}" | tr ',' '\n' | head -n 1 | grep -w "ok.*true" | wc -l`
	if [ "$chk_return" = "0" ]; then
		echo "Token is invalid"
		exit 1
	elif [ "$chk_return" = "1" ]; then
		local chat_id=`echo ${return} | tr ',' '\n' | grep -w "chat.*id" | awk -F ':' '{print $3}'`
		curl --silent --request POST "https://api.telegram.org/bot${token}/sendMessage?chat_id=${chat_id}\&text=${text}" 1>/dev/null
	fi
}

send_message() {
	if [ "$token" = "" ]; then
		echo "ERROR: Token is null"
		show_usage
		exit 1
	fi

	if [ "${msg}" = "" ]; then
		show_usage
		exit 1
	fi

	invoke_api "${msg}"
}

send_message
