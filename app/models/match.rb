class Match
  include Mongoid::Document

  field :round, type: Integer
  field :player_1_id
  field :player_2_id
  field :winner, type: Integer
  field :player_1_wins, type: Integer, default: 0
  field :player_2_wins, type: Integer, default: 0
  field :draws, type: Integer, default: 0

  embedded_in :tournament, inverse_of: :matches

  before_save do
    return if new_record?

    self.winner = case player_1_wins <=> player_2_wins
      when -1 then 2
      when 0 then -1
      else 1
    end
  end

  def player_1
    tournament.players.find(player_1_id)
  end

  def player_1=(player)
    self.player_1_id = player.id
  end

  def player_1_name
    player_1.name
  end

  def player_2
    player_2_id && tournament.players.find(player_2_id)
  end

  def player_2=(player)
    self.player_2_id = player && player.id
  end

  def player_2_name
    (p = player_2) ? p.name : 'BYE'
  end

  def winner?(player)
    (winner == 1 && player_1_id == player.id) ||
    (winner == 2 && player_2_id == player.id)
  end

  def draw?
    winner == -1
  end
end
