require 'yaml'
require 'logger'
module FAsync
  def self.credentials
    @credentials ||= begin
      yaml = "config/credentials.yml"
      creds = YAML.load_file(yaml)
      creds[:callback_url] ||= "http://#{creds[:host]}:#{creds[:port]}"
      creds
    end
  end

  def self.logger
    @@logger||= Logger.new($stdout)
  end

end

