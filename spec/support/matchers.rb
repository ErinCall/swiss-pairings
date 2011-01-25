RSpec::Matchers.define :have_matches_for_round do |round, *expected_matches|
  match do |tournament|
    actual_matches = tournament.matches.where(round: round)
    
    if actual_matches.length != expected_matches.length
      false 
    else
      success = true
      actual_matches.each do |m|
        match_found = expected_matches.find do |em|
          (em[0].id == m.player_1_id && em[1].id == m.player_2_id) ||
            (em[0].id == m.player_2_id && em[1].id == m.player_1_id)
        end

        unless match_found
          success = false
          break
        end
      end
      success
    end
  end
end
