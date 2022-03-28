#!/bin/bash
# ================================================================================
# slot_machine.sh
# ================================================================================
#                          A mad science experiment
#                                 by Squish
# ________________________________________________________________________________
# 						⢀⣠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⣠⣤⣶⣶
# 						⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⢰⣿⣿⣿⣿
# 						⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⣀⣀⣾⣿⣿⣿⣿
# 						⣿⣿⣿⣿⣿⡏⠉⠛⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣿
# 						⣿⣿⣿⣿⣿⣿⠀⠀⠀⠈⠛⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠛⠉⠁⠀⣿
# 						⣿⣿⣿⣿⣿⣿⣧⡀⠀⠀⠀⠀⠙⠿⠿⠿⠻⠿⠿⠟⠿⠛⠉⠀⠀⠀⠀⠀⣸⣿
# 						⣿⣿⣿⣿⣿⣿⣿⣷⣄⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⣿
# 						⣿⣿⣿⣿⣿⣿⣿⣿⣿⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⣴⣿⣿⣿⣿
# 						⣿⣿⣿⣿⣿⣿⣿⣿⡟⠀⠀⢰⣹⡆⠀⠀⠀⠀⠀⠀⣭⣷⠀⠀⠀⠸⣿⣿⣿⣿
# 						⣿⣿⣿⣿⣿⣿⣿⣿⠃⠀⠀⠈⠉⠀⠀⠤⠄⠀⠀⠀⠉⠁⠀⠀⠀⠀⢿⣿⣿⣿
# 						⣿⣿⣿⣿⣿⣿⣿⣿⢾⣿⣷⠀⠀⠀⠀⡠⠤⢄⠀⠀⠀⠠⣿⣿⣷⠀⢸⣿⣿⣿
# 						⣿⣿⣿⣿⣿⣿⣿⣿⡀⠉⠀⠀⠀⠀⠀⢄⠀⢀⠀⠀⠀⠀⠉⠉⠁⠀⠀⣿⣿⣿
# 						⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣿⣿
# 						⣿⣿⣿⣿⣿⣿⣿⣿⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿
# --------------------------------------------------------------------------------
# Monitor patreon for available limited tier slots, and send a notification with
# a subscription link if free slots are detected.
#
# The code is parametized so can be applied to any patreon tier for any creator.
#
# Requirements:
# - htmlq
# - jq
# - notify-send
# - patience
# --------------------------------------------------------------------------------

function check_and_notify_slots {

	patreonUser="$1"
	tierId="$2"
	description="$3"
	sendNotification="$4"
	sendText="$5"
	textNumber="$6"
	textBeltKey="$7"

	# scrape the membership page
	curl -s "https://www.patreon.com/${patreonUser}/membership" | htmlq -t script > out.txt

	# extract the data part necessary for checking tiers
	lines=`wc -l out.txt | awk '{print $1}'`
	start_line=`grep -nF "Object.assign(window.patreon.bootstrap" out.txt | awk -F":" '{print $1}'`
	tail_lines=$(expr $lines - $start_line)
	end_line=$( expr `tail -n ${tail_lines} out.txt | grep -nF "});" | head -n 1 | awk -F":" '{print $1}'` - 1)

	# Build the output for jq to look at...
	echo "{" > out2.txt
	cat out.txt | tail -n ${tail_lines} | head -n ${end_line} >> out2.txt
	echo "}" >> out2.txt

	# extract the number of open brain board slots
	bb_slots=$(cat out2.txt | jq ".campaign.included[] | select( .id | contains(\"${tierId}\") ) | .attributes.remaining" | head -1)

	# simple shell output
	echo "The $description tier has $bb_slots slots."

	if [ $bb_slots -gt 0 ]; then
		if [ "$sendNotification" = "true" ]; then
			notify-send -u critical -t 30000 -i $PWD/icon.png -a "Discord" -c "alert" "$description Poller" "There are $bb_slots slot(s) open on the $description tier: \nhttps://patreon.com/join/$patreonUser/checkout?rid=$tierId"
		fi
		if [ "$sendText" = "true" ]; then
			send_text "$textNumber" "$textBeltKey" "$description tier open ($bb_slots free)."
		fi
	fi

}

function send_text {
	number="$1"
	key="$2"
	body="$3"

	curl -X POST https://textbelt.com/text \
		 --data-urlencode phone="$number" \
		 --data-urlencode message="$body" \
		 -d key="$key"
}

function read_config {
	cfg="./config.json"
	if [ ! -f "${cfg}" ]; then
		echo "No ${cfg}. Please create this file here."
		exit 0
	fi

	export CREATOR=$(cat ${cfg} | jq -r '.creator')
	export TIER_ID=$(cat ${cfg} | jq -r '.tierId')
	export DESCRIPTION=$(cat ${cfg} | jq -r '.description')
	export INTERVAL=$(cat ${cfg} | jq -r '.interval')
	export SEND_TEXT=$(cat ${cfg} | jq -r '.sendText')
	export SEND_NOTIFY=$(cat ${cfg} | jq -r '.sendNotification')
	export TEXT_NUMBER=$(cat ${cfg} | jq -r '.textNumber')
	export TEXT_KEY=$(cat ${cfg} | jq -r '.textBeltKey')

	echo "Creator : $CREATOR"
	echo "Tier    : $TIER_ID"
	echo "Desc    : $DESCRIPTION"
	echo "Interval: $INTERVAL"
	echo "Text?   : $SEND_TEXT"
	echo "Notify? : $SEND_NOTIFY"
	echo "Number  : $TEXT_NUMBER"
	echo "Key     : $TEXT_KEY"
}

read_config

while true
do
	check_and_notify_slots "$CREATOR" "$TIER_ID" "$DESCRIPTION" "$SEND_NOTIFY" "$SEND_TEXT" "$TEXT_NUMBER" "$TEXT_KEY"
	sleep $INTERVAL
done
