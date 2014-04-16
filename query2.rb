#!/usr/bin/env ruby -wU

#require 'gnuplot'
require_relative 'ChangeSet'

module Enumerable
  def sum
    return self.inject(0) { |accum, i| accum + i }
  end

  def mean
    return self.sum / self.length.to_f
  end

  def sample_variance
    m = self.mean
    sum = self.inject(0) { |accum, i| accum + (i - m) ** 2 }
    return sum / (self.length - 1).to_f
  end

  def standard_deviation
    return Math.sqrt(self.sample_variance)
  end
end

if ARGV.size == 0
  puts "usage: script pad_id"
  Process.exit(0)
else
  padid = ARGV[0]
end

delays = computeTimeDelays("tmp/etherpad.log", padid)
css = loadChangeSets("tmp/dirtyCS.db", padid)
resynchTimestamps(css, delays)


# filter events without timestamp
# css = css.select { |cs| cs.timestamp? }

# filter server events
css = css.select { |cs| cs.userid > 1 && cs.type != :unknown } 

clusters = []

tmp = css

while ! tmp.empty? do
  cluster = []  
  conc = tmp.select { |cs| cs.concurrent?(tmp[0]) }    
  conc.each { |a| tmp.delete(a) }
  cluster << conc
  clusters << cluster
end

num = 0
clusters.each do |c|
  num += 1
  if c[0].size > 1
    puts "Cluster #{num}:"
    c[0].each do |cs|
      puts "\t user #{cs.userid}"
      puts "\t line = #{cs.line}"
      puts "\t position = #{cs.position}"
      puts "\t deleted = #{cs.deleted}"
      puts "\t inserted = #{cs.inserted}"
      puts "\t type = #{cs.type}"
      puts "\t value = '#{cs.value}'"
      puts
    end
    puts  "--"
  end
end

puts clusters.size
puts clusters.flatten.size

Process.exit(0)



css.map do |c| 
  ts = c.timestamp
  css.select { |cs| (cs.timestamp - ts).abs < 10*1000 }.group_by(&:line).each do |line, set|
    if set.size > 1
      puts line
      puts set.inspect
    end

  end
end

Process.exit(0)






res = []
0.upto(css.size - 1) do |i|
  cs1 = css[i] 
  ress = []
  
  i.succ.upto(css.size - 1) do |j|    
    cs2 = css[j]
    
    # if cs1.userid != cs2.userid && cs1.line == cs2.line && (cs2.timestamp - cs1.timestamp) < 10*1000
    if cs1.userid != cs2.userid && (cs1.position - cs2.position).abs < 10 && (cs2.timestamp - cs1.timestamp) < 60*1000
      
      #puts cs1.userid
      #puts cs2.userid
      #puts cs1.line
      #puts cs2.line
      #puts cs2.timestamp
      #puts cs1.timestamp
      #Process.exit(0)
      
      ress << cs2      
    end
  end
  
  if ress.size > 0
    ress << cs1
    res << ress

    puts "line = #{cs1.line}"
    
    uids = [ ] 
    uids << ress.collect { |cs| cs.userid - 1 }
    uids.flatten!
    
    puts "users = #{uids} " 
    
    mints = ress.map { |cs| cs.timestamp }.min
    maxts = ress.map { |cs| cs.timestamp }.max
    
    mints_str = Time.at(mints / 1000, mints % 1000 * 1000).strftime("%H:%M:%S,%L")
    maxts_str = Time.at(maxts / 1000, maxts % 1000 * 1000).strftime("%H:%M:%S,%L")
    puts "time = %s %s " % [ mints_str, maxts_str ]
    
    puts "types = %s " % [ ress.map { |cs| cs.type } ] 
    puts "chars = %s " % [ ress.map { |cs| cs.value } ] 
  end
end

puts res.size


# filter events that happened too early (regarding standard deviation)
# mints = css.map { |cs| cs.timestamp }.min
# tss = css.map { |cs| cs.timestamp - mints }
# dev =  tss.standard_deviation
# css = css.select { |cs| cs.timestamp > mints + dev } 
# tss = nil # dirty hack

# dump changesets 
# mints = css.map { |cs| cs.timestamp }.min
# css.each { |cs| 
#   puts "%2d, %s, %s" % [ cs.userid, cs.timestamp, format_timestamp(cs.timestamp, mints) ]
# }

# ...
# plot histogram of frequency of changes + standard deviation
# ...

