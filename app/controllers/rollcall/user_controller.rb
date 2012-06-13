class Rollcall::UserController < Rollcall::RollcallAppController
  before_filter :rollcall_admin_required
  skip_before_filter :authorize, :only => [:new, :create]
  skip_before_filter :rollcall_required, :only => [:new, :create]
  skip_before_filter :rollcall_admin_required, :only => [:new, :create]
  
  respond_to :json
  layout false

  # GET rollcall/users
  def index    
    @results = User.includes(:role_memberships).where("role_memberships.role_id" => Role.where(application: 'rollcall'))
    
    unless current_user.is_super_admin?("rollcall")      
      @results = @results.where("role_memberships.role_id != ? AND role_memberships.role_id != ?", Role.admin('rollcall').id, Role.superadmin('rollcall').id)
      @results = @results.where("role_memberships.jurisdiction_id" => current_user.role_memberships.where(role_id: Role.where(application: 'rollcall')).map(&:jurisdiction_id))
    end

    respond_with(@results)
  end

  def new
    @user                            = User.new
    @user[:rollcall_jurisdiction_id] = nil
    @jurisdictions                   = Jurisdiction.all.sort_by{|j| j.name}
  end

  #POST rollcall/users
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
          SignupMailer.confirmation(@user).deliver
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
        respond_with(@success = !u.blank?)        
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