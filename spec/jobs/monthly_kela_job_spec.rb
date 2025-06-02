require "rails_helper"

require_relative '../../lib/discord/bot'

describe "MonthlyKelaJob" do
  it "should call kela! on bot" do
    mock_bot = double()

    allow(mock_bot).to receive(:initialize!)
      .and_yield(mock_bot)
    expect(mock_bot).to receive(:kela!)
      .and_return(nil)

    allow(Discord::OsuDiscordBot).to receive(:instance)
      .and_return(mock_bot)

    MonthlyKelaJob.perform_now
  end
end
