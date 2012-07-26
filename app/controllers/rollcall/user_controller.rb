class Rollcall::UserController < Rollcall::RollcallAppController
  before_filter :rollcall_admin_required
  
  respond_to :json
  layout false

  # GET rollcall/users
  def index    
    @results = User.includes(:role_memberships => {:role => :app}).where("apps.name" => 'rollcall').paginate(:page => (params[:start].to_i/params[:limit].to_i + 1), :per_page => params[:limit])
    
    unless current_user.is_super_admin?("rollcall")      
      @results = @results.where("role_memberships.role_id != ? AND role_memberships.role_id != ?", Role.admin('rollcall').id, Role.superadmin('rollcall').id)
      @results = @results.joins("JOIN role_memberships rm ON rm.jurisdiction_id = role_memberships.jurisdiction_id").joins("JOIN roles r on rm.role_id = r.id").joins("JOIN apps a on r.app_id = a.id").where("apps.name" => 'rollcall', "rm.user_id" => current_user.id).uniq
    end

    respond_with(@results)
  end

  # PUT rollcall/users/:id
  def update
    unless params[:school_id].blank?
      result = Rollcall::UserSchool.find_or_create_by_user_id_and_school_id({
        :user_id   => params[:id],
        :school_id => params[:school_id]
      })
    end
    unless params[:school_district_id].blank?
      result = Rollcall::UserSchoolDistrict.find_or_create_by_user_id_and_school_district_id({
        :user_id            => params[:id],
        :school_district_id => params[:school_district_id]
      })  
    end    
    respond_with(@success = !result.blank?)
  end

  #DELETE /rollcall/users/:id
  def destroy
    u = User.find_by_id params[:id]
    unless params[:school_id].blank?
      Rollcall::UserSchool.find_all_by_user_id_and_school_id(u.id, params[:school_id]).each{|us| us.destroy}
    end
    unless params[:school_district_id].blank?
      Rollcall::UserSchoolDistrict.find_all_by_user_id_and_school_district_id(u.id, params[:school_district_id]).each{|usd|
        usd.destroy
      }
    end
    respond_with(@success = true)    
  end

  # Method returns school district
  #
  # Method returns school districts associated with current_user
  def get_user_school_districts
    @results = current_user.school_districts
    respond_with(@results)
  end
  protected

  # Method builds up a list of options with regards to pagination
  #
  # Method returns an object of pagination options
  def build_options(params)
    #  map EXT params to Sphinx params
    params[:per_page]  =  params.delete(:limit) unless params[:limit].blank?
    params[:page]      = (params.delete(:start).to_i / params[:per_page].to_i).floor + 1 unless params[:start].blank?
    params[:sort_mode] = params.delete(:dir).downcase.to_sym unless params[:dir].blank?
    params[:sort_mode] = :asc if params[:dir].blank?
    options            = HashWithIndifferentAccess.new(
      :retry_stale => true,                                           # avoid nil results
      :order       => :last_name,                                     # ascending order on name
      :sort_mode   => params[:sort_mode],
      :page        => params[:page] ? params[:page].to_i : 1,         # paginate pages
      :per_page    => params[:per_page] ? params[:per_page].to_i : 8, # paginate entries per page
      :star        => true                                            # auto wildcard
    )
    if %w(pdf csv).include?(params[:format])
      options[:per_page]    = 30000
      options[:max_matches] = 30000
    end
    options
  end
end