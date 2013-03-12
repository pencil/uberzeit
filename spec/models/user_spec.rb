require 'spec_helper'

describe User do

  let(:user) { FactoryGirl.create(:user) }
  let(:leader) { FactoryGirl.create(:leader) }

  it 'has a valid factory' do
    FactoryGirl.build(:user).should be_valid
  end

  it 'provides subordinates' do
    leader.subordinates.length.should eq(leader.teams.first.members.length)
  end

  it 'acts as paranoid' do
    user.destroy
    expect { User.find(user.id) }.to raise_error
    expect { User.with_deleted.find(user.id) }.to_not raise_error
  end

  it 'ensures that at least one time sheet exists' do
    user = FactoryGirl.create(:user, with_sheet: false)
    2.times { user.ensure_timesheet_and_employment_exist }
    user.time_sheets.count.should eq(1)
  end

  it 'ensures that at least one employment exists' do
    user = FactoryGirl.create(:user, with_employment: false)
    2.times { user.ensure_timesheet_and_employment_exist }
    user.time_sheets.count.should eq(1)
  end

  describe '#create_with_omniauth' do
    context 'without extra attributes' do

      let(:omniauth_hash) { {'uid' => 'user-one'} }

      it 'can be created' do
        User.create_with_omniauth(omniauth_hash).should be_persisted
      end
    end
    context 'with extra attributes' do

      let(:omniauth_hash) { {'uid' => 'user-one', 'info' => {'name' => 'Super User'}} }

      subject { User.create_with_omniauth(omniauth_hash) }

      it { should be_persisted }
      its(:name) { should eq('Super User') }

    end
  end

  describe '#current_time_sheet' do

    it 'returns the current active timesheet' do
      user.current_time_sheet.should eq(user.time_sheets.first)
    end

  end

end
