require 'spec_helper'

describe Player do
  describe 'validations' do
    before(:each) { subject.save }

    it 'should require a name' do
      subject.errors[:name].should include("can't be blank")
    end
  end

  describe '#match_score' do
    it 'should count up all the match points the player has earned' do
      player = Factory.create(:player)
      Factory.create(:match, tournament: player.tournament, player_1: player, player_1_wins: 2)
      Factory.create(:match, tournament: player.tournament, player_1: player, player_1_wins: 2)
      Factory.create(:match, tournament: player.tournament, player_1: player, draws: 2)

      player.match_score.should == 7
    end
  end

  describe '#played?' do
    subject { Factory.create(:player) }
    let(:other_player) { Factory.create(:player, tournament: subject.tournament) }


    it 'should return true when a player has played another player' do
      Factory.create(:match, tournament: subject.tournament, player_1: subject, player_2: other_player)

      subject.played?(other_player).should be_true
    end

    it 'should return false when a player has not played another player' do
      subject.played?(other_player).should be_false
    end

    it 'should return false when passed itself' do 
      Factory.create(:match, tournament: subject.tournament, player_1: subject, player_2: other_player)
      subject.played?(subject).should be_false
    end
  end
end
