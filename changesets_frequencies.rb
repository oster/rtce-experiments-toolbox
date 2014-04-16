#!/usr/bin/env ruby -U

require_relative 'ChangeSet'
require_relative "Delays"

data = Delays.values()



delta_tss_mins = []

#[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 13, 14, 16, 17, 18, 19, 20, 21, 25].each do |group|
#[5, 6, 7, 8, 9, 10, 12, 13, 14, 16, 17, 18, 19, 20, 21, 25].each do |group|
#[6, 7, 8, 9, 10, 12, 13, 14, 16, 17, 18, 19, 20, 21, 25].each do |group|
  [6].each do |group|
#  [:corrections, :films].each do |experiment|
  [:films].each do |experiment|
            
    if group == 14 && experiment == :films then num = 15 else num = group end  # to fix group number for bad experimentation

    num =  "%03d" % num     # group number
    delay = data[group][:delay]
    
    padid="#{experiment}#{num}"

    delays = computeTimeDelays("DATA-by-num/#{num}/etherpad.log.gz", padid)

    # NOTE: works only for experiments from 006 to 010
    #css = loadChangeSets("DATA-by-num/#{num}/dirtyCS.db.gz", padid)
    #resynchTimestamps(css, delays)
        
    css = loadChangeSetsFromServerDB("DATA-by-num/#{num}/dirty.db.gz", padid)
    mints = css.select { |cs| cs.timestamp? }.min_by { |cs| cs.timestamp }.timestamp
    
    
    delta_tss = []
    
    prev_cs = nil
    css.each do |cs| 
      if prev_cs == nil then
        prev_cs = cs
      else        
        delta_ts = (cs.timestamp - prev_cs.timestamp).abs                
        delta_tss << delta_ts
        prev_cs = cs
      end        
    end
    delta_tss_mins << delta_tss.min
  end
end    

puts delta_tss_mins.inspect

#puts delta_ts_mins.min
      
      
      
#    row = 0
#    col = 0
#    #["userid", "timestamp", "formatted-timestamp"].each do |v|
#    ["userid", "timestamp", "formatted-timestamp", "event-type", "position", "line", "column", "value", "inserted", "deleted"].each do |v|
#      worksheet.write(row, col, v)
#      col += 1
#    end
#    
#    row = 1
#    css.each do |cs| 
#      col = 0
#      #[cs.userid, cs.timestamp, format_timestamp(cs.timestamp, mints) ].each do |v|
#      [cs.userid, cs.timestamp, format_timestamp(cs.timestamp, mints), cs.type, cs.position, cs.line, cs.column, cs.value.nil? ? 0 : cs.value.size, cs.inserted, cs.deleted].each do |v|
#        worksheet.write(row, col, v)
#        col += 1  
#      end
#      row += 1
#    end
#    last_row = row - 1
#    
#  end
#  end


Process.exit(0)




m = /[a-z]*([0-9]*)/.match(padid)
if ! m.nil?
  num = m[1]
end

#delays = computeTimeDelays("tmp/etherpad.log", padid)
delays = computeTimeDelays("DATA-by-num/#{num}/etherpad.log.gz", padid)

# NOTE: works only for experiments from 006 to 010
css = loadChangeSets("DATA-by-num/#{num}/dirtyCS.db.gz", padid)
resynchTimestamps(css, delays)

# NOTE: use this for previous experiments (from 001 to 005)
#css = loadChangeSetsFromServerDB("tmp/dirty.db", padid)

# TODO: decode changeset information!!!

export_as_csv(css, "tmp/#{padid}.csv")
#export_as_csv(css, "tmp/#{padid}-server.csv")

### print to debug
##  mints = css.select { |cs| cs.timestamp? }.min_by { |cs| cs.timestamp }.timestamp  
##  puts "; userid", "timestamp", "formatted-timestamp", "event-type", "position", "line", "column", "value", "inserted", "deleted"
##  css.each do |cs| 
##     puts  "#{cs.userid} #{cs.timestamp} #{format_timestamp(cs.timestamp, mints)} #{cs.type} #{cs.position} #{cs.line} #{cs.column} #{cs.value.nil? ? 0 : cs.value.size} #{cs.inserted} #{cs.deleted}"
##  end

Process.exit(0)
