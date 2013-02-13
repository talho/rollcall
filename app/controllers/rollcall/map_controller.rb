class Rollcall::MapController < Rollcall::RollcallAppController
  respond_to :json
  layout false
  def index
    @start = 8.days.ago.to_date
    @end = 1.days.ago.to_date

    if params[:school_district].present?
      @results = get_by_school_district 
    else
      @results = get_by_school
    end

    respond_with(@results, @start, @end)
  end

  private
  
  def get_by_school_district
    flat_results = Rollcall::SchoolDistrict
      .joins("inner join (select report_date, district_id, sum(total_absent) as total_absent, sum(total_enrolled) as total_enrolled from rollcall_school_daily_infos inner join rollcall_schools on rollcall_schools.id = school_id group by report_date, district_id) as totals on totals.district_id = rollcall_school_districts.id")
      .joins("inner join (select district_id, (atan2(avg(cos(gmap_lat * pi() / 180) * sin(gmap_lng * pi() / 180)), avg(cos(gmap_lat * pi() / 180) * cos(gmap_lng * pi() / 180)))) * 180 / pi() as gmap_lng, (atan2(avg(sin(gmap_lat * pi() / 180)), sqrt(avg(cos(gmap_lat * pi() / 180) * cos(gmap_lng * pi() / 180)) ^ 2 + avg(cos(gmap_lat * pi() / 180) * sin(gmap_lng * pi() / 180)) ^ 2))) * 180 / pi() as gmap_lat from rollcall_schools where district_id is not null group by district_id) as sdc on sdc.district_id = rollcall_school_districts.id")
      .where("report_date >= ? and report_date <= ?", @start, @end)
      .where("total_enrolled <> 0")
      .select("name as display_name, sdc.gmap_lat, sdc.gmap_lng, rollcall_school_districts.id, report_date")
      .select("round(Cast(total_absent as float) / Cast(total_enrolled as float) * 100) as weight")      
      .order("report_date, rollcall_school_districts.id")
      .all
      
    process_query flat_results
  end

  def get_by_school
    flat_results = Rollcall::School
      .joins("inner join rollcall_school_daily_infos i on i.school_id = rollcall_schools.id")
      .where("report_date >= ? and report_date <= ?", @start, @end)
      .where("total_enrolled <> 0")
      .where("gmap_lat is not null and gmap_lng is not null")
      .select("display_name, gmap_lat, gmap_lng, rollcall_schools.id, report_date")
      .select("round(Cast(total_absent as float) / Cast(total_enrolled as float) * 100) as weight")
      .order("report_date, rollcall_schools.id")
      .all    

    process_query flat_results
  end
  
  def process_query(flat_results)
    iterator_date = flat_results[0][:report_date]
    schools = Array.new
    results = Array.new
  
    flat_results.each_with_index do |s, i|

      if flat_results.count - 1 == i
        schools.push(s)
        results.push({record_date: iterator_date, schools: schools})
      end

      if iterator_date != s.report_date
        results.push({record_date: iterator_date, schools: schools})
        schools = Array.new
        iterator_date = s.report_date
      else
        schools.push(s)
      end
    end
    
    return results
  end
end