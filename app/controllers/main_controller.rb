class MainController < ApplicationController
  def index
    @school_districts = SchoolDistrict.select("school_districts.name, school_districts.id,
                                               CAST(SUM(school_daily_infos.total_absent) as FLOAT)/CAST(GREATEST(SUM(school_daily_infos.total_enrolled), 1) as FLOAT) as pct")
                                      .joins("JOIN schools ON school_districts.id = schools.school_district_id
                                              JOIN school_daily_infos ON schools.id = school_daily_infos.school_id
                                              JOIN school_district_users ON school_districts.id = school_district_users.school_district_id
                                              JOIN (SELECT school_districts.id, MAX(school_daily_infos.report_date) as report_date
                                                    FROM school_districts
                                                    JOIN schools ON school_districts.id = schools.school_district_id
                                                    JOIN school_daily_infos ON schools.id = school_daily_infos.school_id
                                                    GROUP BY school_districts.id
                                              ) as most_recent ON most_recent.id = school_districts.id AND most_recent.report_date = school_daily_infos.report_date")
                                      .where("school_district_users.user_id = ?", current_user.id)
                                      .group("school_districts.id, school_districts.name")

    @schools = School.select("schools.display_name, schools.id,
                              CAST(SUM(school_daily_infos.total_absent) as FLOAT)/CAST(GREATEST(SUM(school_daily_infos.total_enrolled), 1) as FLOAT) as pct")
                      .joins("JOIN school_daily_infos ON schools.id = school_daily_infos.school_id
                              LEFT JOIN school_district_users USING (school_district_id)
                              LEFT JOIN school_users ON schools.id = school_users.school_id
                              JOIN (SELECT schools.id, MAX(school_daily_infos.report_date) as report_date
                                    FROM schools
                                    JOIN school_daily_infos ON schools.id = school_daily_infos.school_id
                                    GROUP BY schools.id
                              ) as most_recent ON most_recent.id = schools.id AND most_recent.report_date = school_daily_infos.report_date")
                      .where("school_district_users.user_id = :user_id OR school_users.user_id = :user_id", user_id: current_user.id)
                      .group("schools.id, schools.display_name")
                      .order("pct DESC")
                      .limit(10)
  end
end
