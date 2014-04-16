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

# NOTE: works only for experiments from 006 to 010
css = loadChangeSets("tmp/dirtyCS.db", padid)
resynchTimestamps(css, delays)

# NOTE: use this for previous experiments (from 001 to 005)
#css = loadChangeSetsFromServerDB("tmp/dirty.db", padid)

# TODO: decode changeset information!!!
export_as_csv(css, "tmp/#{padid}.csv")
#export_as_csv(css, "tmp/#{padid}-server.csv")

Process.exit(0)



# filter events without timestamp
# css = css.select { |cs| cs.timestamp? }

# filter server events
css = css.select { |cs| cs.userid > 0} 

# filter events that happened too early (regarding standard deviation)
mints = css.map { |cs| cs.timestamp }.min
tss = css.map { |cs| cs.timestamp - mints }
dev =  tss.standard_deviation
css = css.select { |cs| cs.timestamp > mints + dev } 
tss = nil # dirty hack

# dump changesets 
# mints = css.map { |cs| cs.timestamp }.min
# css.each { |cs| 
#   puts "%2d, %s, %s" % [ cs.userid, cs.timestamp, format_timestamp(cs.timestamp, mints) ]
# }

# ...
# plot histogram of frequency of changes + standard deviation
# ...

mints = css.map { |cs| cs.timestamp }.min
maxts = css.map { |cs| cs.timestamp }.max
delta = 20000 # 20s

#(1..4).each do |uid|
#  histo = Array.new((maxts-mints) / delta + 1, 0)
#  tss = css.select { |cs| cs.userid == uid }.map { |cs| cs.timestamp - mints }

histo = Array.new((maxts-mints) / delta + 1, 0)
tss = css.map { |cs| cs.timestamp - mints }

  tss.each { |ts| 
    index = ts / delta
    histo[index] += 1
  }
  
  std = histo.standard_deviation

  Gnuplot.open do |gp|
    Gnuplot::Plot.new( gp ) do |plot|
      plot.style "fill solid 0.3"
      plot.ylabel "Frequency"
      plot.xlabel "Time"
      plot.tics "out nomirror"
      #plot.title "User #{uid}"
      plot.title "#{padid}"
     
      x = (0..histo.size-1).collect { |v| v }
      y = histo 
      
      plot.data = [
        Gnuplot::DataSet.new( [x, y] ) { |ds|
          ds.using = "2:xtic(1)"
          ds.notitle
          ds.with = "boxes"
        },
       
        Gnuplot::DataSet.new( "#{std}" ) { |ds|
          ds.with = "lines"
          ds.linewidth = 2
        }   
      ]
    end
  end
# end



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

