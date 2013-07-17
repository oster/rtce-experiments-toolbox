#!/usr/bin/env ruby -wU

require 'time'
require 'json'

# example of usage:
# ./resynch-and-convert-chat-srt.rb films017 sorting-synching/etherpad.log a.GXaGD5oiTgPmEMN5 35000 > VIDEOS_PROCESSING/20130528-1022-G17-EXP2-USER3-screencast.webm.srt

def format_timestamp(timestamp, delay=0)
  if timestamp.nil?
    return ""
  else
    ts = timestamp + delay
    return Time.at(ts / 1000, ts % 1000 * 1000).strftime("%H:%M:%S,%L")
  end
end

# def computeTimeDelays(etherpad_log_file, padid)
#   uids = {}
#   File.open(etherpad_log_file, "r") do |logFile|
#     while (line = logFile.gets())
#       if /"padid":"#{padid}"/.match(line) && /"type":"USER_CHANGES"/.match(line)      
#         m = /\[32m\[(.*)\] \[INFO.*"userId":("[a-zA-Z0-9.]*").*"timestamp":([0-9]*)/.match(line)
#         if ! m.nil?
#           uid = m[2][1..-2] # to strip \" characters
#           
#           if ! uids[uid]            
#             serverTime = Time.strptime(m[1], '%Y-%m-%d %H:%M:%S.%L')
#             clientTimestamp = m[3].to_i
#             clientTime = Time.at(clientTimestamp / 1000, clientTimestamp % 1000 * 1000)
#             deltaToAddToClient = serverTime - clientTime
#             uids[uid] = [ serverTime, clientTime, deltaToAddToClient ]
#             #uids[uid] = deltaToAddToClient
#           end    
#         end
#       end
#     end  
#   end
#   return uids
# end

if ARGV.size < 2
  puts "usage: resynch-and-convert-chat-srt pad_id etherpad_log [user_id delay_in_ms]"
  Process.exit(0)
else
  padid = ARGV[0]
#  etherpad_log_file = ARGV[1]
#  userid = ARGV[2]
  delay = ARGV[3]
end


chat_file = "DATA/CHATS/#{padid}-chat.json"

messages = []
File.open(chat_file, "r") do |inFile|
  while (line = inFile.gets())
    o = JSON.parse(line)

    o["data"].each do |msg|
      messages << msg
    end

  end
end


first_message_time = messages[0]['time'].to_i # 1369729338902

# because chat message are already timestamped with server time !!!!
#
# delays = computeTimeDelays(etherpad_log_file, padid) # compute delay to apply to client time to get server time
# delay_to_apply_in_ms = delays[userid][2] * 1000.0
# if ! delay.nil?
#   delay_to_apply_in_ms = delay_to_apply_in_ms + delay.to_i
# end

delay_to_apply_in_ms = delay.to_i - (first_message_time + 3600000)




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
  puts format_timestamp(startTime, delay_to_apply_in_ms) + ' --> ' + format_timestamp(endTime, delay_to_apply_in_ms)
  puts msg['userName'] + ':> ' + msg['text']
  counter = counter + 1
  puts
end











# cmdline = "./convert-chat-as-srt.rb #{chat_file} #{delay_to_apply_in_ms}"
# 
# output = []
# IO.popen(cmdline).each do |line|
#   output << line.chomp
# end
# 
# puts output
# 
# 
# 

