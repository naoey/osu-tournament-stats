class DiscordServerMembership < ApplicationRecord
  belongs_to :player
  belongs_to :discord_server

  def add_role(role)
    return if self.roles.includes(role)

    self.roles.push(role)
    self.save!
  end

  def remove_role(role)
    return unless self.roles.includes(role)

    self.roles = self.roles.filter { |r| r != role }
    self.save!
  end

  before_create do
    self.roles ||= []
  end
end
