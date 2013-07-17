#!/usr/bin/env ruby -wKU

require 'json'
require 'time'
require 'csv'
require 'zlib'

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
#  File.open(etherpad_log_file, "r") do |logFile|
  Zlib::GzipReader.open(etherpad_log_file) do |logFile|  
    while (line = logFile.gets())
      if /"padid":"#{padid}"/.match(line) && /"type":"USER_CHANGES"/.match(line)      
        m = /\[32m\[(.*)\] \[INFO.*"userId":("[a-zA-Z0-9.]*").*"timestamp":([0-9]*)/.match(line)
        if ! m.nil?
          if ! uids[m[2]]            
            serverTime = Time.strptime(m[1], '%Y-%m-%d %H:%M:%S.%L')
            clientTimestamp = m[3].to_i
            clientTime = Time.at(clientTimestamp / 1000, clientTimestamp % 1000 * 1000)
            deltaToAddToClient = serverTime - clientTime
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
  #File.open(changeset_db_file, "r") do |inFile|
  Zlib::GzipReader.open(changeset_db_file) do |inFile|    
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


def loadPadRevisionsFromDB(db_file, padid)
  revisions = []
#  File.open(db_file, "r") do |inFile|
  Zlib::GzipReader.open(db_file) do |inFile|  
    while (line = inFile.gets())
      o = JSON.parse(line)
    
      new_rev = nil
      if /pad:#{padid}:revs:[0-9]+/.match(o["key"]) # {"key":"pad:test:revs:14","val":{"changeset":"Z:71>1|8=6y=2|1+1$\n","meta":{"author":"","timestamp":1337460881363}}}
        m = /pad:#{padid}:revs:([0-9]+)/.match(o["key"])
        rev = m[1]
        timestamp =  o["val"]["meta"]["timestamp"] # 1337460881363
        new_rev = { :rev => rev.to_i, :timestamp => timestamp.to_i }
        revisions << new_rev
      end
      if ! new_rev.nil?      
          line = inFile.gets()
          if ! line.nil?
            o = JSON.parse(line)    
            head = o["val"]["head"]
            if head.to_i  != new_rev[:rev]
              puts "WARNING: head does not match with current rev number"
              Process.exit(1)
            end            
            if /pad:#{padid}/.match(o["key"]) # {"key":"pad:test","val":{"atext":{"text":"Welcome to Etherpad Lite!\n\nThis pad text is synchronized as you type, so that everyone viewing this page sees the same text. This allows you to collaborate seamlessly on documents!\n\nEtherpad Lite on Github: http://j.mp/ep-lite\n\ntrop cooll ça marche\n\nça\n\n","attribs":"|5+6b*0|1+1*0+k|1+1*0|1+1*0+2|2+2"},"pool":{"numToAttrib":{"0":["author","a.7pYLPeNecJbLVDyL"]},"nextNum":1},"head":14,"chatHead":-1,"publicStatus":false,"passwordHash":null,"vectorClock":{"tab":{"a.7pYLPeNecJbLVDyL":12,"":2}}}}   
              if head != m[1].to_i
                puts "WARNING: heads differ (s <> %s)" % [ head, m[1].to_i ]
                Process.exit(1)
              end
              content = o["val"]["atext"]["text"]
              new_rev[:content] = content
            else
              puts "WARNING: missing pad content forhead = %s" % [ head ]
              Process.exit(1)
            end
          end
      end
      new_rev = nil   
    end
  end  
  return revisions
end


def loadChangeSetsFromServerDB(changeset_db_file, padid)
  changesets = []
  #File.open(changeset_db_file, "r") do |inFile|
  Zlib::GzipReader.open(changeset_db_file) do |inFile|   
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

def format_timestamp(timestamp, min=0)
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
