class SeedRollcallData
  def self.simulate_outbreak illness, day_count, tea_id, report_date
    total_absent = 0
    day_count   += 1
    if illness == 'flu' || illness == 'pox' || illness == 'strep'
      if day_count <= 2
        total_absent = (5..10).to_a[rand((5..10).to_a.length)]
      elsif day_count >= 3 && day_count < 5
        total_absent = (11..21).to_a[rand((11..21).to_a.length)]
      elsif day_count >= 5 && day_count < 14
        total_absent = (22..45).to_a[rand((22..45).to_a.length)]
      elsif day_count >= 14 && day_count < 16
        total_absent = (15..25).to_a[rand((15..25).to_a.length)]
      elsif day_count >= 16
        day_count    = 0
        total_absent = (2..10).to_a[rand((2..10).to_a.length)]
      end
    elsif illness == 'cold'
      if day_count <= 2
        total_absent = (3..10).to_a[rand((3..8).to_a.length)]
      elsif day_count >= 3 && day_count < 6
        total_absent = (15..25).to_a[rand((10..20).to_a.length)]
      elsif day_count >= 6 && day_count < 7
        total_absent = (25..35).to_a[rand((25..35).to_a.length)]
      elsif day_count >= 7
        day_count    = 0
        total_absent = (5..10).to_a[rand((5..10).to_a.length)]
      end
    elsif illness == 'event'
      if day_count == 1
        total_absent = (20..50).to_a[rand((20..50).to_a.length)]
      else
        day_count    = 0
        total_absent = (5..10).to_a[rand((5..10).to_a.length)]
      end
    else
      if day_count == 1
        day_count    = 0
        total_absent = (0..20).to_a[rand((0..20).to_a.length)]
      end
    end
    puts "Generating #{illness} outbreak on day #{day_count}, report date #{report_date}, for school #{tea_id}"
    return [total_absent,day_count]
  end

  def self.do_student_daily_info(daily_info, illness)
    puts "Generating Student Dailies for #{daily_info.school.display_name} on report date #{daily_info.report_date}"
    school_type = daily_info.school.school_type.gsub(/\s/,'').underscore
    (0..(daily_info.total_absent - 1)).collect { |i|
      age_array = nil
      grade     = nil
      if school_type == 'high_school'
        age_array = (15..18).to_a
        grade     = (9..12).to_a[rand((9..12).to_a.length)]
      elsif school_type == 'middle_school'
        age_array = (12..14).to_a
        grade     = (7..8).to_a[rand((7..8).to_a.length)]
      elsif school_type == 'elementary_school'
        age_array = (5..11).to_a
        grade     = (1..6).to_a[rand((1..6).to_a.length)]
      else
        age_array = (2..4).to_a
        grade     = 0
      end
      age                  = age_array[rand(age_array.length)]
      dob                  = Time.now - age.years - (rand(11) + 1).months - (rand(29) + 1).days
      gender_array         = ['M','F']
      is_confirmed_illness = false
      if illness != 'event' && illness != 'none'
        is_confirmed_illness = true
      end
      {
        :age               => age,
        :dob               => dob,
        :grade             => grade,
        :gender            => gender_array[rand(gender_array.length)],
        :confirmed_illness => is_confirmed_illness,
        :symptom           => get_symptom(illness)
      }
    }
  end

  def self.get_symptom(illness)
    case illness
      when 'flu' || 'pox' || 'strep'
        symptom_name = ['Sore Throat','Congestion','Influenza','Temperature','Chills','Lethargy','Headache','Cough']
      when 'cold'
        symptom_name = ['Sore Throat','Congestion','Chills','Lethargy','Headache','Cough']
      else
        symptom_name = ['None']
    end
    symptom_name[rand(symptom_name.length)]
  end
end

# Change current_time to desired test range to best suite your environment
begin_time   = Time.gm(2011, 3, 21)
current_time = Time.gm(2011, 3, 23)
days_to_traverse = ((current_time - begin_time) / 86400).to_i
puts "Generating data for #{days_to_traverse} days ..."

enrollment_fp = File.open("/tmp/enrollment.csv", "w+")
attendance_fp = File.open("/tmp/attendance.csv", "w+")
ili_fp = File.open("/tmp/ili.csv", "w+")
Rollcall::SchoolDistrict.all.each do |district|
  (district.schools.map(&:tea_id)).compact.each do |tea_id|
    school                  = Rollcall::School.find_by_tea_id(tea_id)
    total_enrolled          = (2..6).to_a[rand((2..6).to_a.length)] * 100
    school_illness_outbreak = ['flu','pox','strep','cold','event','none']
    illness                 = school_illness_outbreak[rand(school_illness_outbreak.length)]
    sim_result              = [0, 0]
    event_counter           = 0

    (0..days_to_traverse).reverse_each do |i|
      report_date  = current_time - i.days
      sim_result   = SeedRollcallData.simulate_outbreak illness, sim_result[1], tea_id, report_date
      total_absent = sim_result[0]

      next if report_date.strftime("%a").downcase == "sat" || report_date.strftime("%a").downcase == "sun"

      curdate = report_date.strftime("%Y-%m-%d")
      # Enrollment
      enrollment_fp.puts [curdate, tea_id, school.display_name, total_enrolled].join(",")
      # Attendance
      attendance_fp.puts [curdate, tea_id, school.display_name, total_absent].join(",")
      # ILI
      ili_fp.puts [i, begin_time.year, tea_id, school.display_name, curdate, curdate,
        98.6, "\"Lethargy,Cough\"", school.postal_code, "7th", "inSchool",
        "confirmed", "released", "diagnosis", "treatment", "student name",
        "emg contact", "emg phone", "DOB", "M", "race",
        "physician follow-up date", "doctor", "doctor addr"
      ].join(",")
    end
  end
end
enrollment_fp.close
attendance_fp.close
ili_fp.close
