# == Schema Information
#
# Table name: school_districts
#
#  id              :integer(4)      not null, primary key
#  name            :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  city            :string
#  state           :string
#  county          :string
#  state_id        :string
#

class SchoolDistrict < ActiveRecord::Base
  has_many :school_district_users
  has_many :users, through: :school_district_users

  has_many :schools, -> { order 'display_name' }

  validates :state_id, presence: true, uniqueness: {scope: :state}

  has_many :students, :through => :schools
  has_many :student_daily_infos, :through => :students
  has_many :school_daily_infos, :through => :schools

  def self.for_user(user)
    user = user.class == User ? user : User.find(user)
    roles = Role.admin('rollcall').id.to_s + ',' + Role.superadmin('rollcall').id.to_s
    districts = self
      .joins("left join rollcall_user_school_districts U on U.school_district_id = rollcall_school_districts.id")
      .joins("left join (Jurisdictions J2 " +
        "inner join Jurisdictions J1 on J2.lft between J1.lft and J1.rgt " +
        "inner join role_memberships RM on RM.jurisdiction_id = J1.id) on rollcall_school_districts.jurisdiction_id = J2.id")
      .where("(RM.user_id = #{user.id} and RM.role_id in (#{roles}) and J2.id is not null)" +
        "or (U.id is not null and U.user_id = #{user.id})")
      .uniq
    districts
  end

  def get_graph_data(params)
    graph_data = Rollcall::SchoolDistrict
      .where('rollcall_school_districts.id' => id)

    build_graph_query graph_data, params
  end

  # Method returns zipcode
  #
  # Method returns zipcodes for selected School District
  def zipcodes
    schools.select("postal_code").uniq.reorder(:postal_code).pluck(:postal_code)
  end

  # Method returns school types
  #
  # Method will return school types for selected school district
  def school_types
    schools.select("school_type").uniq.order(:school_type).pluck(:school_type)
  end

  def self.get_neighbors(school_district_id)
    neighbors = self
      .select("*, case id when #{school_district_id} then name else concat((select name from rollcall_school_districts where id = #{school_district_id}), ' Neighbor: ', name) end as title")
      .where("jurisdiction_id = (select jurisdiction_id from rollcall_school_districts where id = ?)", school_district_id)
      .order("case id when #{school_district_id} then 1 else 7 end, name")

    neighbors
  end
end
