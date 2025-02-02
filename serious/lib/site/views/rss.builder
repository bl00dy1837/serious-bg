require 'cgi'
require 'time'

xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
xml.rss "xmlns:itunes" => "http://www.itunes.com/dtds/podcast-1.0.dtd", "xmlns:atom" => "http://www.w3.org/2005/Atom", "xmlns:content" => "http://purl.org/rss/1.0/modules/content/", "xmlns:media" => "http://search.yahoo.com/mrss/", :version => "2.0" do
  xml.channel do
    xml.title catetory_tite(@category)
    xml.link category_url(@category)
    xml.tag!("atom:link", :rel => 'self', :href => @current_url) if defined?(@current_url) && @current_url
    xml.tag!("atom:link", :rel => 'next', :href => @next_url) if defined?(@next_url) && @next_url
    xml.description Serious.description
    xml.language 'de'
    xml.pubDate @articles.first.date_time.rfc2822 unless @articles.empty?
    xml.lastBuildDate @articles.first.date_time.rfc2822 unless @articles.empty?
    xml.itunes :author, Serious.author
    xml.copyright "Creative Commons BY-SA 3.0 DE"

    xml.itunes :subtitle, "Web, Technologie und OpenSource Software"
    xml.itunes :summary, Serious.description
    xml.itunes :keywords, "technology, gadgets, web, opensource, krepel"
    xml.itunes :explicit, "no"

    xml.itunes :image, { "href" => "http://blog.binaergewitter.de/img/binaergewitter_logo_1400x1400.png" }
    xml.itunes :category, {"text" => "Technology"}
    xml.tag!("itunes:owner"){
      xml.tag!("itunes:name", "Binärgewitter Crew")
      xml.tag!("itunes:email", "info@binaergewitter.de")
    }


    @articles.each do |article|
      xml.item do
        xml.title article.title
        xml.description article.automatic_summary
        xml.pubDate article.date_time.rfc2822
        xml.itunes :author, Serious.author
        xml.itunes :summary, article.automatic_summary
        # In case we fudged the initial release, we can set the parameter
        # in the article and generate a new GUID which will trigger clients
        # to redownload things
        if article.release
          xml.guid "#{article.full_url}-#{article.release}", 'isPermaLink'=> "false"
        else
          xml.guid article.full_url
        end
        xml.link article.full_url
        xml.tag!("content:encoded", article.body.formatted)
        if @selected_audio_codec
          if @selected_audio_codec.to_s.downcase == 'itunes'
            selected_codec = (['m4a', 'mp3'] & article.audioformats.keys).first
          else
            selected_codec = @selected_audio_codec
          end
          url = article.audioformats[selected_codec]
          type = "audio/#{selected_codec}"
          #According to the RSS Advisory Board's Best Practices Profile,
          #when an enclosure's size cannot be determined, a publisher should use a length of 0.
          xml.enclosure "url" => url, 'length' => article.audio_file_sizes[selected_codec].to_i.to_s, 'type' => type
        end

        xml.itunes :duration, article.duration_timestring

        # chapter marks
        xml.tag!("psc:chapters", "xmlns:psc" => "http://podlove.org/simple-chapters", :version => "1.2") do
          for item in article.chapter do
            xml.tag!("psc:chapter", :start => item[:start], :title => item[:title])
          end
        end
      end
    end
  end
end
