class Report
  attr_accessor :user
  attr_accessor :day_span

  ILI_SYMPTOM_LIST = ['487.1', '780.60', '780.64', '787.02']

  def initialize user, day_span = 7
    @user = user
    @day_span = day_span
  end

  def totals
    ili_symptom_list = ILI_SYMPTOM_LIST.map{|c| "'#{c}'"}.join(',')
    school_ids = School.for_user(self.user).pluck(:id)

    return SchoolDailyInfo.select("school_daily_infos.report_date, SUM(school_daily_infos.total_absent) AS total_absent,
                           SUM(school_daily_infos.total_enrolled) AS total_enrolled, SUM(ili.confirmed) AS confirmed, SUM(ili.ili) AS ili,
                           SUM(school_daily_infos.total_absent)::FLOAT/GREATEST(SUM(school_daily_infos.total_enrolled), 1)::FLOAT AS pct")
          .joins("LEFT JOIN (SELECT students.school_id, student_daily_infos.report_date,
                             SUM(student_daily_infos.confirmed_illness::INTEGER) as confirmed, COUNT(student_daily_infos.id) as ili
                             FROM students
                             JOIN student_daily_infos ON student_daily_infos.student_id = students.id
                             JOIN student_reported_symptoms ON student_reported_symptoms.student_daily_info_id = student_daily_infos.id
                             JOIN symptoms ON symptoms.id = student_reported_symptoms.symptom_id
                             WHERE symptoms.icd9_code IN (#{ili_symptom_list})
                               AND student_daily_infos.report_date > (current_date - #{@day_span}) AND student_daily_infos.report_date <= current_date
                             GROUP BY students.school_id, student_daily_infos.report_date
                 ) as ili ON ili.school_id = school_daily_infos.school_id AND ili.report_date = school_daily_infos.report_date")
          .where(school_id: school_ids)
          .where("school_daily_infos.report_date > (current_date - #{@day_span}) AND school_daily_infos.report_date <= current_date")
          .group("school_daily_infos.report_date")
          .order("school_daily_infos.report_date DESC")
  end

  def school_districts
    self.user.school_districts.map do |district|
      {
        school_district: district_combined(district),
        schools_with_ili: school_ilis(district),
        schools_with_measles: school_measles(district),
        schools_above_average: school_absences(district)
      }
    end
  end

  def district_combined(district)
    absense_sql = DataFilterService.new(:school_district, {startdt: @day_span.days.ago.to_date, enddt: Date.today}).graph
                                   .select("schools.school_district_id")
                                   .where(:"school_districts.id" => district.id).to_sql
    ili_sql = DataFilterService.new(:school_district, {startdt: @day_span.days.ago.to_date, enddt: Date.today, symptoms: ILI_SYMPTOM_LIST}).graph
                               .select("SUM(confirmed_illness::INTEGER) AS confirmed")
                               .select("schools.school_district_id")
                               .where(:"school_districts.id" => district.id).to_sql

    SchoolDistrict.select("school_districts.*, absences.absent, absences.enrolled, absences.pct, ili.absent AS ili, ili.confirmed, absences.report_date")
                  .joins("LEFT JOIN (#{absense_sql}) AS absences ON absences.school_district_id = school_districts.id")
                  .joins("LEFT JOIN (#{ili_sql}) AS ili ON ili.school_district_id = school_districts.id AND ili.report_date = absences.report_date")
                  .where(:id => district.id)
                  .order("absences.report_date DESC")
  end

  def school_ilis(district)
    school_symptoms(district, ILI_SYMPTOM_LIST)
  end

  def school_measles(district)
    school_symptoms(district, ['055.9'])
  end

  def school_symptoms(district, symptoms)
    district.schools.select("schools.display_name, schools.id, SUM(student_daily_infos.confirmed_illness::INTEGER) as confirmed, COUNT(student_daily_infos.id) as ili")
                    .joins("JOIN students ON students.school_id = schools.id")
                    .joins("JOIN student_daily_infos ON student_daily_infos.student_id = students.id")
                    .joins("JOIN student_reported_symptoms ON student_reported_symptoms.student_daily_info_id = student_daily_infos.id")
                    .joins("JOIN symptoms ON symptoms.id = student_reported_symptoms.symptom_id")
                    .where("report_date > (current_date - #{@day_span}) AND report_date <= current_date")
                    .where(:"symptoms.icd9_code" => symptoms)
                    .group("schools.display_name, schools.id")
                    .having("SUM(student_daily_infos.confirmed_illness::INTEGER) > 0 OR COUNT(student_daily_infos.id) > 0")
                    .order("schools.display_name")
  end

  def school_absences(district)
    district.schools.select("display_name, report_date, total_absent::FLOAT/GREATEST(total_enrolled, 1)::FLOAT as pct, total_absent, total_enrolled, absent_dev, absent_avg")
                    .joins("JOIN school_daily_infos on schools.id = school_daily_infos.school_id")
                    .joins("JOIN (SELECT school_id, STDDEV(total_absent) as absent_dev, AVG(total_absent) as absent_avg
                                  FROM   school_daily_infos
                                  WHERE  report_date > (current_date - 60)
                                  GROUP BY school_id) as deviation on deviation.school_id = schools.id")
                    .where("report_date > (current_date - #{@day_span})
                       AND  report_date <= current_date
                       AND  (total_absent - absent_avg) > absent_dev")
                    .order("display_name, report_date DESC")
  end
end
