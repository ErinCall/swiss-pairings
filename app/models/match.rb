class Match
  include Mongoid::Document

  field :round, type: Integer
  field :player_1_id
  field :player_2_id

  embedded_in :tournament, inverse_of: :matches

  def player_1_name
    tournament.players.find(player_1_id).name
  end

  def player_2_name
    player_2_id ? tournament.players.find(player_2_id).name : 'BYE'
  end
end
