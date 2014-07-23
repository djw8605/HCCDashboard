def GetHours(starttime = Time.now.utc, endtime = nil, span = 86400)
  require 'date'
  require 'net/http'
  require 'time'
  require 'csv'
  
  if endtime == nil
    endtime = starttime + 3600
  end
  starttime_str = DateTime.parse(starttime.to_s).strftime('%Y-%m-%d%%20%H:%M:%S')
  endtime_str = DateTime.parse(endtime.to_s).strftime('%Y-%m-%d%%20%H:%M:%S')

  url_raw = 'http://hcc-gratia.unl.edu:8100/gratia/csv/vo_facility_hours_bar_smry?starttime=%{starttime}&endtime=%{endtime}&span=%{span}' % { :starttime => starttime_str, :endtime => endtime_str, :span => span }

  uri = URI(url_raw)
  response = Net::HTTP.get_response(uri)

  #File.open("/tmp/csv.file", 'w') { |f| f.write(url_raw) }
  #File.open("/tmp/csv.file", 'a') { |f| f.write(response.body) }

  total_hours = 0.0
  CSV.parse(response.body, { :headers => :first_row} ) do |row|
     total_hours += row[2].to_f
  end

  #File.open("/tmp/csv.file", 'a') { |f| f.write(list) }
  return total_hours

end


# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '1h', :first_in => 0 do |job|
  require 'time'

  # Previous 24 hours...
  current_hours = GetHours(Time.now.utc - 3600*24)
  previous_hours = GetHours(Time.now.utc - 3600*48)

  # Last weeks
  current_week = GetHours(Time.now.utc - 3600*24*7, endtime = Time.now.utc - 3600*24, span=604800)
  previous_week = GetHours(Time.now.utc - 3600*24*14, endtime = Time.now.utc - 3600*24*8, span=604800)
  #File.open("/tmp/csv.file", 'a') { |f| f.write(current_week) }
  #File.open("/tmp/csv.file", 'a') { |f| f.write("\n") }
  #File.open("/tmp/csv.file", 'a') { |f| f.write(previous_week) }

  send_event('HoursToday', {current: current_hours, last: previous_hours })
  send_event('HoursWeek', {current: current_week, last: previous_week })
end
