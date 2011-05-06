require 'spec_helper'

describe TournamentsHelper do
  describe '#result_class' do
    let(:match) { Factory.build(:match) }

    it 'should return the class winner when they are the winner' do
      match.update_attributes(player_1_wins: 1)

      helper.result_class(match, 1).should == 'winner'
    end

    it 'should return the class loser when they are the loser' do
      match.update_attributes(player_2_wins: 1)

      helper.result_class(match, 1).should == 'loser'
    end

    it 'should return the class draw if it is a draw' do
      match.update_attributes(draws: 2)

      helper.result_class(match, 1).should == 'draw'
    end

    it 'should not return a class if it has not finished yet' do
      helper.result_class(match, 1).should be_nil
    end
  end

  describe '#tournament_status' do
    let(:tournament) { Factory.build(:tournament) }

    it 'should return an empty string if there are no players' do
      tournament_status(tournament).should == ''
    end

    it 'should list the number of players' do
      subject = tournament
      Factory.create(:player, tournament: subject)
      tournament_status(subject).should == '1 player'

      3.times { Factory.create(:player, tournament: subject) }

      tournament_status(subject).should == '4 players'
    end

    it 'should list the number of completed and total matches, if any are completed' do
      subject = Factory.create(:tournament, current_round: 3, total_rounds: 4)
      tournament_status(subject).should == '; 3 of 4 rounds complete'
    end

    it 'should list both players and matches' do
      subject = Factory.create(:tournament, current_round: 1, total_rounds: 2)
      4.times { Factory.create(:player, tournament: subject) }

      tournament_status(subject).should == '4 players; 1 of 2 rounds complete'
    end
  end
end
