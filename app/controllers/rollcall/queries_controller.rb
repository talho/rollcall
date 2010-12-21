class Rollcall::QueriesController < Rollcall::RollcallAppController
  helper :rollcall
  before_filter :rollcall_required

  def index
    results      = Rollcall::AbsenteeReport.search(params)
    options      = {:page => params[:page] || 1, :per_page => params[:limit] || 6}
    results_uniq = results.blank? ? results.paginate(options) : results.paginate(options)
    respond_to do |format|
      format.json do
        render :json => {
          :success       => true,
          :total_results => results.length,
          :results       => results_uniq.as_json
        }
      end
    end
  end
  
  def create
    results = Rollcall::AbsenteeReport.render_graphs(params)
    schools = params["results"]["schools"].blank? ? "" : params["results"]["schools"]
    respond_to do |format|
      format.json do
        render :json => {
          :success       => true,
          :total_results => results.length,
          :results       => {:id => 2, :img_urls => results, :schools => schools}.as_json
        }
      end
    end
  end

  def export
    results = Rollcall::AbsenteeReport.export_rrd_data(params)
    #results      = "Trying,out,this,csv,thing"
    #options      = {:page => params[:page] || 1, :per_page => params[:limit] || 6}
    #results_uniq = results.blank? ? results.paginate(options) : results.paginate(options)
    send_data "Trying,out,this,csv,thing", :type => 'application/csv', :filename => "example.csv"
  end
  
end