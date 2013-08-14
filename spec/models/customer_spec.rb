# == Schema Information
#
# Table name: customers
#
#  id           :integer          primary key
#  name         :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  abbreviation :string(255)
#

require 'spec_helper'

describe Customer do
  subject { FactoryGirl.create(:customer) }

  its(:abbreviation) { should eq('yolo') }
  its(:display_name) { should eq("#{subject.id}: Yolo Inc. (yolo)") }
end
