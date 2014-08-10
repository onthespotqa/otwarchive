class Admin < ActiveRecord::Base
  # Authlogic gem
  acts_as_authentic do |config|
    config.transition_from_restful_authentication = true
    config.transition_from_crypto_providers = Authlogic::CryptoProviders::Sha1
    config.merge_validates_length_of_password_field_options({:minimum => 3, :maximum => 40})
  end
  
  has_many :log_items
  has_many :invitations, :as => :creator
  has_many :wrangled_tags, :class_name => 'Tag', :as => :last_wrangler 
end
