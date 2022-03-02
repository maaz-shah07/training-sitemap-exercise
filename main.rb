# frozen_string_literal: true

require_relative 'map'
require_relative 'url_valid_module'

# This is the main class
class Main
  include MainModule

  def runner
    url = _url
    res = check_url_exsists url
    SitemapBuilder.new(url).main_method if res.code == '200'
  rescue StandardError
    puts 'Invalid URL...'
  end
end
