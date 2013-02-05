
class Rollcall::MapController < Rollcall::RollcallAppController
  respond_to :json
  layout false
  
  def index    
    @schools = Rollcall::School
      .joins("inner join (select sum(total_absent) as absent, sum(total_enrolled) as enrolled, school_id from rollcall_school_daily_infos where total_enrolled <> 0 and report_date between '#{7.days.ago}' and '#{DateTime.now}' group by school_id) as sum on sum.school_id = id")      
      .where("gmap_lat is not null and gmap_lng is not null")      
      .select("display_name, gmap_lat, gmap_lng, rollcall_schools.id")      
      .select("round(Cast(absent as float) / Cast(enrolled as float) * 100) as weight")          
    
    respond_with(@schools)
  end
end