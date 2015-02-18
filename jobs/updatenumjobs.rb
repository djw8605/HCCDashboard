def GetNumJobs(starttime = Time.now.utc - 86400, endtime = Time.now.utc)
  require 'date'
  require 'net/http'
  require 'time'
  require 'csv'
  
  #if endtime == nil
  #  endtime = starttime + 3600
  #end
  starttime_str = DateTime.parse(starttime.to_s).strftime('%Y-%m-%d%%20%H:%M:%S')
  endtime_str = DateTime.parse(endtime.to_s).strftime('%Y-%m-%d%%20%H:%M:%S')

  url_raw = 'http://hcc-gratia.unl.edu:8100/gratia/csv/osg_facility_count?starttime=%{starttime}&endtime=%{endtime}' % { :starttime => starttime_str, :endtime => endtime_str }

  uri = URI(url_raw)
  response = Net::HTTP.get_response(uri)

  File.open("/tmp/csv.file", 'w') { |f| f.write(url_raw) }
  File.open("/tmp/csv.file", 'a') { |f| f.write(response.body) }

  total_jobs = 0
  CSV.parse(response.body, { :headers => :first_row} ) do |row|
     total_jobs += row[1].to_i
  end

  File.open("/tmp/csv.file", 'a') { |f| f.write(total_jobs) }
  return total_jobs

end


# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '30s', :first_in => 0 do |job|
  require 'time'

  # Previous 24 hours...
  #current_hours = GetHours(Time.now.utc - 3600*24)
  #previous_hours = GetHours(Time.now.utc - 3600*48)

  numjobs = GetNumJobs()

  # Last weeks
  #current_week = GetHours(Time.now.utc - 3600*24*7, endtime = Time.now.utc - 3600*24, span=604800)
  #previous_week = GetHours(Time.now.utc - 3600*24*14, endtime = Time.now.utc - 3600*24*8, span=604800)
  #File.open("/tmp/csv.file", 'a') { |f| f.write(current_week) }
  #File.open("/tmp/csv.file", 'a') { |f| f.write("\n") }
  #File.open("/tmp/csv.file", 'a') { |f| f.write(previous_week) }

  send_event('JobsCompleted', {current: numjobs})

  #send_event('HoursToday', {current: current_hours, last: previous_hours })
  #send_event('HoursWeek', {current: current_week, last: previous_week })
end
