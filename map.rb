# frozen_string_literal: true

require 'net/http'
require 'open-uri'
require 'nokogiri'
require_relative 'url_module'
require_relative 'xml_module'

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
    puts 'Getting Links....'
    @links = get_all_urls @url
    final_links
    puts get_xml @final_links, @url
    puts 'Successfully saved to file....'
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
    @final_links << link if new_links.is_a?(Array) && link != @root_url
    @links = @links.uniq
  end
end
