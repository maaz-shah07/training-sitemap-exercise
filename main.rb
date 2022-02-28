# frozen_string_literal: true

require_relative 'map'

print 'Enter Root URL: '
url = gets.chomp

SitemapBuilder.new(url).main_method
