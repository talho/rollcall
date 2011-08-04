class DataTransformer
  def self.transform
    Rollcall::SchoolDailyInfo.find_each do |sdi|
      sdi.total_absent   = varyData(sdi.total_absent)
      sdi.total_enrolled = varyData(sdi.total_enrolled)
      sdi.save
    end
  end

  private
  def self.varyData value
    variance = 10.0
    (value * (1.0 + (rand(variance) * 0.02 - (variance * 0.01)))).to_i
  end
end