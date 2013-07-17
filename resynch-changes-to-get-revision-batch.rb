#!/usr/bin/env ruby -wU


data = {
    5 => { :group => 5,
           :delay => 8,
           :corrections => {
             :timestamp => 1341575940928,
             :userid => 'a.Fjb4qfZXvpdxYPDu'
           },
           :films => {
             :timestamp => 1341576722586,
             :userid => 'a.T3a9ef7SR0nCjcgB'             
           }
    },
    6 => { :group => 6,
           :delay => 0,
           :corrections => {
             :timestamp => 1342437363889,
             :userid => 'a.Fjb4qfZXvpdxYPDu'
         },
           :films => {
             :timestamp => 1342438193039,
             :userid => 'a.6Fu3ePE1Qfgjl0ky'
         }
    },
    7 => { :group => 7,
           :delay => 6, 
           :corrections => {
             :timestamp => 1342766847306,
             :userid => 'a.6Fu3ePE1Qfgjl0ky'
         },
           :films => {
             :timestamp => 1342767711599,
             :userid => 'a.T3a9ef7SR0nCjcgB'
         }
    },
    8 => { :group => 8,
           :delay => 6, 
           :corrections => {
             :timestamp => 1342783567406,
             :userid => 'a.FIK9w8r3VYs51VEs'
         },
           :films => {
             :timestamp => 1342784326908,
             :userid => 'a.FIK9w8r3VYs51VEs'
         }         
    },
    9 => { :group => 9,
           :delay => 10, 
           :corrections => {
             :timestamp => 1343111793415,
             :userid => 'a.FIK9w8r3VYs51VEs'
         },
           :films => {
             :timestamp => 1343112545269,
             :userid => 'a.FIK9w8r3VYs51VEs'
         }
    },
    10 => { :group => 10,
            :delay => 10, 
            :corrections => {
              :timestamp => 1343128547311,
              :userid => 'a.HDMdU4ErhOEi31l3'
          },
            :films => {
              :timestamp => 1343129317856,
              :userid => 'a.bptKNCIHFQnLXyvD'
          }
    },
    11 => { :group => 11,
            :delay => 0, 
            :corrections => {
              :timestamp => 1366265973419,
              :userid => 'a.JbwK9KlqpJV2vjBE'
          },
            :films => {
              :timestamp => 1366266649038,
              :userid => 'a.xD0XdvZ82CskICbL'
          }
    },
    12 => { :group => 12,
            :delay => 6, 
            :corrections => {
              :timestamp => 1366270049788,
              :userid => 'a.GXaGD5oiTgPmEMN5'
          },
            :films => {
              :timestamp => 1366270755326,
              :userid => 'a.GXaGD5oiTgPmEMN5'
          }
    },
    13 => { :group => 13,
            :delay => 10, 
            :corrections => {
              :timestamp => 1366625328915,
              :userid => 'a.yaDHM6kalywWyaVW'
          },
            :films => {
              :timestamp => 1366626203829,
              :userid => 'a.kkFFGgg1FhOsUL6T'
          }
    },
    14 => { :group => 14,
            :delay => 4,
            :corrections => {
              :timestamp => 1369375696375,
              :userid => 'a.263OMQOSbDC9CkwJ'
          },
            :films => { # films015
              :timestamp => 1369376742743,
              :userid => 'a.GXaGD5oiTgPmEMN5'
          }
    },
    16 => { :group => 16,
            :delay => 8, 
            :corrections => {
              :timestamp => 1369638616129,
              :userid => 'a.GXaGD5oiTgPmEMN5'
          },
            :films => {
              :timestamp => 1369639425561,
              :userid => 'a.GXaGD5oiTgPmEMN5'
          }
    },
    17 => { :group => 17,
            :delay => 0,   
            :corrections => {
              :timestamp => 1369721409901,
              :userid => 'a.263OMQOSbDC9CkwJ'
          },
            :films => {
              :timestamp => 1369722157631,
              :userid => 'a.GXaGD5oiTgPmEMN5'
          }
    },
    18 => { :group => 18,
            :delay => 4, 
            :corrections => {
              :timestamp => 1369735983492,
              :userid => 'a.GXaGD5oiTgPmEMN5'
          },
            :films => {
              :timestamp => 1369736650978,
              :userid => 'a.263OMQOSbDC9CkwJ'
          }
    },
    19 => { :group => 19,
            :delay => 0, 
            :corrections => {
              :timestamp => 1369984536143,
              :userid => 'a.263OMQOSbDC9CkwJ'
          },
            :films => {
              :timestamp => 1369985245216,
              :userid => 'a.263OMQOSbDC9CkwJ'
          }
    },
    20 => { :group => 20,
            :delay => 8,       
            :corrections => {
              :timestamp => 1372760447796,
              :userid => 'a.fEHZdRB09Sds6jMD'
            },
            :films => {
              :timestamp => 1372761227618,
              :userid => 'a.fEHZdRB09Sds6jMD'
            }
    },
    21 => { :group => 21,
            :delay => 6,       
            :corrections => {
              :timestamp => 1372919350395,
              :userid => 'a.fEHZdRB09Sds6jMD'
            },
            :films => {
              :timestamp => 1372920122841,
              :userid => 'a.xyIz9UR3lXhTFMh6'
            }
    },
#    22 => { :group => 22,
#            :delay => 0,       
#            :corrections => { # should be used with *-failed.gz files! 
#              :timestamp => 1373005343306,
#              :userid => 'a.fEHZdRB09Sds6jMD'
#            },
#            :films => {
#              :timestamp => 1373007198159, # films014
#              :userid => 'a.5eXQct6sNarG6j0R'
#            }
#    },
}





[6, 7, 8, 9, 10].each do |duration|
  [5, 6, 7, 8, 9, 10, 12, 13, 14, 16, 17, 18, 19, 20, 21].each do |group|
    [:corrections, :films].each do |experiment|
              
      if group == 14 && experiment == :films then num = 15 else num = group end  # to fix group number for bad experimentation
      
      num =  "%03d" % num     # group number
      uid = data[group][experiment][:userid]       # id of user who performed the first modification
      tstamp = data[group][experiment][:timestamp] # timestamp (server time) of the first modification
      logfile = "/tmp/#{experiment}-syncing-#{duration}mn.log"
         
      system "./resynch-changes-to-get-revision.rb #{experiment}#{num} DATA-by-num/#{num}/etherpad.log.gz DATA-by-num/#{num}/dirtyCS.db.gz DATA-by-num/#{num}/dirty.db.gz #{uid} #{tstamp} #{duration} >> #{logfile}"
      system "echo === >> #{logfile}"
    end
  end
end