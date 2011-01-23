require 'spec_helper'

describe Tournament do
  describe 'validations' do
    before(:each) { subject.save }

    it 'should require a name' do
      subject.errors[:name].should include("can't be blank")
    end
  end
end
