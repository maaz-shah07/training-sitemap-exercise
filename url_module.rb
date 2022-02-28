# frozen_string_literal: true

# This is the module for getting urls
module Urls
  def get_all_urls(url)
    link_array = []

    net_response = Net::HTTP.get_response(URI(url))
    parsed_data = Nokogiri::HTML.parse(net_response.body)
    get_a_tags = parsed_data.xpath('//a')
    get_a_tags.each { |tag| link_array << tag[:href] }

    link_array
  end
end
