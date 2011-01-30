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
      tournament = mock_model(Tournament, win_value: 3, draw_value: 1)
      player.stub(:tournament).and_return(tournament)
      tournament.stub(:matches_for_player).with(player).and_return([
        mock_model(Match, winner?: true),
        mock_model(Match, winner?: true),
        mock_model(Match, winner?: false, draw?: true),
        mock_model(Match, winner?: false, draw?: false)
      ])

      player.match_score.should == 7
    end
  end

  describe '#played?' do
    subject { Factory.create(:player) }
    let(:tournament) { mock_model(Tournament, win_value: 3, draw_value: 1) }
    before(:each) { subject.stub(:tournament).and_return(tournament) }

    it 'should return true when a player has played another player' do
      other_player = mock_model(Match)
      tournament.stub(:matches_for_player).with(subject).and_return([
        mock_model(Match, player_1_id: other_player.id)
      ])

      subject.played?(other_player).should be_true
    end

    it 'should return false when a player has not played another player' do
      other_player = mock_model(Match)
      tournament.stub(:matches_for_player).with(subject).and_return([
        mock_model(Match, player_1_id: 'foo', player_2_id: subject.id)
      ])

      subject.played?(other_player).should be_false
    end
  end
end
