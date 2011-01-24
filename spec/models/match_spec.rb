require 'spec_helper'

describe Match do
  describe 'name helpers' do
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

  describe 'before save' do
    let(:match) { Factory.create(:match) }

    it 'should set player 1 as the winner when they have more wins' do
      match.update_attributes(player_1_wins: 2, player_2_wins: 0)

      match.winner.should == 1
    end

    it 'should set player 2 as the winner when they have more wins' do
      match.update_attributes(player_1_wins: 0, player_2_wins: 2)

      match.winner.should == 2
    end

    it 'should mark it a draw if neither player has more wins' do
      match.update_attributes(player_1_wins: 0, player_2_wins: 2)

      match.winner.should == 2
    end
  end
end