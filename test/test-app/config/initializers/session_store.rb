# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_test-app_session',
  :secret      => '1b2fc1ef0ee8ce1b1b09ae1ad798ce33bd95a4cb21768b6fb959af27fc5df4c95ac653cb0e985e0c15ba3f4fca94a28bf1db0df0b28b3ed00a7a811db078234c'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
