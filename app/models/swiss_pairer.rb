class SwissPairer
  class UnmatchableRound < StandardError; end

  def initialize(tournament)
    @tournament = tournament
    @matches = {}
  end


  def generate_matches
    generate_naive_matches
    fix_illegal_matches
    create_matches
  end

  private
    def generate_naive_matches
      groups = @tournament.players.group_by { |p| p.match_score }
      scores = groups.keys.sort.reverse

      scores.each_with_index do |group, index|
        if groups[group].length.odd? && index < scores.length - 1
          groups[group] << promote_random_player_from_group(groups[scores[index + 1]])
        end

        groups[group].sort_by { rand }.each_slice(2) do |pair|
          @matches[group] ||= []
          @matches[group] << pair
        end
      end
    end

    def fix_illegal_matches
      scores = @matches.keys.sort.reverse
      scores.each_with_index do |group, index|
        while illegal_match = find_illegal_match(@matches[group])
          raise UnmatchableRound unless swap_with_group(illegal_match, @matches[group]) ||
            (index + 1 < scores.size && swap_with_group(illegal_match, @matches[scores[index + 1]])) ||
            swap_with_group(illegal_match, @matches[scores[index - 1]])
        end
      end
    end

    def create_matches
      @matches.values.flatten(1).each do |pair|
        @tournament.create_match(pair[0], pair[1])
      end
    end

    def promote_random_player_from_group(group)
      group.delete_at(rand(group.length))
    end

    def find_illegal_match(matches)
      matches.find { |match| played?(match[0], match[1]) }
    end

    def swap_with_group(match, swappable_matches)
      swappable_matches.each do |swap_match|
        return true if swap_if_possible(match, swap_match)
      end

      false
    end

    def swap_if_possible(m1, m2)
      return false if m1 == m2

      if !played?(m1[0], m2[0]) && !played?(m1[1], m2[1])
        m1[1], m2[0] = m2[0], m1[1]
        true
      elsif !played?(m1[0], m2[1]) && !played?(m1[1], m2[0])
        m1[1], m2[1] = m2[1], m1[1]
        true
      else
        false
      end
    end

    def played?(player_1, player_2)
      player_1 && player_2 && player_1.played?(player_2)
    end
end
