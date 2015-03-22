class DataFilterService
  attr_accessor :params
  attr_accessor :type
  attr_accessor :ili
  attr_accessor :query

  def initialize(type, params)
    @params = params
    @type = type
    @ili = params[:ili]

    param_setup
  end

  def graph
    @query = @ili ? StudentDailyInfo.all : SchoolDailyInfo.all
    apply_selects @params[:data_func]
    apply_joins
    apply_filters if @ili
    apply_total_absent_filter unless @ili
    apply_date_filter @params[:startdt], @params[:enddt]
    apply_order
    apply_group

    @query
  end

  protected

  def apply_joins
    if @ili
      @query = @query.joins("JOIN students ON students.id = student_daily_infos.id")
                   .joins("JOIN schools ON schools.id = students.id")
                   .joins("JOIN (SELECT MAX(total_enrolled) as max_enrolled, school_id
                                 FROM school_daily_infos
                                 GROUP BY school_id) as max_school_enrollment on max_school_enrollment.school_id = schools.id")
      if @type == :school_district
        @query = @query.joins("JOIN school_districts ON schools.school_district_id = school_districts.id")
                     .joins("LEFT JOIN (SELECT SUM(total_enrolled) as total_enrolled, school_district_id, report_date
                             FROM schools rs
                             JOIN school_daily_infos rsdi ON rs.id = rsdi.school_id
                             GROUP BY school_district_id, report_date) district_info on district_info.school_district_id = school_districts.id and district_info.report_date = student_daily_infos.report_date")
      else
        @query = @query.joins("LEFT JOIN school_daily_infos ON student_daily_infos.report_date = school_daily_infos.report_date AND schools.id = school_daily_infos.school_id")
                     .joins("JOIN (SELECT MAX(total_enrolled) as max_enrolled, school_id
                             FROM school_daily_infos
                             GROUP BY school_id) as max_school_enrollment ON max_school_enrollment.school_id = schools.id")
      end
    else
      @query = @query.joins("JOIN schools ON schools.id = school_daily_infos.id")
      if @type == :school_district
        @query = @query.joins("JOIN school_districts ON schools.school_district_id = school_districts.id")
      else
        @query = @query.joins("JOIN (SELECT MAX(total_enrolled) as max_enrolled, school_id
                                 FROM school_daily_infos
                                 GROUP BY school_id) as max_school_enrollment on max_school_enrollment.school_id = schools.id")
      end
    end
  end

  def apply_filters
    if @params[:age].present?
      @query = @query.where("extract(year from age(students.dob)) in (?)", @params[:age])
    end

    if @params[:gender].present?
      @query = @query.where("students.gender = ?", @params[:gender])
    end

    if @params[:grade].present?
      @query = @query.where("student_daily_infos.grade in (?)", @params[:grade])
    end

    if @params[:confirmed_illness] == true
      @query = @query.where("student_daily_infos.confirmed_illness = true")
    end

    if @params[:symptoms].present?
      @query = @query
        .joins("JOIN student_reported_symptoms on student_reported_symptoms.student_daily_info_id = student_daily_infos.id")
        .joins("JOIN symptoms on symptoms.id = student_reported_symptoms.symptom_id")
        .where("symptoms.icd9_code in (?)", @params[:symptoms])
    end
  end

  def apply_date_filter start_date, end_date
    if @ili
      report_date = "student_daily_infos.report_date"
    else
      report_date = "school_daily_infos.report_date"
    end

    if start_date.present? and end_date.present?
      @query = @query.where("#{report_date} between ? and ? ", start_date, end_date)
    elsif start_date.present?
      @query = @query.where("#{report_date} >= ?", start_date)
    elsif end_date.present?
      @query = @query.where("#{report_date} <= ?", end_date)
    end
  end

  def apply_order
    if @ili
      @query = @query.order("student_daily_infos.report_date")
    elsif
      @query = @query.order("school_daily_infos.report_date")
    end
  end

  def apply_total_absent_filter
    @query = @query.where("school_daily_infos.total_absent <> 0 and school_daily_infos.total_enrolled <> 0")
  end

  def apply_group
    if @ili
      @query = @query.group("student_daily_infos.report_date")
      @query = @query.group("schools.school_district_id") if @type == :school_district
    elsif @type == :school_district
      @query = @query.group("schools.school_district_id, school_daily_infos.report_date")
    end
  end

  def apply_selects function
    if @ili
      total_absent = "count(*)"
      report_date = "student_daily_infos.report_date"
      total_enrolled = @type == :school ? "MAX(CASE WHEN total_enrolled = 0 or total_enrolled is null THEN max_enrolled ELSE total_enrolled END)" : "MAX(district_info.total_enrolled)"
    elsif @type == :school
      total_absent = "total_absent"
      report_date = "school_daily_infos.report_date"
      total_enrolled = "CASE WHEN total_enrolled = 0 or total_enrolled is null THEN max_enrolled ELSE total_enrolled END"
    else
      total_absent = "SUM(total_absent)"
      report_date = "school_daily_infos.report_date"
      total_enrolled = "SUM(total_enrolled)"
    end

    function = [function] unless function.is_a?(Array)
    @query = @query.select("stddev_pop(#{total_absent}) over (order by #{report_date} asc rows between unbounded preceding and current row) as \"deviation\"") if function.include?("std")
    @query = @query.select("avg(#{total_absent}) over (order by #{report_date} asc rows between unbounded preceding and current row) as \"average\"") if function.include?("avg")
    @query = @query.select("avg(#{total_absent}) over (order by #{report_date} asc rows between 29 preceding and current row) as \"average30\"") if function.include?("avg30")
    @query = @query.select("avg(#{total_absent}) over (order by #{report_date} asc rows between 59 preceding and current row) as \"average60\"") if function.include?("avg60")
    if function.include?("cusum")
      avg = (@query.select("AVG(#{total_absent}) OVER () as av").limit(1).first || {"av" => 0})["av"].to_f
      @query = @query.select("greatest(sum(#{total_absent} - #{avg}) over (order by #{report_date} rows between unbounded preceding and current row),0) as \"cusum\"")
    end

    @query = @query.select("#{report_date} as report_date")
      .select(%{#{total_absent} as "absent", #{total_enrolled} as "enrolled",
              CAST(#{total_absent} as FLOAT)/CAST(GREATEST(#{total_enrolled}, 1) as FLOAT) as pct})
  end

  def param_setup
    case @params[:span]
    when 'month' then @params[:startdt] ||= 1.month.ago.to_s
    when '6month' then @params[:startdt] ||= 6.months.ago.to_s
    when 'year' then @params[:startdt] ||= 1.year.ago.to_s
    else
      @params[:startdt] ||= 3.months.ago.to_s
      @params[:span] = '3month'
    end

    @params[:enddt] ||= Date.today.to_s

    @params[:gender] = @params[:gender] =~ /^M/ ? 'M' : 'F' if @params[:gender].present?

    if @params[:absent].present? && @params[:absent] == "Confirmed Illness"
      @params[:confirmed_illness] = true
    end

    @ili = @ili || @params[:age].present? || @params[:gender].present? || @params[:grade].present? || @params[:confirmed_illness] == true || @params[:symptoms].present?
  end
end
