module FAsync
  module MediaHandler

    #Post json with main media info to main server
    def self.post media
      #Securing with sha1 salted by unixtime
      dig_secret = Digest::SHA1.hexdigest FAsync.credentials[:fg_secret]
      unix_time = DateTime.now.to_time.to_i
      sig = Digest::SHA1.hexdigest("#{dig_secret}#{unix_time}")
      secured = {data: {
          media: media,
          secure: {
            time: unix_time,
            sig: sig
          }
        }
      }
      request =  EventMachine::HttpRequest.new(FAsync.credentials[:fg_url])
        .post head:{"Content-Type" =>"application/json",  'HTTP-ACCEPT' => 'application/json'}, body: secured.to_json
      request.errback {|err| FAsync.logger.error "HTTP ERROR uploading: #{media[:uid]}" }
      request.callback {FAsync.logger.debug "Media #{media[:uid]} succersfully uploaded"}
    end

    #Callback to em-instagram handle media
    def self.handle media
      unless media["type"] == "image"
        return
      end
      persist_media = {
        link: media["link"],
        thumb_url: media["images"]["thumbnail"]["url"],
        small_url: media["images"]["low_resolution"]["url"],
        big_url: media["images"]["standard_resolution"]["url"],
        uid: media["id"],
        tags: media["tags"],
      }
      self.post persist_media

    end
  end
end