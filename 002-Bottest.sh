#!/bin/bash

#Test script to try some different stuff.

Send()
{
	#oldMsgID
	oldMsgID=$msgID
	#echo oldMsgID: $msgID

	local messages=$(curl -s "https://api.groupme.com/v3/groups/<groupID>/messages?token=<botToken>&limit=1")
	#echo $messages | jq '.response.messages[]'

	local text1=$(echo $messages| jq '.response.messages[].text')
	#echo $text

	local user1=$(echo $messages| jq '.response.messages[].name')
	#echo $user

	msgID=$(echo $messages| jq '.response.messages[].id')
	#echo msgID: $msgID

	if [[ $oldMsgID == $msgID ]]
	then
		return
	fi

	curl -s -H "Authorization: Bearer A1b2C3" -H "Content-Type: application/json" http://192.168.1.40:4243/api/message -d"{\"text\":$text1,\"username\":$user1,\"gateway\":\"gateway4\"}" > out.log

}

Receve()
{
	local messages=$(curl -s -H "Authorization: Bearer A1b2C3" http://192.168.1.40:4243/api/messages)
	echo $messages
	if [[ $messages == "[]" ]]
	then
		return
	fi

	text=$(echo $messages| jq '.[].text')
	#echo $text

	protocol=$(echo $messages| jq '.[].protocol')
	#echo $protocol

	local user=$(echo $messages| jq '.[].username')
	#echo $user

	local text2=$(echo "[$protocol]<$user> $text")
	echo "message: $text2"
	echo
	echo

	curl -s -H "Content-Type: application/json" "https://api.groupme.com/v3/groups/65225076/messages?token=<botToken>" -d"{\"message\":{\"source_guid\":\"$(date +%s)\",\"text\":\$text2 \"}}"
}

Repeat()
{
	Send
	Receve
	sleep 5s
	Repeat
}

Repeat
