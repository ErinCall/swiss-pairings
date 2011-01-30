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
end
