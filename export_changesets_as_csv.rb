#!/usr/bin/env ruby -wU

#require 'gnuplot'
require_relative 'ChangeSet'

if ARGV.size == 0
  puts "usage: export_changesets_as_csv.rb pad_id"
  Process.exit(0)
else
  padid = ARGV[0]
end

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
