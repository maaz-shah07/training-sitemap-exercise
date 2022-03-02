# frozen_string_literal: true

# This is the main module that validates and call
# use map class.
module MainModule
  def _url
    print 'Enter Root URL: '
    gets.chomp
  end

  def check_url_exsists(u_url)
    user_url = "#{u_url}/"
    url = URI.parse(user_url)
    req = Net::HTTP.new(url.host, url.port)
    req.use_ssl = true
    req.request_head(url.path)
  end
end
