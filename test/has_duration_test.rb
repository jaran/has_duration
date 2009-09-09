require 'test/unit'
require 'rubygems'
gem 'activerecord', '>= 1.15.4.7794'
require 'active_record'

require "#{File.dirname(__FILE__)}/../init"

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :dummies do |t|
      t.column :duration, :integer
      t.column :duration_hours, :integer
      t.column :duration_minutes, :integer
      t.column :duration_seconds, :integer
    end
  end
  
  ActiveRecord::Schema.define(:version => 1) do
    create_table :required_dummies do |t|
      t.column :duration, :integer
      t.column :duration_hours, :integer
      t.column :duration_minutes, :integer
      t.column :duration_seconds, :integer
    end
  end
  
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

class Dummy < ActiveRecord::Base
  has_duration :duration
  
end

class RequiredDummy < ActiveRecord::Base
  has_duration :duration, :allow_nil => false
end

class HasDurationTest < Test::Unit::TestCase
  def setup
    setup_db
  end

  def teardown
    teardown_db
  end

  def test_hour
    dummy = Dummy.new
    dummy.duration_hours = 1
    assert dummy.save
    assert dummy.duration == 3600
    assert dummy.duration_hours == 1
  end
  
  def test_minute
    dummy = Dummy.new
    dummy.duration_minutes = 1
    assert dummy.save
    assert dummy.duration == 60
  end
  
  def test_second
    dummy = Dummy.new
    dummy.duration_seconds = 1
    assert dummy.save
    assert dummy.duration == 1
  end
  
  def test_required
    dummy = RequiredDummy.new
    assert dummy.save == false
    dummy.duration_hours = 1
    assert dummy.save
  end
  
  def test_extraction
    dummy = Dummy.new
    dummy.duration = 3661
    assert dummy.save
    assert dummy.duration_hours == 1
    assert dummy.duration_minutes == 1
    assert dummy.duration_seconds == 1
  end
  
  def test_hour_validation
    dummy = Dummy.new
    dummy.duration_hours = "HH"
    assert dummy.save == false
  end
  
  def test_minute_validation
    dummy = Dummy.new
    dummy.duration_minutes = "MM"
    assert dummy.save == false
    dummy = Dummy.new
    dummy.duration_minutes = 60
    assert dummy.save == false
  end
  
  def test_minute_validation
    dummy = Dummy.new
    dummy.duration_seconds = "SS"
    assert dummy.save == false
    dummy = Dummy.new
    dummy.duration_seconds = 60
    assert dummy.save == false
  end
  
end