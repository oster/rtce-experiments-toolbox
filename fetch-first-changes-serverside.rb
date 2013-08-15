#!/usr/bin/env ruby -KU

require 'json'
require 'time'
require 'csv'
require 'zlib'

# TODO: remove ChangeSet code and include the ChangeSet.rb library
# TODO: decode and print information from ChangeSet (server encoded at the moment)


class ChangeSet
  attr_reader :userid, :vectorclock, :timestamp, :type, :position, :line, :column, :value, :deleted, :inserted
  attr_writer :timestamp, :position, :line, :column, :value, :deleted, :inserted

  @@userids = {}

  def initialize(struid, timestamp)
    @@userids[""] = 0 # server entry
    if ! @@userids[struid]
      @@userids[struid] = @@userids.size
    end    
    @userid = @@userids[struid]    
    @timestamp = timestamp
  end
 
  def timestamp?
   return ! @timestamp.nil?
  end
  
  def self.userids
    return @@userids
  end
  
  def decodeVectorClock(o)
    @vectorclock = {}
    o.each do |key, value| 
      @vectorclock[@@userids[key]] = value
    end
  end

  def concurrent?(cs)
    return ! (self.greaterThan?(cs) || cs.greaterThan?(self))
  end
  
  
  def clock_at_site(uid)
    if @vectorclock[uid].nil? 
      return 0
    else
      return @vectorclock[uid]
    end
  end
  
  def greaterThan?(cs)
    vc = cs.vectorclock
    gt = false;
    
    vc.each do |site, value| 
      if clock_at_site(site) < value
        return false
      elsif clock_at_site(site) > value
        gt = true
      end
    end
    
    if gt 
      return true
    end
    
    @vectorclock.each do |site, value|
      if vc[site].nil? || vc[site] < value
        return true
      end
    end
    
    return false
  end  
  
  def decodeType(typeStr)
    @type = case typeStr
    when "insertion"
      :ins
    when "suppression"
      :del
    when "remplacement"
      :upd
    when "style"
      :style
    else
      :unknown
    end
  end
    
  def decodeChangeSet(csStr)    
    # @position
    # @line
    # @column
    # @value 
    # @deleted 
    # @inserted
    @column = 0  # positionLineIndice / ind
    @line = 1 # positionLine / line
    @position = 0 # position
    @inserted = 0 # nbCharInserted
    @deleted = 0 # nbCharDeleted

    # @type
    if inserted > 0 && deleted > 0
      @type = :upd
    elsif inserted > 0
      @type = :ins
    elsif deleted  > 0
      @type = :del
    else
      @type = :unknown
    end
  end
  
end

#def format_timestamp(timestamp)
#  if timestamp.nil?
#    return ""
#  else
#    return Time.at(timestamp / 1000, timestamp % 1000 * 1000).strftime("%M:%S,%L")
#  end
#end

def computeTimeDelays(etherpad_log_file, padid)
  uids = {}
  Zlib::GzipReader.open(etherpad_log_file) do |logFile|  
