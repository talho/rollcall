class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :school_users
  has_many :school_district_users
  has_many :schools, through: :school_users
  has_many :school_districts, through: :school_district_users

  after_create :claim_schools_and_districts

  protected
  def claim_schools_and_districts
    SchoolDistrictUser.where(email: self.email).update_all(user_id: self.id)
    SchoolUser.where(email: self.email).update_all(user_id: self.id)
  end
end
