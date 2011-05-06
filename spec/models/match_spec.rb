require 'spec_helper'

describe Match do
  describe 'name helpers' do
    let(:tournament) { Factory.create(:tournament) }
    let(:player) { Factory.create(:player, tournament: tournament, name: 'Drew') }

    describe '#player_1_name' do
      it 'should return the name of the first player' do
        match = Factory.create(:match, tournament: tournament, player_1: player)

        match.player_1_name.should == 'Drew'
      end
    end

    describe '#player_2_name' do
      it 'should return the name of the second player' do
        match = Factory.create(:match, tournament: tournament, player_2: player)

        match.player_2_name.should == 'Drew'
      end

      it 'should return BYE when there is no second player' do
        match = Factory.create(:match, tournament: tournament, player_2: nil)

        match.player_2_name.should == 'BYE'
      end
    end
  end

  describe '#winner?' do
    let(:player) { Factory.create(:player) }
    subject { match = Factory.create(:match, tournament: player.tournament, player_1: player) }

    it 'should return true if the player won the match' do
      subject.update_attributes(player_1_wins: 1)

      subject.winner?(player).should be_true
    end

    it 'should return false if the player lost the match' do
      subject.update_attributes(player_2_wins: 1)

      subject.winner?(player).should be_false
    end

    it 'should return false if the player drew the match' do
      subject.update_attributes(draws: 1)

      subject.winner?(player).should be_false
    end

    it 'should return true if the player got a bye' do
      subject.update_attributes(player_2_id: nil)

      subject.winner?(player).should be_true
    end
  end

  describe '#draw?' do
    let(:player) { Factory.create(:player) }
    subject { match = Factory.create(:match, tournament: player.tournament, player_1: player) }

    it 'should return false if the player 1 won the match' do
      subject.update_attributes(player_1_wins: 1)

      subject.should_not be_draw
    end

    it 'should return false if the player 2 won the match' do
      subject.update_attributes(player_2_wins: 1)

      subject.should_not be_draw
    end

    it 'should return true if the players drew the match' do
      subject.update_attributes(draws: 1)

      subject.should be_draw
    end

    it 'should return false if it was a bye' do
      subject.update_attributes(player_2_id: nil)

      subject.should_not be_draw
    end
  end

  describe '#games_played' do
    let(:player) { Factory.create(:player) }
    subject { match = Factory.create(:match, tournament: player.tournament, player_1: player) }
    
    it "should account for player 1's wins" do
      subject.update_attributes(player_1_wins: 1) 
      subject.games_played.should == 1
    end

    it 'should account for draws' do
      subject.update_attributes(draws: 1) 
      subject.games_played.should == 1
    end

    it "should account for player 2's wins" do
      subject.update_attributes(player_2_wins: 2) 
      subject.games_played.should == 2
    end
  end

  describe '#game_score' do
    let(:player_one) { Factory.create(:player) }
    let(:player_two) { Factory.create(:player) }
    subject { match = Factory.create(:match, tournament: player_one.tournament, player_1: player_one, player_2: player_two) }

    it "should account for player one's wins" do
      subject.update_attributes(player_1_wins: 2)
      subject.game_score(player_one).should == 2*3
    end

    it "should account for player two's wins" do
      subject.update_attributes(player_2_wins: 1)
      subject.game_score(player_two).should == 1*3
    end

    it "should count draws for both players" do
      subject.update_attributes(draws: 1)

      subject.game_score(player_one).should == 1
      subject.game_score(player_two).should == 1
    end
  end

  describe 'before save' do
    subject { Factory.create(:match) }

    it 'should set player 1 as the winner when they have more wins' do
      subject.update_attributes(player_1_wins: 2, player_2_wins: 0)

      subject.winner.should == 1
    end

    it 'should set player 2 as the winner when they have more wins' do
      subject.update_attributes(player_1_wins: 0, player_2_wins: 2)

      subject.winner.should == 2
    end

    it 'should mark it a draw if neither player has more wins' do
      subject.update_attributes(player_1_wins: 0, player_2_wins: 2)

      subject.winner.should == 2
    end
  end
end
