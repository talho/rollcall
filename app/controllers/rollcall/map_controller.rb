
class Rollcall::MapController < Rollcall::RollcallAppController
  respond_to :json
  layout false
  
  def index
    @start = 7.days.ago.to_date
    @end = DateTime.now.to_date
    @results = Array.new
    
    flat_results = Rollcall::School
      .joins("inner join rollcall_school_daily_infos i on i.school_id = rollcall_schools.id")
      .where("report_date between ? and ?", @start, @end)
      .where("total_enrolled <> 0")
      .where("gmap_lat is not null and gmap_lng is not null")
      .select("display_name, gmap_lat, gmap_lng, rollcall_schools.id, report_date")      
      .select("round(Cast(total_absent as float) / Cast(total_enrolled as float) * 100) as weight")
      .order("report_date")
      .all
      
    iterator_date = flat_results[0][:report_date]
    schools = Array.new
    
    flat_results.each_with_index do |s, i|
      
      if flat_results.count == i - 1
        schools.push(s)
        @results.push({record_date: iterator_date, schools: schools})
      end
      
      if iterator_date != s.report_date
        @results.push({record_date: iterator_date, schools: schools})
        schools = Array.new
        iterator_date = s.report_date
      else
        schools.push(s)
      end            
    end
    
    respond_with(@results, @start, @end)
  end
end