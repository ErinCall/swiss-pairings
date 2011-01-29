class SwissPairer
  def initialize(tournament)
    @tournament = tournament
  end


  def generate_matches
    groups = @tournament.players.group_by { |p| p.match_score }
    scores = groups.keys.sort.reverse

    scores.each_with_index do |group, index|
      if groups[group].length.odd? && index < scores.length - 1
        groups[group] << promote_random_player_from_group(groups, scores[index + 1])
      end

      groups[group].sort_by { rand }.each_slice(2) do |pair|
        @tournament.create_match(pair[0], pair[1])
      end
    end
  end

  private
    def promote_random_player_from_group(groups, group)
      groups[group].delete_at(rand(groups[group].length))
    end
end
