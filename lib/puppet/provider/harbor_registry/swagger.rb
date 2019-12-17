# frozen_string_literal: true

Puppet::Type.type(:harbor_registry).provide(:swagger) do
  mk_resource_methods

  def self.instances
    api_instance = do_login

    registries = api_instance.registries_get()

    registries.map do |registry|
      new(
        ensure: :present,
        name: registry.name,
        description: registry.description,
        url: registry.url,
        access_key: registry.credential.access_key,
        access_secret: registry.credential.access_secret,
        insecure: registry.insecure.to_s(),
        provider: :swagger,
      )
    end
  end

  def self.prefetch(resources)
    instances.each do |int|
      if (resource = resources[int.name])
        resource.provider = int
      end
    end
  end

  def self.do_login
    require 'yaml'
    require 'harbor_swagger_client'
    my_config = YAML.load_file('/etc/puppetlabs/swagger.yaml')

    SwaggerClient.configure do |config|
      config.username = my_config['username']
      config.password = my_config['password']
      config.scheme = my_config['scheme']
      config.verify_ssl = my_config['verify_ssl']
      config.verify_ssl_host = my_config['verify_ssl_host']
    end

    api_instance = SwaggerClient::ProductsApi.new
    api_instance
  end

  def do_login
    require 'yaml'
    require 'harbor_swagger_client'
    my_config = YAML.load_file('/etc/puppetlabs/swagger.yaml')

    SwaggerClient.configure do |config|
      config.username = my_config['username']
      config.password = my_config['password']
      config.scheme = my_config['scheme']
      config.verify_ssl = my_config['verify_ssl']
      config.verify_ssl_host = my_config['verify_ssl_host']
    end

    api_instance = SwaggerClient::ProductsApi.new
    api_instance
  end

  def exists?
    api_instance = do_login

    opts = {
      name: resource[:name],
    }

    begin
      result = api_instance.registries_get(opts)
    rescue SwaggerClient::ApiError => e
      puts "Exception when calling ProductsApi->registries_get: #{e}"
    end

    if result.nil?
      false
    else
      true
    end
  end

  def create
    api_instance = do_login

    if resource[:insecure]
      insecure_bool = cast_to_bool(resource[:insecure].to_s())
    end

    if insecure_bool and (insecure_bool.class == TrueClass or insecure_bool.class == FalseClass)
      nr = registry = SwaggerClient::Registry.new(name: resource[:name], url: resource[:url], insecure: insecure_bool, type: 'harbor')
    else
      nr = registry = SwaggerClient::Registry.new(name: resource[:name], url: resource[:url], type: 'harbor')
    end

    begin
      api_instance.registries_post(nr)
    rescue SwaggerClient::ApiError => e
      puts "Exception when calling ProductsApi->registries_post: #{e}"
    end

    if resource[:set_credential]
      credential_bool = cast_to_bool(resource[:set_credential].to_s())
    end

    if credential_bool and (credential_bool.class == TrueClass)
      id = get_registry_id_by_name(resource[:name])
      set_registry_credential(id)
    end
  end

  def set_registry_credential(id)
    api_instance = do_login

    repo_target = SwaggerClient::PutRegistry.new(access_key: resource[:access_key], access_secret: resource[:access_secret])

    begin
      api_instance.registries_id_put(id, repo_target)
    rescue SwaggerClient::ApiError => e
      puts "Exception when calling ProductsApi->registries_id_put: #{e}"
    end
  end

  def cast_to_bool(foo)
    if foo == "true"
      return 'true' == 'true'
    end

    if foo == "false"
      return 'false' != 'false'
    end
  end

  def get_registry_id_by_name(registry_name)
    api_instance = do_login

    opts = {
      name: registry_name,
    }

    begin
      registry = api_instance.registries_get(opts)
    rescue SwaggerClient::ApiError => e
      puts "Exception when calling ProductsApi->registries_get: #{e}"
    end

    registry[0].id
  end

  def description=(_value)
    api_instance = do_login

    id = get_registry_id_by_name(resource[:name])

    repo_target = SwaggerClient::PutRegistry.new(description: resource[:description])

    begin
      api_instance.registries_id_put(id, repo_target)
    rescue SwaggerClient::ApiError => e
      puts "Exception when calling ProductsApi->registries_id_put: #{e}"
    end
  end

  def insecure=(_value)
    api_instance = do_login

    id = get_registry_id_by_name(resource[:name])

    insecure_bool = cast_to_bool(resource[:insecure].to_s())

    repo_target = SwaggerClient::PutRegistry.new(insecure: insecure_bool)

    begin
      api_instance.registries_id_put(id, repo_target)
    rescue SwaggerClient::ApiError => e
      puts "Exception when calling ProductsApi->registries_id_put: #{e}"
    end
  end

  def url=(_value)
    api_instance = do_login

    id = get_registry_id_by_name(resource[:name])

    repo_target = SwaggerClient::PutRegistry.new(url: resource[:url])

    begin
      api_instance.registries_id_put(id, repo_target)
    rescue SwaggerClient::ApiError => e
      puts "Exception when calling ProductsApi->registries_id_put: #{e}"
    end
  end

  def destroy
    api_instance = do_login

    registry_id = get_registry_id_by_name(resource[:name])

    begin
      api_instance.registries_id_delete(registry_id)
    rescue SwaggerClient::ApiError => e
      puts "Exception when calling ProductsApi->registries_id_delete: #{e}"
    end
  end
end