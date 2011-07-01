Given /^"([^\"]*)" has the following current student absenteeism data:$/ do |isd, table|
  table.hashes.each do |row|
    report_date   = Date.today - row["day"].to_i.days
    student       = Rollcall::Student.create(
       :dob               => row['dob'],
       :gender            => row['gender'],
       :school_id         => Rollcall::School.find_by_display_name(row['school_name']).id
    )
    result        = Rollcall::StudentDailyInfo.create(
      :student_id        => student.id,
      :report_date       => report_date,
      :grade             => row['grade'],
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