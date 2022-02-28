# frozen_string_literal: true

require 'net/http'
require 'open-uri'
require 'nokogiri'

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

# This is the module of printing all links in
#  XML Fomat
module XMLFomrat
  def get_xml(final_links, url)
    xml_builder = Nokogiri::XML::Builder.new do |xml|
      xml.urlset('xmlns' => url) do
        final_links.each do |link|
          xml.url do
            xml.loc link
          end
        end
      end
    end
    xml_builder.to_xml
  end
end

# Main class that have all functionalities of Sitemap
class SitemapBuilder
  include Urls
  include XMLFomrat

  def initialize(url)
    @url = url
    @links = []
    @final_links = []
    @page_array = []
    @root_protocol = URI.parse(url).scheme
    @url_domain = URI.parse(url).host
    uri = URI.parse(url)
    @root_url = "#{uri.scheme}://#{uri.host}"
  end

  def main_method
    p '----------------  Getting Links ---------------- \n\n'
    @links = get_all_urls @url

    final_links
    p "\n\n ---------------- End Getting Links ---------------- \n\n"
    p "---------------- Printing Results in XML Format ---------------- \n\n"
    puts get_xml @final_links, @url
    p "\n\n ------  Finished  ------ \n "
  end

  def get_page(page_link)
    link = page_link.split('/')
                    .reject { |p_link| p_link.empty? || p_link.strip.empty? }
    link.pop
  end

  def final_links
    until @links.empty?
      link = @links.pop
      # puts "F--- #{link}"
      result = modified_links link
      next if [true, false].include? result

    end
    @final_links
  end

  def modified_links(link)
    result = check_reg_ex link
    return false if [true, false].include? result

    return false unless check_condition result

    print_links result
  end

  def check_reg_ex(link)
    case
    when /^\w*\.\w*$/.match?(link) then link = "#{@root_url}/#{link}"
    when %r{^/.*}.match?(link) then link = "#{@root_url}#{link}"
    when %r{^https?://.*}.match?(link) || %r{^http?://.*}.match?(link)
      return false if URI.parse(link).scheme != @root_protocol
    else
      return false
    end
    link
  end

  def new_links(link)
    @page_array << get_page(link)
    new_links = get_all_urls(link)

    get_new_links new_links, link
  end

  def get_new_links(new_links, link)
    if new_links.is_a?(Array) && !new_links.empty?
      new_links.each do |new_link|
        @links << if !Regexp.new('^http.*').match?(link)
                    "#{link}/#{new_link}"
                  else
                    new_link
                  end
      end
    end
    new_links
  end

  def check_condition(link)
    cond1 = @final_links.count(link).zero?
    cond2 = URI.parse(link).host == @url_domain
    cond3 = @page_array.count(get_page(link)).zero?
    cond1 && cond2 && cond3
  end

  def print_links(link)
    new_links = new_links link
    puts "Link ---> #{link}"
    @final_links << link if new_links.is_a?(Array)
    @links = @links.uniq
  end
end

print 'Enter Root URL: '
url = gets.chomp

SitemapBuilder.new(url).main_method
