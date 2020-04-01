FactoryBot.define do
  factory :tournament do
    name { "Tournament #{Tournament.count + 1}" }
    start_date { DateTime.now - 2.days }
    end_date { DateTime.now + 2.days }

    association :host_player, factory: :player
  end
end
