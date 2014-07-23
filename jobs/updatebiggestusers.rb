def GetCurrentUsers()
  require 'date'
  require 'net/http'
  require 'time'
  require 'csv'

  starttime = Time.now.utc - 3600*3
  endtime = Time.now.utc - 3600*2
  starttime_str = DateTime.parse(starttime.to_s).strftime('%Y-%m-%d %H:%M:%S')
  endtime_str = DateTime.parse(endtime.to_s).strftime('%Y-%m-%d %H:%M:%S')

  url_raw = 'http://hcc-gratia.unl.edu:8100/gratia/csv/status_vo?starttime=%{starttime}&endtime=%{endtime}&excludevo=nanohub|cmsprod|engage|ligo|dzero|uscms|Cusatlas|osg|sbgrid|glow|fermilab|ucsdgrid' % { :starttime => starttime_str, :endtime => endtime_str }
  
  uri = URI(URI.escape(url_raw))
  File.open("/tmp/csv.file", 'w') { |f| f.write(url_raw) }
  response = Net::HTTP.get_response(uri)

  File.open("/tmp/csv.file", 'a') { |f| f.write(response.body) }

  list = []
  CSV.parse(response.body, { :headers => :first_row} ) do |row|
     list.push({ :label => row[0], :value => row[2].to_f })
  end

  #File.open("/tmp/csv.file", 'a') { |f| f.write(list) }
  return list

end


# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '30m', :first_in => 0 do |job|
  require 'rubygems'
  require 'mysql'
  require 'yaml'
  
  list = GetCurrentUsers()
  dbconf = YAML.load_file('db.yml')
  #puts "Starting connection..."
  #puts dbconf['rcfmysql_user']
  #puts dbconf['rcfmysql_pass']
  db = Mysql.new(dbconf['rcfmysql_host'], dbconf['rcfmysql_username'], dbconf['rcfmysql_pass'], dbconf['rcfmysql_db'])
  sorted = list.sort_by{|e| -e[:value]}.slice(0, 25)
  sorted.each_index do |index|
    query = "select Department, Campus from Personal where LoginID = '%{username}'" % { :username => sorted[index][:label] }
    #puts query
    #puts "Starting query..."
    results = db.query(query)
    row = results.fetch_row()
    if row != nil
      sorted[index]["dept"] = row[0]
      sorted[index]["campus"] = row[1]
      #File.open("/tmp/csv.file", 'a') { |f| f.write(sorted[index]) }
    end
  end
  #File.open("/tmp/csv.file", 'a') { |f| f.write("\n") } 
  #File.open("/tmp/csv.file", 'a') { |f| f.write(sorted) }
  

  send_event('BiggestUsers', { items:  sorted})
end
