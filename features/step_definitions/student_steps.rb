Given /^"([^\"]*)" has the following current student absenteeism data:$/ do |isd, table|
  table.hashes.each do |row|
    report_date   = Date.today - row["day"].to_i.days
    result        = Rollcall::StudentDailyInfo.create(
      :school_id         => Rollcall::School.find_by_display_name(row['school_name']).id,
      :report_date       => report_date,
      :age               => row['age'],
      :dob               => row['dob'],
      :grade             => row['grade'],
      :gender            => row['gender'],
      :confirmed_illness => row['confirmed_ill']
    )
    unless row['symptoms'].blank?
      row['symptoms'].split(',').each do |value|
        Rollcall::StudentReportedSymptoms.create(
          :student_daily_info_id => result.id,
          :symptom_id            => Rollcall::Symptom.find_by_name(value).id
        )
      end
    end
  end
end