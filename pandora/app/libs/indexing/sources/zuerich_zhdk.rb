class Indexing::Sources::ZuerichZhdk < Indexing::SourceSuper

  def records
    document.xpath('.//metadata')
  end

  def _record_id
    record.xpath('.//metadatum[1]/media-entry-id/text()')
  end

  def record_id
    "#{_record_id}"
  end

  def path
    "#{_record_id}_maximum.jpg"
  end

  def _label(str, field = nil)
    number = record.xpath('count(.//metadatum)')
    (1..(number.to_i)).map{|index|
      if "#{record.xpath(".//metadatum[#{index}]/meta-key-id/text()")}" == str 
        if field
          "#{record.xpath(".//metadatum[#{index}]/values/value/#{field}/text()")}"
        else
         "#{record.xpath(".//metadatum[#{index}]/value/text()")}"
        end
      end
    }
  end

  def date
    _label("madek_core:portrayed_object_date")
  end

  def artist
    _label("madek_core:authors", "last-name")
  end

  def title
    _label("madek_core:title")
  end

  def location
    _label("media_content:portrayed_object_location")
  end

  def keyword
    record.xpath(".//metadatum/values/value/term/text()").map{|keyword|
    keyword.to_s.gsub(/Alle Rechte vorbehalten/, '')
    }.delete_if { |keyword|
      keyword.blank?
    }.join(", ")

  end

  def credits
    _label("copyright:source")
  end

  def rights_reproduction
    "Gemeinfrei" 
  end

  def rights_work
    "Gemeinfrei"
  end

  def source_url
    "https://medienarchiv.zhdk.ch/entries/#{_record_id}"
  end
end
