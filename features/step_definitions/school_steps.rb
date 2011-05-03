Given /^"([^\"]*)" has the following schools:$/ do |isd, table|
  rrd_path = Dir.pwd << "/rrd/"
  table.hashes.each do |row|
    @district = Rollcall::SchoolDistrict.find_by_name(isd)
    result    = Rollcall::School.create(
      :name          => row["name"],
      :display_name  => row["name"],
      :tea_id        => row["tea_id"],
      :district_id   => @district,
      :school_number => row["school_number"],
      :gmap_lat      => row["gmap_lat"],
      :gmap_lng      => row["gmap_lng"],
      :gmap_addr     => row["gmap_addr"],
      :postal_code   => row["postal_code"],
      :school_type   => row["school_type"]
    )
    File.delete("#{rrd_path}#{result.tea_id}_c_absenteeism.rrd") if File.exist?("#{rrd_path}#{result.tea_id}_c_absenteeism.rrd")
    rrd_file = Rollcall::Rrd.find_by_file_name_and_school_id("#{result.tea_id}_c_absenteeism.rrd", result.id)
    rrd_file.destroy unless rrd_file.blank?
    current_time = Time.gm(Date.today.year, Date.today.month, Date.today.day,0,0).at_beginning_of_week - 1.week
    Rollcall::Rrd.build_rrd("#{result.tea_id}_c", result.id, current_time)
  end
end

Given /^"([^\"]*)" has the following current school absenteeism data:$/ do |isd, table|
  school         = ''
  first_run      = false
  report_date    = ''
  total_enrolled = ''
  current_time   = Time.gm(Date.today.year, Date.today.month, Date.today.day,0,0).at_beginning_of_week - 1.week
  rrd_path       = Dir.pwd << "/rrd/"
  rrd_tool       = if File.exist?(doc_yml = RAILS_ROOT+"/vendor/plugins/rollcall/config/rrdtool.yml")
    YAML.load(IO.read(doc_yml))[Rails.env]["rrdtool_path"] + "/rrdtool"
  else
    "rrdtool"
  end
  table.hashes.each do |row|
    if school.blank?
      school    = Rollcall::School.find_by_display_name(row['school_name'])
      first_run = true
    else
      if school.display_name != row['school_name']
        RRD.update "#{rrd_path}#{school.tea_id}_c_absenteeism.rrd",[(report_date + 2.days).to_i.to_s,0,total_enrolled],"#{rrd_tool}"
        school    = Rollcall::School.find_by_display_name(row['school_name'])
        first_run = true
      end
    end
    report_date    = current_time + row["day"].strip.to_i.days
    total_absent   = row['total_absent'].strip.to_i
    total_enrolled = row['total_enrolled'].strip.to_i
    if first_run
      RRD.update "#{rrd_path}#{school.tea_id}_c_absenteeism.rrd",[report_date.to_i.to_s,0,total_enrolled],"#{rrd_tool}"
      first_run = false
    end

    Rollcall::SchoolDailyInfo.create(
      :school_id      => school.id,
      :total_absent   => total_absent,
      :total_enrolled => row['total_enrolled'],
      :report_date    => report_date
    )
    if report_date.strftime("%a").downcase == "sat" || report_date.strftime("%a").downcase == "sun"
      RRD.update("#{rrd_path}#{school.tea_id}_c_absenteeism.rrd", [(report_date + 1.day).to_i.to_s,0,total_enrolled], "#{rrd_tool}")
    else
      RRD.update("#{rrd_path}#{school.tea_id}_c_absenteeism.rrd", [(report_date + 1.day).to_i.to_s,total_absent,total_enrolled], "#{rrd_tool}")
      result = Rollcall::SchoolDailyInfo.create(
        :school_id      => school.id,
        :total_absent   => total_absent,
        :total_enrolled => total_enrolled,
        :report_date    => report_date
      )
    end

  end
end