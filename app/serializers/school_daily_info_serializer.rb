class SchoolDailyInfoSerializer < ActiveModel::Serializer
  attributes :report_date, :absent, :enrolled, :pct, :deviation, :average, :average30, :average60, :cusum

  def deviation
    object[:deviation]
  end

  def average
    object[:average]
  end

  def average30
    object[:average30]
  end

  def average60
    object[:average60]
  end

  def cusum
    object[:cusum]
  end
end
