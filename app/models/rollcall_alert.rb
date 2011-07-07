class RollcallAlert < Alert
  acts_as_MTI
  before_create :create_email_alert_device_type

  belongs_to :alarm, :class_name => "Rollcall::Alarm", :foreign_key => "alarm_id"

  def to_s
    title || ''
  end
  
  def self.default_alert
    title = "Rollcall Alarm Alert"
    message = "This message is intended to update the user on a newly created Alarm."
    Alert.new(:title => title, :message => message, :created_at => Time.zone.now)
  end

  def to_xml(options={})
    unless options[:IVRTree]
      options[:IVRTree] = {}
      options[:IVRTree][:override] = Proc.new do |ivrtree|
        ivrtree.IVR(:name => 'message_ivr') do |ivr|
          ivr.RootNode(:operation => 'start') do |root_node|
            root_node.ContextNode do |ctxt|
              ctxt.operation 'put'
              ctxt.response(:ref => 'message')
            end
          end
        end
      end
    end
    
    unless options[:Behavior]
      options.merge!({:Behavior => {:Delivery => {:Providers => {} } } })
      options[:Behavior][:Delivery][:Providers][:override] = Proc.new do |providers|
        (self.alert_device_types.map{|device| device.device_type.display_name} || Service::TALHO::Message::SUPPORTED_DEVICES.keys).each do |device|
          providers.Provider(:name => "talho", :device => device, :ivr => 'message_ivr')
        end
      end
    end
    
    super(options)
  end

  private
  def set_alert_type
    self[:alert_type] = "RollcallAlert"
  end

  def create_email_alert_device_type
    alert_device_types << AlertDeviceType.new(:alert_id => self.id, :device => "Device::EmailDevice") unless alert_device_types.map(&:device).include?("Device::EmailDevice")  
  end  
end