#  File.open(etherpad_log_file, "r") do |logFile|
    while (line = logFile.gets())
      if /"padid":"#{padid}"/.match(line) && /"type":"USER_CHANGES"/.match(line)      
        m = /\[32m\[(.*)\] \[INFO.*"userId":("[a-zA-Z0-9.]*").*"timestamp":([0-9]*)/.match(line)
        if ! m.nil?
          if ! uids[m[2]]            
            serverTime = Time.strptime(m[1], '%Y-%m-%d %H:%M:%S.%L')
            clientTimestamp = m[3].to_i
            clientTime = Time.at(clientTimestamp / 1000, clientTimestamp % 1000 * 1000)
            deltaToAddToClient = serverTime - clientTime # delta in seconds!
            uids[m[2]] = [ serverTime, clientTime, deltaToAddToClient ]
          end    
        end
      end
    end  
  end
  return uids
end

def loadChangeSets(changeset_db_file, padid)
  changesets = []
  Zlib::GzipReader.open(changeset_db_file) do |inFile|  
#  File.open(changeset_db_file, "r") do |inFile|
    while (line = inFile.gets())
      o = JSON.parse(line)
      if /key:padid:#{padid}:userid:[.0-9a-zA-Z]*:clock:[0-9]+/.match(o["key"])        
        val = o["val"]
        cs = ChangeSet.new(val["userId"], val["timestamp"])
        
        cs.decodeType(val["operation"])
        cs.position = val["position"]
        cs.line = val["positionLine"]
        cs.column = val["positionLineIndice"]
        cs.value = val["chars_inserted"]
        cs.deleted = val["number_charDeleted"]
        cs.inserted = val["number_charInserted"]
        cs.decodeVectorClock(val["vector_clock"]["tab"])
        
        changesets << cs
      end
    end
  end
  return changesets
end


def loadChangeSetsFromServerDB(changeset_db_file, padid)
  changesets = []
  Zlib::GzipReader.open(changeset_db_file) do |inFile|  
#  File.open(changeset_db_file, "r") do |inFile|
    while (line = inFile.gets())
      o = JSON.parse(line)
      
      rev = -1
      cs = nil
      
      if /pad:#{padid}:revs:[0-9]+/.match(o["key"]) # {"key":"pad:test:revs:14","val":{"changeset":"Z:71>1|8=6y=2|1+1$\n","meta":{"author":"","timestamp":1337460881363}}}
        m = /pad:#{padid}:revs:([0-9]+)/.match(o["key"])
        rev = m[1]
        
        # puts o["val"]["changeset"] # "Z:71>1|8=6y=2|1+1$\n"
        # puts o["val"]["meta"]["author"] # ""
        # puts o["val"]["meta"]["timestamp"] # 1337460881363
        
        cs = ChangeSet.new(o["val"]["meta"]["author"], o["val"]["meta"]["timestamp"]);
        cs.decodeChangeSet(o["val"]["changeset"])
      end
      
      if ! cs.nil?
        line = inFile.gets()
        o = JSON.parse(line)    
        head = o["val"]["head"]
      
        if /pad:#{padid}/.match(o["key"]) # {"key":"pad:test","val":{"atext":{"text":"Welcome to Etherpad Lite!\n\nThis pad text is synchronized as you type, so that everyone viewing this page sees the same text. This allows you to collaborate seamlessly on documents!\n\nEtherpad Lite on Github: http://j.mp/ep-lite\n\ntrop cooll ça marche\n\nça\n\n","attribs":"|5+6b*0|1+1*0+k|1+1*0|1+1*0+2|2+2"},"pool":{"numToAttrib":{"0":["author","a.7pYLPeNecJbLVDyL"]},"nextNum":1},"head":14,"chatHead":-1,"publicStatus":false,"passwordHash":null,"vectorClock":{"tab":{"a.7pYLPeNecJbLVDyL":12,"":2}}}}   
          if head != m[1].to_i
            puts "WARNING: heads differ (s <> %s)" % [ head, m[1].to_i ]
            Process.exit(1)
          end
          cs.decodeVectorClock(o["val"]["vectorClock"]["tab"])
        else
          puts "WARNING: missing pad content forhead = %s" % [ head ]
          Process.exit(1)
        end
      end
      
      changesets << cs unless cs.nil?
    end
  end
  return changesets
end

def resynchTimestamps(changesets, delays)
  changesets.each do |cs|
    if (! cs.timestamp.nil? && cs.userid > 0) 
      struid = ChangeSet.userids.key(cs.userid)
      delayForThisUser = delays[%Q["#{struid}"]]
      newtimestamp = Time.at(cs.timestamp / 1000, cs.timestamp % 1000 * 1000)
      newtimestamp += delayForThisUser[2]
      cs.timestamp = newtimestamp.strftime("%s%L").to_i
    end
  end
end

def format_timestamp(timestamp, min)
  if timestamp.nil?
    return ""
  else
    ts = timestamp - min
    return Time.at(ts / 1000, ts % 1000 * 1000).strftime("%H:%M:%S,%L")
  end
end


def export_as_csv(changesets, filename)
  mints = changesets.select { |cs| cs.timestamp? }.min_by { |cs| cs.timestamp }.timestamp
  
  puts mints
  
  CSV.open(filename, "wb") do |csv|
    csv << ["; userid", "timestamp", "formatted-timestamp", "event-type", "position", "line", "column", "value", "inserted", "deleted"]
#    csv << ["; userid", "timestamp", "formatted-timestamp"]
    changesets.each { |cs| 
      csv << [cs.userid, cs.timestamp, format_timestamp(cs.timestamp, mints), cs.type, cs.position, cs.line, cs.column, cs.value.nil? ? 0 : cs.value.size, cs.inserted, cs.deleted]  
#      csv << [cs.userid, cs.timestamp, format_timestamp(cs.timestamp, mints) ]
    }
  end
end


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


# ./fetch-first-changes-serverside.rb films001 DATA-by-num/001/etherpad.log.gz DATA-by-num/001/dirty.db.gz

if ARGV.size < 3
  puts "usage: fetch-first-changes-serverside pad_id etherpad_log dbFile"
  Process.exit(0)
else
  padid = ARGV[0]
  etherpad_log_file = ARGV[1]
  db_file = ARGV[2]
end

#css = loadChangeSetsFromServerDB("tmp/dirty.db", padid)
#export_as_csv(css, "tmp/#{padid}-server.csv")

#delays = computeTimeDelays(etherpad_log_file, padid)

#puts delays

#css = loadChangeSets(changeset_file, padid)
css = loadChangeSetsFromServerDB(db_file, padid)
#resynchTimestamps(css, delays)
#export_as_csv(css, "tmp/#{padid}.csv")

#Process.exit(0)


# filter events without timestamp
# css = css.select { |cs| cs.timestamp? }

# filter server events
#css = css.select { |cs| cs.userid > 1 && cs.type != :unknown } 




ChangeSet.userids.values.each do |uid|
  csCount = css.select { |item| item.userid == uid }.size
  puts "User #{uid}: [ #{ChangeSet.userids.key(uid)}  ]"
  puts "  #{csCount} changeset(s) performed"
  if (csCount > 0)
    startTime = css.select { |cs| cs.userid == uid }[0].timestamp
    endTime = css.select { |cs| cs.userid == uid }[csCount-1].timestamp
    if (! startTime.nil?)
      duration = endTime - startTime
      puts "  #{format_timestamp(startTime, 0)} -> #{format_timestamp(endTime, 0)} (#{format_timestamp(duration, 0)})"
    end
    
    
    puts "==="
#    css.select { |cs| cs.userid == uid && cs.type == :ins }[0..4].each do |cs| 
    css.select { |cs| cs.userid == uid}[0..4].each do |cs| 
      puts "#{format_timestamp(cs.timestamp, 0)} [ #{cs.timestamp} ]: #{cs.value}"
    end
    puts "==="
    
    
#    puts css.select { |cs| cs.userid == uid && cs.type == :ins }.min_by { |cs| cs.timestamp }.value
    
    
    #   css.select { |item| item.userid == uid }.collect { |cs| 
    #     case cs.type
    #       when :ins
    
    
    
    
  end
#    puts Time.at(startTime/1000)
    
#  end
end
