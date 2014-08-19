require 'fasync/media_handler'
require 'em-instagram'
module FAsync
  module Runner
    def self.run
      instagram_args = {
          :client_id =>FAsync.credentials[:ig_client],
          :client_secret =>FAsync.credentials[:ig_server],
          :host => FAsync.credentials[:host],
          :port => FAsync.credentials[:port],
          :callback_url => "#{FAsync.credentials[:host]}:#{FAsync.credentials[:port]}"

      }
      FAsync.logger.debug instagram_args
      instagram_connection = EventMachine::Instagram.new(instagram_args)
      instagram_connection.logger = FAsync.logger

      instagram_connection.on_update{|media| FAsync::MediaHandler.handle media}
      EventMachine.run do
        instagram_connection.start_server
        #TODO tags must be setted in config
        instagram_connection.subscribe_to({:object => "tag", :object_id => "pain"})
      end
    end
  end
end