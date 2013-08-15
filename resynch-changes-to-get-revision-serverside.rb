#!/usr/bin/env ruby -wU

require_relative 'ChangeSet'

## require 'time'
## require 'json'
require 'zlib'

# example of usage:

# ./resynch-changes-to-get-revision.rb films017 sorting-synching/etherpad.log.gz sorting-synching/dirtyCS.db.gz sorting-synching/dirty.db.gz a.GXaGD5oiTgPmEMN5 1369722157631
#     VIDEOS_PROCESSING/20130528-1022-G17-EXP2-USER3-screencast.webm.srt

## class ChangeSet
## 
## def format_timestamp(timestamp, delay=0)
##   if timestamp.nil?
##     return ""
##   else
##     ts = timestamp + delay
##     return Time.at(ts / 1000, ts % 1000 * 1000).strftime("%H:%M:%S,%L")
##   end
## end
## 
## def resynchTimestamps(changesets, delays)
##   changesets.each do |cs|
##     if (! cs.timestamp.nil? && cs.userid > 0) 
##       struid = ChangeSet.userids.key(cs.userid)
##       delayForThisUser = delays[struid]
## #      delayForThisUser = delays[%Q["#{struid}"]]
##       newtimestamp = Time.at(cs.timestamp / 1000, cs.timestamp % 1000 * 1000)
##       newtimestamp += delayForThisUser[2]
##       cs.timestamp = newtimestamp.strftime("%s%L").to_i      
##     end
##   end  
## end
## 
## def computeTimeDelays(etherpad_log_file, padid)
##   uids = {}
## #  File.open(etherpad_log_file, "r") do |logFile|
##   Zlib::GzipReader.open(etherpad_log_file) do |logFile|  
##     while (line = logFile.gets())
##       if /"padid":"#{padid}"/.match(line) && /"type":"USER_CHANGES"/.match(line)      
##         m = /\[32m\[(.*)\] \[INFO.*"userId":("[a-zA-Z0-9.]*").*"timestamp":([0-9]*)/.match(line)
##         if ! m.nil?
##           uid = m[2][1..-2] # to strip \" characters
##           
##           if ! uids[uid]            
##             serverTime = Time.strptime(m[1], '%Y-%m-%d %H:%M:%S.%L')
##             clientTimestamp = m[3].to_i
##             clientTime = Time.at(clientTimestamp / 1000, clientTimestamp % 1000 * 1000)
##             deltaToAddToClient = serverTime - clientTime
##             uids[uid] = [ serverTime, clientTime, deltaToAddToClient ]
##             #uids[uid] = deltaToAddToClient
##           end    
##         end
##       end
##     end  
##   end
##   return uids
## end
## 
## 
## end



# ./resynch-changes-to-get-revision.rb films017 sorting-synching/etherpad.log.gz sorting-synching/dirtyCS.db.gz sorting-synching/dirty.db.gz a.GXaGD5oiTgPmEMN5 1369722157631 9




if ARGV.size < 6
  puts "usage: resynch-changes-to-video pad_id etherpad_log changesetDB padDB user_id first_changes_timestamp expected_duration_in_mn"
  Process.exit(0)
else
  padid = ARGV[0]
  etherpad_log_file = ARGV[1]
  changeset_file = ARGV[2]
  db_file = ARGV[3]
  userid = ARGV[4]
  first_changes_timestamp = ARGV[5].to_i
  expected_duration_in_mn = ARGV[6].to_i
end


#delays = computeTimeDelays(etherpad_log_file, padid) # compute delay to apply to client time to get server time
#css = loadChangeSets(changeset_file, padid)
css = loadChangeSetsFromServerDB(db_file, padid)
#resynchTimestamps(css, delays) # now all changes are timestamped according to server time

# css = css.select { |item| ChangeSet.userids.key(item.userid) == userid && item.type != :unknown }

# puts "changes count for user #{userid}: #{css.size}"

first_cs = css.select { |item| item.timestamp == first_changes_timestamp }[0]

puts "= first changes"
puts "user: #{userid}"
puts "time: #{format_timestamp(first_cs.timestamp)} (#{first_cs.timestamp})"
puts "changes: #{first_cs.inspect}"

#expected_duration_in_mn = 9
expected_duration_in_s = expected_duration_in_mn * 60

last_timestamp = first_cs.timestamp
last_timestamp = last_timestamp + expected_duration_in_s * 1000


puts "= expected timestamp"
puts "time: #{format_timestamp(last_timestamp)} (#{last_timestamp})"

# last_cs = css.select { |cs| cs.timestamp >= last_timestamp && cs.type != :unknown }.min_by { |cs| cs.timestamp }
#last_cs = css.select { |cs| ! cs.timestamp.nil? && cs.timestamp >= last_timestamp && cs.type != :unknown }.min_by { |cs| cs.timestamp }
last_cs = css.select { |cs| ! cs.timestamp.nil? && cs.timestamp <= last_timestamp }.max_by { |cs| cs.timestamp }

puts "= nearest changes to expected cut point (#{expected_duration_in_mn}mn)"
puts "time: #{format_timestamp(last_cs.timestamp)} (#{last_cs.timestamp})"
puts "changes: #{last_cs.inspect}"

# css.each do |cs| 
#   puts "#{format_timestamp(cs.timestamp)}   #{cs.type}"
# end

#Process.exit(0)

revisions = loadPadRevisionsFromDB(db_file, padid)

#revisions.map { |rev| rev[:timestamp] = rev[:timestamp] - 2 * 3600000 + 2} # DIRTY_HACK: fix timezone difference + '2' for error corrections -- sometimes revision is stored before corresponding change was done

last_rev = revisions.select {|rev| rev[:timestamp] >= last_cs.timestamp }.min_by { |rev| rev[:timestamp] }

puts "= revision"
puts "time: #{format_timestamp(last_rev[:timestamp])} (#{last_rev[:timestamp]})"
puts "rev: #{last_rev[:rev]}"

output_file_basename = "./#{padid}-#{expected_duration_in_mn}mn"
output_dir = '/tmp/'

File.open(output_dir + '/' + output_file_basename + "-metadata.txt", 'w') do |output| 
  output.puts("# CAUTION: data are extracted from server log")
  output.puts("tstart:   #{format_timestamp(first_cs.timestamp)} (#{first_cs.timestamp})")
  output.puts("tcut:     #{format_timestamp(last_cs.timestamp)} (#{last_cs.timestamp})")
  output.puts("rev:      #{last_rev[:rev]}/#{revisions[-1][:rev]}")  
  output.puts("trev:     #{format_timestamp(last_rev[:timestamp])} (#{last_rev[:timestamp]})")
  output.puts("duration: #{format_timestamp(last_rev[:timestamp]-first_cs.timestamp-3600000)}")
end

# puts("tstart:   #{format_timestamp(first_cs.timestamp)} (#{first_cs.timestamp})")
# puts("tcut:     #{format_timestamp(last_cs.timestamp)} (#{last_cs.timestamp})")
# puts("rev:      #{last_rev[:rev]}/#{revisions[-1][:rev]}")  
# puts("trev:     #{format_timestamp(last_rev[:timestamp])} (#{last_rev[:timestamp]})")
# puts("duration: #{format_timestamp(last_rev[:timestamp]-first_cs.timestamp-3600000)}")

File.open(output_dir + '/' + output_file_basename + ".txt", 'w') do |output| 
  output.puts(last_rev[:content])
end
