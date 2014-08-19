require 'spec_helper'
require 'fasync'
require 'fasync/media_handler'
require 'json'

media = {
"link" => "http://example.com/123",
"images" => {
  "thumbnail" => {"url" => "http://example.com/ex.png"},
  "low_resolution" => {"url" => "http://example.com/ex.png"},
  "standard_resolution" => {"url" => "http://example.com/ex.png"}
  },
"id" => "12345",
"tags" => ["pain", "frustration", "linux"]
}
persist_media = {
  link: media["link"],
  thumb_url: media["images"]["thumbnail"]["url"],
  small_url: media["images"]["low_resolution"]["url"],
  big_url: media["images"]["standard_resolution"]["url"],
  uid: media["id"],
  tags: media["tags"],
}


secured_media = {
  data: {
    media: persist_media,
    secure: {
      time: /(0-9){9,14}/,
      sig: /.{40}/
    }
  }
}
puts secured_media
describe FAsync::MediaHandler do

  before(:each) do
    stub_request(:post,  FAsync.credentials[:fg_url]).
        with(:body =>  /.+/,
             :headers => {'Content-Type'=>'application/json', 'HTTP-ACCEPT' => 'application/json'}).
        to_return(:status => 200, :body => "", :headers => {})
  end

  it  "not requested if tipe not image" do

    EventMachine.run do
      FAsync::MediaHandler.handle media
      expect(a_request :post, FAsync.credentials[:fg_url]).to_not have_been_made
      EventMachine.stop
    end
  end

  it  "handle" do

    EventMachine.run do
      media["type"] = "image"
      FAsync::MediaHandler.handle media
      expect(a_request :post, FAsync.credentials[:fg_url]).to have_been_made.once
      EventMachine.stop
    end
  end


  it "just requested" do
    EventMachine.run do
      FAsync::MediaHandler.post secured_media
      expect(a_request :post, FAsync.credentials[:fg_url]).to have_been_made.once
      EventMachine.stop
    end
  end
end