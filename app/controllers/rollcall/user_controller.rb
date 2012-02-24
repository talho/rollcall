class Rollcall::UserController < Rollcall::RollcallAppController
  before_filter :rollcall_admin_required
  skip_before_filter :login_required, :only => [:new, :create]
  skip_before_filter :rollcall_required, :only => [:new, :create]
  skip_before_filter :rollcall_admin_required, :only => [:new, :create]

  def index
    results  = []
    unless params[:with].blank?
      begin
        params[:with][:jurisdiction_ids] = []
        params[:with][:role_ids]         = []
        roles                            = current_user.roles.for_app("rollcall")
        RoleMembership.find_all_by_user_id(current_user.id, :conditions => ["role_id IN (?)", roles]).each{ |r|
          params[:with][:jurisdiction_ids].push(r.jurisdiction_id)
        }
        Role.find_all_by_application("rollcall").each{ |r|
          if r.name != "Admin"
            params[:with][:role_ids].push(r.id)
          elsif current_user.is_super_admin?("rollcall")
            params[:with][:role_ids].push(r.id)
          end
        }
        options = build_options(params)       
        if current_user.is_super_admin?("rollcall")
          options[:with]            = {}
          options[:with][:role_ids] = params[:with][:role_ids]
          User.search(options).each{|u| results.push(u) unless u.id == current_user.id}
        else
          options[:with] = params[:with]
          jurisdiction   = Jurisdiction.find_all_by_id(params[:with][:jurisdiction_ids])
          User.search(options).each{|u|
            jurisdiction.each{|j|
              if u.jurisdictions.include? j
                results.push(u) unless u.id == current_user.id
              end
            }
          }
        end
      rescue
      end
    end
    for_admin = current_user.is_admin?
    respond_to do |format|
      format.json do
        render :json => {
          :success => true,
          :results => results.collect {|u| u.to_json_results_rollcall(for_admin)},
          :total   => results.length
        }
      end
    end
  end

  def new
    @user                            = User.new
    @user[:rollcall_jurisdiction_id] = nil
    @jurisdictions                   = Jurisdiction.all.sort_by{|j| j.name}
  end

  def create
    unless params[:user].blank?
      jurisdiction  = params[:user]["rollcall_jurisdiction_id"].blank? ? nil : Jurisdiction.find(params[:user]["rollcall_jurisdiction_id"])
      rollcall_role = Role.find_by_name_and_application("Rollcall", 'rollcall')
      @user         = User.new params[:user]
      @user.email   = @user.email.downcase
      params[:user].delete("rollcall_jurisdiction_id")
      @user.role_memberships.build(:role=>rollcall_role, :jurisdiction=>jurisdiction, :user=>@user)
      respond_to do |format|
        if @user.save
          SignupMailer.deliver_confirmation(@user)
          format.html { redirect_to sign_in_path }
          format.xml  { render :xml => @user, :status => :created, :location => @user }
          flash[:notice] = "Thanks for signing up! An email will be sent to #{@user.email} shortly to confirm your account." +
            "Once you've confirmed you'll be able to login into the TALHO Rollcall Dashboard.\n\nIf you have any questions please email support@#{DOMAIN}."
        else
          @user[:rollcall_jurisdiction_id] = jurisdiction.blank? ? nil : jurisdiction.id
          @jurisdictions                   = Jurisdiction.all.sort_by{|j| j.name}
          format.html { render :action => "new" }
          format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
        end
      end
    else 
      if rollcall_admin_required
        u       = User.find_by_id({:user_id => params[:user_id]})
        p_u_s   = params[:user_schools]
        p_u_s_d = params[:user_school_district]
        u_s     = Rollcall::UserSchool.find_or_create_by_user_id_and_school_id({:user_id => u.id, :school_id => params[:school_id]})
        u_s_d   = Rollcall::UserSchoolDistrict.find_or_create_by_user_id_and_school_district_id({:user_id => u.id, :school_district_id => params[:school_district_id]})
        respond_to do |format|
          format.json do
            render :json => {:success => !u.blank?}
          end
        end
      end
    end
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
      Rollcall::UserSchool.find_all_by_user_id_and_school_id(u.id, params[:school_id]).each{|us| us.destroy}
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