# frozen_string_literal: true
# Use this hook to configure devise mailer, warden hooks and so forth.
# Many of these configuration options can be set straight in your model.
Devise.setup do |config|
  # ==> ORM configuration
  # Load and configure the ORM. Supports :active_record (default) and
  # :mongoid (bson_ext recommended) by default. Other ORMs may be
  # available as additional gems.
  require 'devise/orm/active_record'

  # By default Devise will store the user in session. You can skip storage for
  # particular strategies by setting this option.
  # Notice that if you are skipping storage for all authentication paths, you
  # may want to disable generating routes to Devise's sessions controller by
  # passing skip: :sessions to `devise_for` in your config/routes.rb
  config.skip_session_storage = [:http_auth]

  # By default, Devise cleans up the CSRF token on authentication to
  # avoid CSRF token fixation attacks. This means that, when using AJAX
  # requests for sign in and sign up, you need to get a new CSRF token
  # from the server. You can disable this option at your own risk.
  # config.clean_up_csrf_token_on_authentication = true

  # When false, Devise will not attempt to reload routes on eager load.
  # This can reduce the time taken to boot the app but if your application
  # requires the Devise mappings to be loaded during boot time the application
  # won't boot properly.
  # config.reload_routes = true

  # ==> Configuration for :rememberable
  # The time the user will be remembered without asking for credentials again.
  # config.remember_for = 2.weeks

  # Invalidates all the remember me tokens when the user signs out.
  config.expire_all_remember_me_on_sign_out = true

  # If true, extends the user's remember period when remembered via cookie.
  # config.extend_remember_period = false

  # Options to be passed to the created cookie. For instance, you can set
  # secure: true in order to force SSL only cookies.
  # config.rememberable_options = {}

  # ==> Scopes configuration
  # Turn scoped views on. Before rendering "sessions/new", it will first check for
  # "users/sessions/new". It's turned off by default because it's slower if you
  # are using only default views.
  # config.scoped_views = false

  # Configure the default scope given to Warden. By default it's the first
  # devise role declared in your routes (usually :user).
  # config.default_scope = :user

  # Set this configuration to false if you want /users/sign_out to sign out
  # only the current scope. By default, Devise signs out all scopes.
  # config.sign_out_all_scopes = true

  # ==> Navigation configuration
  # Lists the formats that should be treated as navigational. Formats like
  # :html, should redirect to the sign in page when the user does not have
  # access, but formats like :xml or :json, should return 401.
  #
  # If you have any extra navigational formats, like :iphone or :mobile, you
  # should add them to the navigational formats lists.
  #
  # The "*/*" below is required to match Internet Explorer requests.
  # config.navigational_formats = ['*/*', :html]

  # The default HTTP method used to sign out a resource. Default is :delete.
  config.sign_out_via = :get

  # ==> Configuration for :cas_authenticatable
  # The CAS specification allows for the passing of a follow URL to be displayed when
  # a user logs out on the CAS server. RubyCAS-Server also supports redirecting to a
  # URL via the destination param. Set either of these urls and specify either nil,
  # 'destination' or 'follow' as the logout_url_param. If the urls are blank but
  # logout_url_param is set, a default will be detected for the service.
  # config.cas_destination_url = 'https://cas.myorganization.com'
  # config.cas_follow_url = 'https://cas.myorganization.com'
  # config.cas_logout_url_param = nil

  # You can specify the name of the destination argument with the following option.
  # e.g. the following option will change it from 'destination' to 'url'
  # config.cas_destination_logout_param_name = 'url'

  # By default, devise_cas_authenticatable will create users.  If you would rather
  # require user records to already exist locally before they can authenticate via
  # CAS, uncomment the following line.
  # config.cas_create_user = false

  # If you don't want to use the username returned from your CAS server as the unique
  # identifier, but some other field passed in cas_extra_attributes, you can specify
  # the field name here.
  # config.cas_user_identifier = nil

  # If you want to use the Devise Timeoutable module with single sign out,
  # uncommenting this will redirect timeouts to the logout url, so that the CAS can
  # take care of signing out the other serviced applocations. Note that each
  # application manages timeouts independently, so one application timing out will
  # kill the session on all applications serviced by the CAS.
  # config.warden do |manager|
  #   manager.failure_app = DeviseCasAuthenticatable::SingleSignOut::WardenFailureApp
  # end

  # You can also set another single sign out strategy so that you won't be attached to rails_cache.
  # Be aware that to do so you also need to set the session_store.
  # Example for setting redis_cache.
  # There are some gems the help with it. One of them is called redis-rails and it can easily be set like this:
  # Rails.application.config.session_store :redis_store, servers: ["redis://localhost:6379/0/session"]
  # This is specially useful when you need to share session id accross apps (i.e. in a distributed environment)
  # config.cas_single_sign_out_mapping_strategy = :redis_cache

  # If you need to specify some extra configs for rubycas-client, you can do this via:
  # config.cas_client_config_options = {
  #     logger: Rails.logger
  # }
end
