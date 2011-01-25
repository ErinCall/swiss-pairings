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
end
