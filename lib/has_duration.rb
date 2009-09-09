module HasDuration  
  def self.included base #:nodoc:
    base.extend ClassMethods
  end
  
  module ClassMethods
    
    def has_duration(name, options = {})
      include InstanceMethods
      options.reverse_merge!({ :allow_nil => true })
      
      validates_numericality_of "#{name}_hours", :greater_than_or_equal_to => 0, :allow_nil => true
      validates_numericality_of "#{name}_minutes", :greater_than_or_equal_to => 0, :less_than_or_equal_to => 59, :allow_nil => true
      validates_numericality_of "#{name}_seconds", :greater_than_or_equal_to => 0, :less_than_or_equal_to => 59, :allow_nil => true
      validates_numericality_of "#{name}", :greater_than_or_equal_to => 0, :allow_nil => options[:allow_nil]

      attr_protected "#{name}"
      before_validation "calculate_duration_#{name}"
      
      define_method "#{name}=" do |value|
        write_attribute("#{name}", value)
        extract_duration("#{name}")
      end
      
      define_method "calculate_duration_#{name}" do 
        calculate_duration("#{name}")
      end
    end
     
  end
  
  module InstanceMethods
    def calculate_duration(name)
      hours = self.send("#{name}_hours")
      minutes = self.send("#{name}_minutes")
      seconds = self.send("#{name}_seconds")
      return if hours.nil?  && minutes.nil? && seconds.nil?
      
      total_seconds = 0
      total_seconds += hours * 3600 unless hours.nil?
      total_seconds += minutes * 60 unless minutes.nil?
      total_seconds += seconds unless seconds.nil?
      write_attribute("#{name}", total_seconds)
    end
    
    def extract_duration(name)
      total_seconds = read_attribute(name)
      return if total_seconds.nil?
      
      hours = total_seconds/3600.to_i
      minutes = (total_seconds/60 - hours * 60).to_i
      seconds = (total_seconds - (minutes * 60 + hours * 3600))
      self.send("#{name}_hours=", hours)
      self.send("#{name}_minutes=", minutes)
      self.send("#{name}_seconds=", seconds)
    end
  end
end

if Object.const_defined?("ActiveRecord")
  ActiveRecord::Base.send(:include, HasDuration)
end