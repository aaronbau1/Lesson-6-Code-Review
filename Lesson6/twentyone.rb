PLAY_POINT = 21

def prompt(msg)
  puts "=>#{msg}"
end

def initialize_deck(deck)
  (1..13).to_a.each do |card|
    case card
    when 1 then 4.times { |_| deck << "A" }
    when (2..9) then 4.times { |_| deck << card }
    when 10 then 4.times { |_| deck << "T" }
    when 11 then 4.times { |_| deck << "J" }
    when 12 then 4.times { |_| deck << "Q" }
    when 13 then 4.times { |_| deck << "K" }
    end
  end
  deck.shuffle
end

def display_ends(cards)
  card_end = "+---+"
  cards.each_with_index do |_, i|
    print card_end + "  "
    if i == cards.size - 1
      print "\n"
    end
  end
end

def display_mids(cards, hide_first)
  cards.each_with_index do |crd, i|
    card_mid = "| #{crd} |"
    if hide_first == true && i == 0
      print "| ? |" + "  "
    else
      print card_mid + "  "
      if i == cards.size - 1
        print "\n"
      end
    end
  end
end

def display_cards(cards, hide_first_card)
  display_ends(cards)
  display_mids(cards, hide_first_card)
  display_ends(cards)
end

def show_table(player, dealer, dont_show_card)
  prompt "Dealer Hand"
  display_cards(dealer, dont_show_card)
  prompt "Player Hand"
  display_cards(player, false)
end

def deal_cards(deck, player, dealer)
  2.times do |_|
    player << deck.pop
    dealer << deck.pop
  end
end

def hit(person, deck)
  person << deck.pop
end

def calculate_aces(hand_total, aces)
  hand_total += aces * 11
  aces.times { |_|
    if hand_total > 21
      hand_total -= 10
      break if hand_total < 21
    end
  }
  hand_total
end

def hand_count(hand)
  hand_total = 0

  # calculate everything but aces in hand
  hand.each do |card|
    case card
    when (2..9) then hand_total += card
    when "T" then hand_total += 10
    when "J" then hand_total += 10
    when "Q" then hand_total += 10
    when "K" then hand_total += 10
    end
  end
  aces = hand.count("A")
  if aces > 0 then hand_total = calculate_aces(hand_total, aces) end
  hand_total
end

def print_outcome(outcome, dealer_total, player_total)
  prompt "Dealer has #{dealer_total}, Player has #{player_total}"
  case outcome
  when :player_bust then prompt "Busted, you lose"
  when :dealer_bust then prompt "Player wins, Dealer busts"
  when :dealer_win then prompt "Dealer wins"
  when :tie then prompt "Tie"
  end
end

def print_game_scores(player_score, dealer_score)
  prompt "Player: #{player_score} Dealer: #{dealer_score}"
end

def final_output(player_score, dealer_score)
  if player_score == 3
    prompt "Player wins the best of 5"
  elsif dealer_score == 3
    prompt "Dealer wins the best of 5"
  end
  prompt "Thank you for playing Blackjack!"
end

# Best of 5 Loop
loop do
  player_score = 0
  dealer_score = 0

  # Single Hand Loop
  loop do
    # Single Hand Constants
    deck = []
    player_hand = []
    dealer_hand = []
    player_total = 0
    dealer_total = 0

    # Deal Hands
    deck = initialize_deck(deck)
    deal_cards(deck, player_hand, dealer_hand)

    # Player Turn
    loop do
      #Formats Game UI
      system "clear"
      show_table(player_hand, dealer_hand, true)
      print_game_scores(player_score, dealer_score)

      # Player Game Interaction
      player_total = hand_count(player_hand)
      dealer_total = hand_count(dealer_hand)

      prompt "You have #{player_total}"
      prompt "Hit or Stay? (H/S)"
      move = gets.chomp
      if move.downcase == 's'
        prompt "You chose to stay"
        break
      elsif move.downcase == 'h'
        hit(player_hand, deck)
        player_total = hand_count(player_hand)
      else
        prompt "Invalid Move"
      end

      # Player Busts
      show_table(player_hand, dealer_hand, true)
      if player_total > PLAY_POINT
        system "clear"
        show_table(player_hand, dealer_hand, false)
        print_outcome(:player_bust, dealer_total, player_total)
        dealer_score += 1
        break
      end
    end

    # Dealer turn
    if player_total <= PLAY_POINT
      loop do

        #Formats Game UI
        system "clear"
        dealer_total = hand_count(dealer_hand)
        show_table(player_hand, dealer_hand, false)
        print_game_scores(player_score, dealer_score)

        # Dealer Hand Logic
        if dealer_total < player_total
          hit(dealer_hand, deck)
        elsif dealer_total > PLAY_POINT
          print_outcome(:dealer_bust, dealer_total, player_total)
          player_score += 1
          break
        elsif dealer_total > player_total
          print_outcome(:dealer_win, dealer_total, player_total)
          dealer_score += 1
          break
        elsif dealer_total == player_total
          print_outcome(:tie, dealer_total, player_total)
          break
        end
      end
    end

    #End of hand result display
    print_game_scores(player_score, dealer_score)
    if dealer_score == 3 || player_score == 3
      final_output(player_score, dealer_score)
      break
    else
      loop do
        prompt "Ready for the next hand? (type r)"
        answer = gets.chomp
        break if answer.downcase == 'r'
      end
    end
  end
  # Play another best of 5?
  prompt "Would you like to play again? (y/n)"
  answer = gets.chomp
  break if answer.downcase != 'y'
end