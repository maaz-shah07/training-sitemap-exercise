# frozen_string_literal: true

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
    xml_to_file xml_builder
  end

  def xml_to_file(xml_builder)
    f = File.new('output.xml', 'w')
    f.write(xml_builder.to_xml)
    f.close
  end
end
