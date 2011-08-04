Given /^"([^\"]*)" has the following current student absenteeism data:$/ do |isd, table|
  table.hashes.each do |row|
    current_time  = Time.gm(Date.today.year, Date.today.month, Date.today.day,0,0).at_beginning_of_week - 1.week 
    report_date   = current_time + row["day"].strip.to_i.days
    student       = Rollcall::Student.create(
       :first_name        => row['first_name'].strip,
       :last_name         => row['last_name'].strip,
       :student_number    => row['student_number'].strip,
       :dob               => row['dob'].strip,
       :gender            => row['gender'].strip,
       :school_id         => Rollcall::School.find_by_display_name(row['school_name']).id
    )
    result        = Rollcall::StudentDailyInfo.create(
      :student_id        => student.id,
      :report_date       => report_date,
      :grade             => row['grade'].strip,
      :confirmed_illness => row['confirmed_ill']
    )
    unless row['symptoms'].blank?
      row['symptoms'].split(',').each do |value|
        Rollcall::StudentReportedSymptom.create(
          :student_daily_info_id => result.id,
          :symptom_id            => Rollcall::Symptom.find_by_name(value).id
        )
      end
    end
  end
end

Given /^"([^\"]*)" has the following student data:$/ do |isd, table|
  table.hashes.each do |row|
    student       = Rollcall::Student.create(
       :first_name         => row['first_name'],
       :last_name          => row['last_name'],
       :contact_first_name => row['contact_first_name'],
       :contact_last_name  => row['contact_last_name'],
       :address            => row['address'],
       :zip                => row['zip'],
       :dob                => row['dob'],
       :gender             => row['gender'],
       :phone              => row['phone'],
       :race               => row['race'],
       :student_number     => row['student_number'],
       :school_id          => Rollcall::School.find_by_display_name(row['school_name']).id
    )
  end
end