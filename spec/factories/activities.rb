# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :activity do
    activity_type
    user
    date "2013-06-12"
    duration 1
    description "MyText"
    customer_id 1
    project_id 1
    redmine_ticket_id 1
    otrs_ticket_id 1
  end
end
