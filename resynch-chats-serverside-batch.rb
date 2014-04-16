#!/usr/bin/env ruby -wU


require_relative 'Delays'

data = Delays.values()

#[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 13, 14, 16, 17, 18, 19, 20, 21, 25].each do |group|
[10].each do |group|
  [:films].each do |experiment|
  #[:corrections, :films].each do |experiment|
            
    if group == 14 && experiment == :films then num = 15 else num = group end  # to fix group number for bad experimentation
    #num = group
    num =  "%03d" % num     # group number
    uid = data[group][experiment][:userid]       # id of user who performed the first modification
    tstamp = data[group][experiment][:timestamp] # timestamp (server time) of the first modification
    #logfile = "/tmp/#{experiment}-syncing-#{duration}mn.log"
       
    #system "./resynch-changes-to-get-revision-serverside.rb #{experiment}#{num} DATA-by-num/#{num}/etherpad.log.gz DATA-by-num/#{num}/dirtyCS.db.gz DATA-by-num/#{num}/dirty.db.gz #{uid} #{tstamp} #{duration} >> #{logfile}"
    #system "echo === >> #{logfile}"
    
    outputfile = "sorting/DATA/#{experiment}#{num}_chat.srt"
    
    puts "#{experiment}#{num}:"
    
    puts "tstamp: #{tstamp}"
    
    system "./resynch-and-pretty-chat.rb #{num} #{experiment}#{num} #{tstamp} >> #{outputfile}"
  end
end
