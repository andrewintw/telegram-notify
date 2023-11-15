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
	local header="Content-Type: application/json"

	local return=`curl --silent --header "${header}" --data '{"limit":"1"}' --request GET https://api.telegram.org/bot${token}/getUpdates`
	if [ "`echo "${return}" | jq -r .ok`" = "false" ]; then
		echo "Token is invalid"
		exit 1
	elif [ "`echo "${return}" | jq -r .ok`" = "true" ]; then
		local chat_id=`echo ${return} | jq -r .result[0].message.chat.id`
		local data_json=$(jq -c --null-input \
					--arg chat_id "${chat_id}" \
					--arg text    "${text}" \
					'{"chat_id":$chat_id,
					  "text":$text}')
		return=`curl --silent --header "${header}" --request POST --data "${data_json}" https://api.telegram.org/bot${token}/sendMessage`
	fi
}

send_message() {
	if [ ! `command -v jq` ]; then
		echo 'WARN: please install jq: $ sudo apt install jq'
		exit 1
	fi

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
