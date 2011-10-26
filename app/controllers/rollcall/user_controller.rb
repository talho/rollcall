class Rollcall::UserController < Rollcall::RollcallAppController
  before_filter :rollcall_admin_required

  def index
    if params.count == 2
      @results = []
    else
      params[:conditions].delete_if{|k,v| v.blank?} if params[:conditions]
      params[:with].delete_if{|k,v| v.blank?} if params[:with]
      unless params[:name].blank? || params[:name].index('@').nil?
        params[:conditions][:email] = params[:name]
        params.delete(:name)
      end
      sanitize(params[:conditions])
      params[:with] = Hash.new if !params.has_key?(:with)
      params[:with][:applications] = current_user.roles.map{|r| r.application.to_crc32 }
      if params[:admin_mode] == "1"
        if !params[:with].has_key?(:jurisdiction_ids)
          params[:with][:jurisdiction_ids] = Array.new
          current_user.jurisdictions.admin.each { |j|
            j.self_and_descendants.each { |jsub| params[:with][:jurisdiction_ids].push(jsub.id) }
          }
        end
      end
      params[:conditions][:phone].gsub!(/([^0-9*])/,"") unless params[:conditions].blank? || params[:conditions][:phone].blank?
      Role.find_all_by_application("rollcall").each{|r| params[:with][:role_ids].push(r.id) if r.name != "Admin"}
      params.merge!(build_options(params))
      @results = User.search(params)
    end
    respond_to do |format|
     format.json do
       for_admin = current_user.is_admin?
       @results ||= []
       render :json => { :success => true,
                         :results => @results.collect {|u| u.to_json_results_rollcall(for_admin)},
                         :total   => @results.total_entries}
     end
   end
  end

  def create
    u       = User.find_by_id({:user_id => params[:user_id]})
    p_u_s   = params[:user_schools]
    p_u_s_d = params[:user_school_district]
    u_s     = Rollcall::UserSchool.find_or_create_by_user_id_and_school_id({:user_id => u.id, :school_id => params[:school_id]})
    u_s_d   = Rollcall::UserSchoolDistrict.find_or_create_by_user_id_and_school_district_id({:user_id => u.id, :school_district_id => params[:school_district_id]})
    respond_to do |format|
      format.json do
        render :json => {
          :success => !u.blank?
        }
      end
    end
  end

  # PUT rollcall/users/:id
  def update
    unless params[:school_id].blank?
      result = Rollcall::UserSchool.find_or_create_by_user_id_and_school_id({
        :user_id => params[:id],
        :school_id => params[:school_id]
      })
    end
    unless params[:school_district_id].blank?
      result = Rollcall::UserSchoolDistrict.find_or_create_by_user_id_and_school_district_id({
        :user_id => params[:id],
        :school_district_id => params[:school_district_id]
      })  
    end
#    u       = User.find_by_id params[:id]
#    p_u_s   = params[:user_schools]
#    p_u_s_d = params[:user_school_district]
#    u_s     = Rollcall::UserSchool.find_all_by_user_id u.id
#    u_s_d   = Rollcall::UserSchoolDistrict.find_all_by_user_id u.id
#    p_u_s.each{|pus|
#      u_s.each{|us|
#        if us.id == pus[:id]
#          u_s.delete(us)
#          p_u_s.delete(pus)
#        end
#      }
#    }
#    p_u_s_d.each{|pusd|
#      u_s_d.each{|usd|
#        if usd.id == pusd[:id]
#          u_s_d.delete(usd)
#          p_u_s_d.delete(pusd)
#        end
#      }
#    }
#    u_s.each{|us|
#      us.destroy
#    }
#    p_u_s.each{|pus|
#      Rollcall::UserSchool.create(:user_ud => u.id, :school_id => pus[:school_id])
#    }
#    u_s_d.each{|usd|
#      usd.destroy
#    }
#    p_u_s_d.each{|pusd|
#      Rollcall::UserSchoolDistrict.create(:User_id => u.id, :school_district_id => pusd[:school_district_id])
#    }
    # DEVNOTE: How do we calculate success
    respond_to do |format|
      format.json do
        render :json => {
          :success => !result.blank?
        }
      end
    end
  end

  #DELETE /rollcall/users/:id
  def destroy
    u = User.find_by_id params[:id]
    unless params[:school_id].blank?
      Rollcall::UserSchool.find_all_by_user_id_and_school_id(u.id, params[:school_id]).each{|us|
        us.destroy
      }
    end
    unless params[:school_district_id].blank?
      Rollcall::UserSchoolDistrict.find_all_by_user_id_and_school_district_id(u.id, params[:school_district_id]).each{|usd|
        usd.destroy
      }
    end
    respond_to do |format|
      format.json do
        render :json => {
          :success => true
        }
      end
    end
  end

  def get_user_school_districts
    results = current_user.school_districts
    respond_to do |format|
      format.json do
        render :json => {
          :success       => true,
          :total_results => results.length,
          :results       => results.as_json
        }
      end
    end
  end
  protected

  def sanitize(conditions,exclude=[:phone])
    return unless conditions
    email = /[:"\*\!&]/
    other = /[:"@\-\*\!\~\&]/
    conditions.reject{ |k,v| exclude.include? k }.each do |k,v|
      regexp = (k == "email") ? email : other
      conditions[k] = v.gsub(regexp,'') unless conditions[k].blank?
    end
  end

  def build_options(params)
    #  map EXT params to Sphinx params
    unless params[:limit].blank?
        params[:per_page] =  params.delete(:limit)
    end
    unless params[:start].blank?
      params[:page] = (params.delete(:start).to_i / params[:per_page].to_i).floor + 1
    end
    unless params[:dir].blank?
      params[:sort_mode] = params.delete(:dir).downcase.to_sym
    else
      params[:sort_mode] = :asc
    end

    options = HashWithIndifferentAccess.new(
      :retry_stale => true,                                        # avoid nil results
      :order => :last_name,                                        # ascending order on name
      :sort_mode => params[:sort_mode],
      :page => params[:page] ? params[:page].to_i : 1,             # paginate pages
      :per_page => params[:per_page] ? params[:per_page].to_i : 8, # paginate entries per page
      :star => true                                                # auto wildcard
    )
    if %w(pdf csv).include?(params[:format])
      options[:per_page] = 30000
      options[:max_matches] = 30000
    end
    return options
  end
end