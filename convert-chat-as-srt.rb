#!/usr/bin/env ruby -wU

require 'json'
require 'time'

# example of usage:
#./convert-chat-as-srt.rb DATA/CHATS/films018-chat.json -1000

def format_timestamp(timestamp, delay=0)
  if timestamp.nil?
    return ""
  else
    ts = timestamp + delay
    return Time.at(ts / 1000, ts % 1000 * 1000).strftime("%H:%M:%S,%L")
  end
end

if ARGV.size == 0
  puts "usage: convert-chat-as-srt chat_file [ delay_in_ms ]"
  Process.exit(0)
else
  chat_file = ARGV[0]
  delay = ARGV[1].to_i
end

messages = []
File.open(chat_file, "r") do |inFile|
  while (line = inFile.gets())
    o = JSON.parse(line)

    o["data"].each do |msg|
      messages << msg
    end
  end
end


# This generate the same output as ./pretty-chat.js 
# (except username maybe)
#
# messages.each do |msg| 
#   puts '[' + format_timestamp(msg['time']) + '] ' + msg['userName'] + ':> ' + msg['text'] # msg['userId']
# end

counter = 1
messages.each do |msg| 
  puts counter
  startTime = msg['time']
  if counter < messages.size
     endTime = messages[counter]['time']
  else
     endTime = startTime + 10 * 1000 # last message will remain for 10 sec.  
  end
  puts format_timestamp(startTime, delay) + ' --> ' + format_timestamp(endTime, delay)
  puts msg['userName'] + ':> ' + msg['text']
  counter = counter + 1
  puts
end





