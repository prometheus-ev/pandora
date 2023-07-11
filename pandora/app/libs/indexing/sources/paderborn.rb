class Indexing::Sources::Paderborn < Indexing::SourceSuper
  def records
    document.xpath('//Bild')
  end

  def record_id
    if (easy4_id = "#{record.xpath('.//easy4_id/text()')}").blank?
      record.xpath('.//ID/text()')
    else
      unless @paths_document
        paths_file = File.open(Rails.configuration.x.dumps_path + "paderborn_easydb4_ids.xml")
        @paths_document = Nokogiri::XML(File.open(paths_file)) do |config|
          config.noblanks
        end
      end
      path = @paths_document.xpath("//Bilder/Bild/ID[text()='#{easy4_id}']/../Bildreferenz/text()").to_s.gsub(/https:\/\/eas-neu.uni-paderborn.de\//, 'https://eas.uni-paderborn.de/') || ""
    end

  end

  def path
    "#{record.at_xpath('.//Bildreferenz/text()')}".sub(/https:\/\/media.uni-paderborn.de\//, '')
  end

  def s_location
    [record.xpath('.//Standort/text()'), record.xpath('.//Dargestellter_Ort/text()')]
  end

  # künstler
  def artist
    record.xpath('.//KuenstlerIn/text()')
  end

  def artist_normalized
    an = record.xpath('.//KuenstlerIn/text()').map { |a|
      a.to_s.split(', ').reverse.join(' ')
    }
    super(an)
  end

  # titel
  def title
    record.xpath('.//Titel/text()')
  end

  # datierung
  def date
    record.xpath('.//Datierung/text()')
  end

  def date_range
    d = date.to_s.strip

    super(d)
  end

  # standort
  def location
    record.xpath('.//Standort/text()')
  end

  # Dargestellter Ort
  def pictured_location
    record.xpath('.//Dargestellter_Ort/text()')
  end

  # technik
  def technique
    record.xpath('.//Technik/text()')
  end

  # Gattung
  def genre
    record.xpath('.//Gattung/text()')
  end

  # Masse
  def size
    record.xpath('.//Masse/text()')
  end

  # abbildungsnachweis
  def credits
    record.xpath('.//Abbildungsnachweis/text()')
  end

  def rights_work
    if is_record_id_a_rights_work_warburg_record_id?
      rights_work_warburg
    elsif is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end

  # Anmerkung
  def origin
    record.xpath('.//Zusatz/text()')
  end
end
