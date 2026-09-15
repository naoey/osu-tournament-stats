# frozen_string_literal: true

Rails.application.config.session_store :cookie_store,
  key: '_ots_session',
  same_site: :lax,
  secure: Rails.env.production?
