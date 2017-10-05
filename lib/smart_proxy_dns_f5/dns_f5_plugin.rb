require 'smart_proxy_dns_f5/dns_f5_version'

module Proxy::Dns::F5
  class Plugin < ::Proxy::Provider
    plugin :dns_f5, ::Proxy::Dns::F5::VERSION

    # Settings listed under default_settings are required.
    # An exception will be raised if they are initialized with nil values.
    # Settings not listed under default_settings are considered optional and by default have nil value.
    default_settings :gtms = {
      "10.0.0.10" => {
         "password"=> "password",
         "query_server"=> "10.0.0.10",
         "username"=> "foreman_proxy",
         "view"=> "Default"
       }
     }

    requires :dns, '>= 1.15'

    # Loads plugin files and dependencies
    load_classes ::Proxy::Dns::F5::PluginConfiguration
    # Loads plugin dependency injection wirings
    load_dependency_injection_wirings ::Proxy::Dns::PluginTemplate::PluginConfiguration
  end
end
