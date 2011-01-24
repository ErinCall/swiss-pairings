require 'spec_helper'

describe Tournament do
  describe 'validations' do
    before(:each) { subject.save }

    it 'should require a name' do
      subject.errors[:name].should include("can't be blank")
    end
  end

  describe '#generate_matches' do
    context 'in the first round' do
      subject { Factory.create(:tournament) }
      let(:players) { 4.times.map { Factory.create(:player, tournament: subject) } }

      before(:each) do
        subject.players.should_receive(:sort_by).and_return(players)
        subject.generate_matches
      end

      it 'should randomly assign matches' do
        should have_matches_for_round(1,
          [players[0], players[1]],
          [players[2], players[3]]
        )
      end
      
      its(:current_round) { should == 1 }
    end
  end
end
