def GetCurrentUsers()
  require 'date'
  require 'net/http'
  require 'time'
  require 'csv'

  starttime = Time.now.utc - 3600*3
  endtime = Time.now.utc - 3600*2
  starttime_str = DateTime.parse(starttime.to_s).strftime('%Y-%m-%d%%20%H:%M:%S')
  endtime_str = DateTime.parse(endtime.to_s).strftime('%Y-%m-%d%%20%H:%M:%S')

  url_raw = 'http://rcf-gratia.unl.edu/gratia/csv/status_vo?starttime=%{starttime}&endtime=%{endtime}' % { :starttime => starttime_str, :endtime => endtime_str }

  uri = URI(url_raw)
  response = Net::HTTP.get_response(uri)

  #File.open("/tmp/csv.file", 'w') { |f| f.write(url_raw) }
  #File.open("/tmp/csv.file", 'a') { |f| f.write(response.body) }

  list = []
  CSV.parse(response.body, { :headers => :first_row} ) do |row|
     list.push({ :label => row[0], :value => row[2].to_f })
  end

  #File.open("/tmp/csv.file", 'a') { |f| f.write(list) }
  return list

end

# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '1m', :first_in => 0 do |job|

  list = GetCurrentUsers()
  total_cores = list.inject(0) {|sum, hash| sum + hash[:value]}

  dollar_amount = "$%.2f" % ((total_cores / 4) * 0.3)
  
  File.open("/tmp/csv.file", 'w') { |f| f.write(total_cores) }
  send_event('HCCAmazonPrice', {current: dollar_amount})
end
