require 'spec_helper'

describe Match do
  let(:tournament) { Factory.create(:tournament) }
  let(:player) { Factory.create(:player, tournament: tournament, name: 'Drew') }

  describe '#player_1_name' do
    it 'should return the name of the first player' do
      match = Factory.create(:match, tournament: tournament, player_1_id: player.id)
      
      match.player_1_name.should == 'Drew'
    end
  end

  describe '#player_2_name' do
    it 'should return the name of the second player' do
      match = Factory.create(:match, tournament: tournament, player_2_id: player.id)
      
      match.player_2_name.should == 'Drew'
    end

    it 'should return BYE when there is no second player' do
      match = Factory.create(:match, tournament: tournament)
      
      match.player_2_name.should == 'BYE'
    end
  end
end
