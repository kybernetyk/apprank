#!/bin/sh
while true; do
	date
	ruby main.rb &
	date
	sleep 3600
done
