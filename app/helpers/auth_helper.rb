module AuthHelper
  # Creates an absolute callback URL for a given OAuth provider by prepending the base URL to the
  # provider. Returns the base URL as is if it is blank.
  def self.get_callback_url(provider)
    base = ENV.fetch('OAUTH_CALLBACK_BASE', '')

    return base if base.blank?

    base += '/' unless base.ends_with?('/')

    # todo: URI is fucking stupid why doesn't this work
    # URI::join(base, 'osu').to_s
    base += provider
  end
end
