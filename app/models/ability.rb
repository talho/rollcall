class Ability
  include CanCan::Ability

  def initialize(user)
    can :create, SchoolDistrict
    can :manage, SchoolDistrict do |sd|
      sd.school_district_users.where(user_id: user.id, role: 1).exists?
    end
    can :read, SchoolDistrict, :school_district_users => {:user_id => user.id}

    can :read, School, :school_users => {:user_id => user.id}
    can :read, School, :school_district => {:school_district_users => {:user_id => user.id}}
    can :create, School do |s|
      can? :manage, s.school_district
    end
    can :manage, School do |s|
      s.school_users.where(user_id: user.id, role: 1).exists? || can?(:manage, s.school_district)
    end

    can [:create, :destroy], SchoolDistrictUser do |sdu|
      can? :manage, sdu.school_district
    end
    can [:create, :destroy], SchoolUser do |su|
      can? :manage, su.school
    end

    can :manage, SchoolDailyInfo do |sdi|
      can? :read, sdi.school
    end
    can :manage, StudentDailyInfo do |sdi|
      can? :read, sdi.student.school
    end
  end
end
