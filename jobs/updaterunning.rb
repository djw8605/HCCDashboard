
def GetCores(cluster = nil, starttime = nil, endtime = nil)
  require 'date'
  require 'net/http'
  require 'time'
  require 'csv'

  starttime_str = DateTime.parse(starttime.to_s).strftime('%Y-%m-%d%%20%H:%M:%S')
 
  if endtime == nil
    url_raw = 'http://rcf-gratia.unl.edu/gratia/csv/status_vo?facility=%{cluster}&starttime=%{starttime}' % { :cluster => cluster, :starttime => starttime_str }
  else
    endtime_str = DateTime.parse(endtime.to_s).strftime('%Y-%m-%d%%20%H:%M:%S')
    url_raw = 'http://rcf-gratia.unl.edu/gratia/csv/status_vo?facility=%{cluster}&starttime=%{starttime}&endtime=%{endtime}' % { :cluster => cluster, :starttime => starttime_str, :endtime => endtime_str }
  end

  uri = URI(url_raw)
  response = Net::HTTP.get_response(uri) 

  #File.open("/tmp/csv.file", 'w') { |f| f.write(url) }
  #File.open("/tmp/csv.file", 'a') { |f| f.write(response.body) }

  total_cores = 0.0
  CSV.parse(response.body, { :headers => :first_row} ) do |row|
     total_cores += row[2].to_f
  end

  return total_cores

end


# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '15m', :first_in => 0 do |job|
 
  # time - 1 hour
  t = Time.now.utc - 3600

  # yesterday at the same time period
  last_start = Time.now.utc - 86400-3600
  last_end = Time.now.utc - 86400
  
  total_cores = GetCores('Tusker', t)
  last_cores = GetCores('Tusker', last_start, last_end)
  send_event('TuskerRunning', { current:  total_cores, last: last_cores, last_period: 'yesterday'})

  total_cores = GetCores('Crane', t)
  last_cores = GetCores('Crane', last_start, last_end)
  send_event('CraneRunning', { current:  total_cores, last: last_cores, last_period: 'yesterday'})

  total_cores = GetCores('Sandhills', t)
  last_cores = GetCores('Sandhills', last_start, last_end)
  send_event('SandhillsRunning', { current:  total_cores, last: last_cores, last_period: 'yesterday'})

  
end
