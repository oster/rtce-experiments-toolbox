#! /bin/bash

cat DATA-chat-word-counts/films*.csv | cut -d ',' -f 1,1  | sort -k 1 | uniq | sed 's/"//g'