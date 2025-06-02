require 'rails_helper'

RSpec.describe DiscordServerMembership, type: :model do
  it "should correctly add and delete roles" do
    membership = DiscordServerMembership.create(player: create(:player), discord_server: create(:discord_server))

    membership.add_role(0)

    expect(membership.roles).to eql([0])

    membership.remove_role(0)

    expect(membership.roles).to eql([])
  end
end
