module ::Proxy::Dns::F5
  class PluginConfiguration
    def load_classes
      require 'dns_common/dns_common'
      require 'smart_proxy_dns_f5/dns_f5_main'
    end

    def load_dependency_injection_wirings(container_instance, settings)
      container_instance.dependency :dns_provider, (lambda do
        ::Proxy::Dns::F5::Record.new(
            settings[:gtms])
      end)
    end
  end
end
