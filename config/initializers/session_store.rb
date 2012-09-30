# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_CrazyEights_session',
  :secret      => '149b33eb732b662c27dbc4e53b538a01b77488aa3e28cc5c420975bd6f0c1d5e0b1ca63432f604a9fe648ced82539e93d53f1a2872315b58b12f9c9b63b6a1be'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
