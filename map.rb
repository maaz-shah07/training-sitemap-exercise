require 'net/http'
require 'open-uri'
require 'nokogiri'

def main_method
    print "Enter Root URL: "
    url = gets.chomp

    final_links = []
    page_array = []

    root_protocol = URI.parse(url).scheme
    url_domain = URI.parse(url).host

    uri = URI.parse(url)
    root_url = uri.scheme + "://" + uri.host

    # puts root_protocol
    # puts url_domain
    # puts root_url

    links = get_all_urls(url).uniq

    puts "----------------  Getting Links ---------------- \n\n"

    while !links.empty? do
        link = links.pop()
        # puts "F--- #{link}"
        if /^\w*\.\w*$/.match?(link)
            link = root_url + "/" + link
        elsif /^\/.*/.match?(link)
            link = root_url + link
        elsif /^https?:\/\/.*/.match?(link) || /^http?:\/\/.*/.match?(link)
            next if URI.parse(link).scheme != root_protocol
        else
            next
        end

        # puts "S--- #{link}"

        condition = final_links.count(link) == 0 && URI.parse(link).host == url_domain && page_array.count(get_page(link)) == 0

        if condition
            page_array << get_page(link)
            # puts "Final Link --- #{link}"
            new_links = get_all_urls(link)
            if new_links.is_a?(Array) && !new_links.empty?
                new_links.each{ |new_link|
                    if !Regexp.new("^http.*").match?(link)
                        links << link + "/" + new_link
                    else
                        links << new_link
                    end
                }
            end
            links = links.uniq
            puts "Link ---> #{link}"

            final_links << link if new_links.is_a?(Array)
        end
    end

    puts "\n\n ---------------- End Getting Links ---------------- \n\n"



    puts "---------------- Printing Results in XML Format ---------------- \n\n"


    puts get_xml final_links, url

    puts "\n\n ------  Finished  ------ \n "
end

def get_page(page_link)
    link = page_link.split("/").
            reject {|p_link| p_link.empty? || p_link.strip.empty?}
    link.pop
end

def get_all_urls(url)
    link_array = []

    net_response = Net::HTTP.get_response(URI(url))
    parsed_data = Nokogiri::HTML.parse(net_response.body)

    get_a_tags = parsed_data.xpath("//a")
    get_a_tags.each { |tag| link_array << tag[:href] }

    link_array
end

def get_xml final_links, url
    xml_builder = Nokogiri::XML::Builder.new do |xml|
        xml.urlset('xmlns' => url) {
            final_links.each{ |link|
                xml.url {
                    xml.loc link
                }
            }
        }
    end
    xml_builder.to_xml
end
main_method
