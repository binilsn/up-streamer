class RodauthApp < Rodauth::Rails::App
  # primary configuration
  configure RodauthMain

  # secondary configuration
  # configure RodauthAdmin, :admin

  route do |r|
    rodauth.load_memory # autologin remembered users

    r.rodauth # route rodauth requests

    # Public paths that don't require authentication
    public_paths = [ "/up", "/doc", "/api", "/cable" ]

    unless public_paths.any? { |p| r.path.start_with?(p) }
      rodauth.require_account
    end

    # ==> Secondary configurations
    # r.rodauth(:admin) # route admin rodauth requests
  end
end
