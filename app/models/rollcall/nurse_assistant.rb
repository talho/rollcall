class Rollcall::NurseAssistant < Rollcall::Base
  belongs_to :user,   :class_name => "User"
  belongs_to :school, :class_name => "Rollcall::School", :foreign_key => "school_id"
  set_table_name "rollcall_nurse_assistant"

  def create_associative_data obj, user_id
    school_info    = Rollcall::SchoolDailyInfo.find_by_school_id_and_report_date obj.school_id, obj.report_date
    total_absent   = nil
    total_enrolled = nil
    result         = create(
      :school_id          => Rollcall.School.find_by_name(obj.school).id,
      :user_id            => user_id,
      :student_first_name => obj.student_first_name,
      :student_last_name  => obj.student_last_name,
      :parent_first_name  => obj.parent_first_name,
      :parent_last_name   => obj.parent_last_name,
      :address            => obj.address,
      :zip_code           => obj.zip_code,
      :phone_number       => obj.phone_number,
      :action             => obj.action,
      :report_date        => obj.report_date
    )
    unless school_info
      if obj.total_enrolled_alpha_value
        total_enrolled = obj.total_enrolled_alpha_value
      else
        sdi            = Rollcall::SchoolDailyInfo.find_all_by_school_id(obj.school_id, :order => "report_date ASC")
        total_enrolled = sdi.last.total_enrolled
      end
      total_absent = 1
      school_info  = Rollcall::SchoolDailyInfo.create(
        :school_id      => obj.school_id,
        :total_absent   => total_absent,
        :total_enrolled => total_enrolled,
        :report_date    => obj.report_date
      )
    else
      total_absent = school_info.total_absent + 1
      school_info.update(
        :total_absent => total_absent,
        :report_date  => obj.report_date
      )
      school_info.save!
    end  
    daily_info = Rollcall::StudentDailyInfo.create(
      :school_id         => obj.school_id,
      :report_date       => obj.report_date,
      :age               => obj.age,
      :dob               => obj.dob,
      :grade             => obj.grade,
      :gender            => obj.gender,
      :confirmed_illness => !obj.symptoms.blank?
    )
    symptom_id      = Rollcall::Symptom.find_by_name(obj[:symptom]).id
    student_symptom = Rollcall::StudentReportedSymptoms.create :student_daily_info_id => daily_info.id, :symptom_id => symptom_id
    rrd_result      = Rollcall::Rrd.update_rrd_data report_date, total_absent, total_enrolled, Rollcall.School.find_by_name(obj.school).tea_id 
    return result
  end
end