# mints = css.map { |cs| cs.timestamp }.min
# maxts = css.map { |cs| cs.timestamp }.max
# delta = 20000 # 20s

#(1..4).each do |uid|
#  histo = Array.new((maxts-mints) / delta + 1, 0)
#  tss = css.select { |cs| cs.userid == uid }.map { |cs| cs.timestamp - mints }

# histo = Array.new((maxts-mints) / delta + 1, 0)
# tss = css.map { |cs| cs.timestamp - mints }
# 
#   tss.each { |ts| 
#     index = ts / delta
#     histo[index] += 1
#   }
#   
#   std = histo.standard_deviation
# 
#   Gnuplot.open do |gp|
#     Gnuplot::Plot.new( gp ) do |plot|
#       plot.style "fill solid 0.3"
#       plot.ylabel "Frequency"
#       plot.xlabel "Time"
#       plot.tics "out nomirror"
#       #plot.title "User #{uid}"
#       plot.title "#{padid}"
#      
#       x = (0..histo.size-1).collect { |v| v }
#       y = histo 
#       
#       plot.data = [
#         Gnuplot::DataSet.new( [x, y] ) { |ds|
#           ds.using = "2:xtic(1)"
#           ds.notitle
#           ds.with = "boxes"
#         },
#        
#         Gnuplot::DataSet.new( "#{std}" ) { |ds|
#           ds.with = "lines"
#           ds.linewidth = 2
#         }   
#       ]
#     end
#   end
# # end



#serverTime = "2012-07-06 14:23:41.232" 
#t = Time.strptime(serverTime, '%Y-%m-%d %H:%M:%S.%L')
#puts serverTime
#puts t.strftime("%H:%M:%S.%L")
#puts t.strftime("%s%L")
#puts

#s = t.strftime("%s%L")
#clientTime = s.to_i
#clientTime = 1341602271896 

#t2 = Time.at(clientTime / 1000, clientTime % 1000 * 1000)
#clientTime = s
#t2 = Time.strptime(clientTime, "%s.%L")

#puts clientTime
#puts t2.strftime("%H:%M:%S.%L")
#puts t2.strftime("%s%L")

#Process.exit(0)

# puts "Experiments #{padid}"
# puts "==="
# 
# puts ChangeSet.userids
# 
# csTotalCount = css.select { |item| item.userid > 0 }.size
# csTotalLength = 0
# css.select { |item| item.userid > 0 }.collect { |cs| 
#    case cs.type
#      when :ins
#        csTotalLength += cs.inserted
#      when :del 
#        csTotalLength += cs.deleted
#      when :upd
#        csTotalLength += (cs.inserted-cs.deleted).abs
#    end
# }
 
# ChangeSet.userids.values.each do |uid|
#   csCount = css.select { |item| item.userid == uid }.size
# 
#   csLength = 0
#   css.select { |item| item.userid == uid }.collect { |cs| 
#     case cs.type
#       when :ins
#         csLength += cs.inserted
#       when :del 
#         csLength += cs.deleted
#       when :upd
#         csLength += (cs.inserted-cs.deleted).abs
#     end    
#   }
#   
#   puts "User #{uid}:" 
#   puts " %3d / %3d changesets (%2d%%)" % [ csCount, csTotalCount, (csCount*100)/csTotalCount ]
#   puts " %3d / %3d size of cs (%2d%%)" % [ csLength, csTotalLength, (csLength*100)/csTotalLength ]
# end  

#css.select { |cs| cs.userid > 0 && cs.timestamp? }.sort_by { |cs| cs.timestamp }.collect { |cs| 
#css.select { |cs| cs.userid > 0 }.collect { |cs| 
# ts = cs.timestamp
# puts "#{cs.userid}: #{format_timestamp(ts)}"
#}  


# ChangeSet.userids.values.each do |uid|
#   csCount = css.select { |item| item.userid == uid }.size
#   startTime = css.select { |cs| cs.userid == uid }[0].timestamp
#   endTime = css.select { |cs| cs.userid == uid }[csCount-1].timestamp
#   if (! startTime.nil?)
#     diffTime = endTime - startTime
#     puts "User #{uid}: "
#     
#     puts Time.at(startTime/1000)
#     
#     puts "#{format_timestamp(startTime)} -> #{format_timestamp(endTime)} (#{format_timestamp(diffTime)})"
#   end
# end

