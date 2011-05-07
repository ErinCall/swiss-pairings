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

  describe '#opponents' do
    subject { Factory.create(:player, name: 'subject') }
    let(:opponent) { Factory.create(:player, tournament: subject.tournament, name: 'opponent') }
    let(:bye_guy)  { Factory.create(:player, tournament: subject.tournament, name: 'bye guy') }

    it 'should return a list of past opponents' do
        Factory.create(:match, tournament: subject.tournament, player_1: subject, player_2: opponent);

        subject.opponents.should == [ opponent ]
    end
  end

  describe '#match_win_percentage' do
    subject { Factory.create(:player, name: 'subject') }
    let(:opponent)  { Factory.create(:player, tournament: subject.tournament, name: 'opponent') }

    it 'should return the percentage of matches won' do
      Factory.create(:match, tournament: subject.tournament,
        player_1: subject,
        player_2: opponent,
        player_1_wins: 2,
      );

      Factory.create(:match, tournament: subject.tournament,
        player_1: subject,
        player_2: opponent,
        player_2_wins: 2,
      );

      Factory.create(:match, tournament: subject.tournament,
        player_1: subject,
        player_2: opponent,
        player_1_wins: 2,
      );

      subject.match_win_percentage.should == (2.0/3);
    end

    it 'should be affected by drawn matches' do
      Factory.create(:match, tournament: subject.tournament, player_1: subject, player_2: opponent, player_1_wins: 2,);
      Factory.create(:match, tournament: subject.tournament, player_1: subject, player_2: opponent, player_2_wins: 2,);

      Factory.create(:match, tournament: subject.tournament,
        player_1: subject,
        player_2: opponent,
        player_1_wins: 1,
        player_2_wins: 1,
        draws: 1,
      );

      subject.match_win_percentage.should == (3.0+1)/(3*3);
    end

    it 'should return zero if no matches have been played' do
      subject.match_win_percentage.should == (0.0);
    end

    it 'should never be less than 0.33' do
      Factory.create(:match, tournament: subject.tournament,
        player_1: subject,
        player_2: opponent,
        player_2_wins: 1
      )

      subject.match_win_percentage.should == (0.33);
    end
  end

  describe '#opponents_match_win_percentage' do
    subject { Factory.create(:player, name: 'subject') }
    let(:opponent1)  { Factory.create(:player, tournament: subject.tournament, name: 'opponent1') }
    let(:opponent2)  { Factory.create(:player, tournament: subject.tournament, name: 'opponent2') }

    it 'should return zero if no matches have been played' do
      subject.opponents_match_win_percentage.should == (0.0);
    end

    it "should return the average of all opponents' match-win-percentage" do
      Factory.create(:match, tournament: subject.tournament, player_1: subject, player_2: opponent1)
      Factory.create(:match, tournament: subject.tournament, player_1: subject, player_2: opponent2)
      
      opponent1.stub(:match_win_percentage) { 0.7 }
      opponent2.stub(:match_win_percentage) { 0.4 }

      subject.opponents_match_win_percentage.should == ((0.7+0.4)/2)
    end
  end

  describe '#game_win_percentage' do
    subject        { Factory.create(:player, name: 'subject') }
    let(:opponent) { Factory.create(:player, name: 'opponent', tournament: subject.tournament) }

    it 'should return zero if no matches have been played' do
      subject.game_win_percentage.should == (0.0);
    end

    it 'should equal the number of points earned divided by three times the number of matches' do
      Factory.create(:match, tournament: subject.tournament, player_1: subject, player_2: opponent,
        player_1_wins: 2,
        player_2_wins: 1,
      )
      Factory.create(:match, tournament: subject.tournament, player_1: subject, player_2: opponent,
        player_1_wins: 1,
        player_2_wins: 1,
        draws: 1,
      )

      subject.game_win_percentage.should == (6.0+3.0+1)/(3*6)
    end
  end

  describe '#opponents_game_win_percentage' do
    subject        { Factory.create(:player, name: 'subject') }

    it 'should return zero if no matches have been played' do
      subject.opponents_game_win_percentage.should == (0.0);
    end

    it "should be the average of all a players' opponents' game-win-percentages" do
      alice = Factory.create(:player, name: 'Alice', tournament: subject.tournament)
      brent = Factory.create(:player, name: 'Brent', tournament: subject.tournament)

      Factory.create(:match, tournament: subject.tournament, player_1: subject, player_2: alice,
        player_2_wins: 2,
        draws: 1,
      )
      Factory.create(:match, tournament: subject.tournament, player_1: subject, player_2: brent,
        player_1_wins: 1,
        player_2_wins: 2,
      )

      #sanity check
      brent.game_win_percentage.should == (6.0/(3*3)) # 2/3
      alice.game_win_percentage.should == (7.0/(3*3)) # 7/9

      subject.opponents_game_win_percentage.should == ((2.0/3)+(7.0/9))/2
    end

    it "should be 0.33 at minimum" do
      alice = Factory.create(:player, name: 'Alice', tournament: subject.tournament)
      brent = Factory.create(:player, name: 'Brent', tournament: subject.tournament)

      Factory.create(:match, tournament: subject.tournament, player_1: subject, player_2: alice,
        player_1_wins: 2,
      )

      subject.opponents_game_win_percentage.should == 0.33
    end
  end
end
