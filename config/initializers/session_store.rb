# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_pongratings_session',
  :secret      => '58306837d97d9a802c4c04d0304b49b423092562fab92c2d61f38b4064cb5a96b29dbf582d4447dfff4562587b7212f4455ae75a60e605b89487a95593ac2c62'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
