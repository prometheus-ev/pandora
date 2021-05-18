class Indexing::Sources::Bern < Indexing::SourceSuper
  VERSIONS_URL = 'http://www.diathek.ikg.unibe.ch/eas/versions/%s?instance=uni-bern'.freeze

  def records
    document.xpath("//row[Bilder/bild/text()]")
  end

  def record_id
    record.xpath('.//Bilder/id/text()')
  end

  def path
    @miro_record_ids ||= Rails.configuration.x.athene_search_record_ids['miro'][name]

    if @miro_record_ids.include?(process_record_id(record_id))
      "miro"
    else
      image_id = record.xpath('.//Bilder/bild/text()').to_s

      unless @paths_document
        paths_file = File.open(Rails.configuration.x.dumps_path + "bern_paths.xml")
        @paths_document = Nokogiri::XML(File.open(paths_file)) do |config|
          config.noblanks
        end
      end

      path = @paths_document.xpath("//root/row/bild[text()='#{image_id}']/../paths/path/size[text()='original']/../path/text()").to_s || ""

      if path.blank?
        begin
          url = URI.parse(VERSIONS_URL % image_id)
          result = Net::HTTP.start(url.host, url.port, { :open_timeout => 1, :read_timeout => 1 })

          JSON.parse(result.body).each { |version|
            printf '-'
            if version == 'original'
              path = "#{version['link']}/#{image_id}.jpg"
            end
          }
        rescue => exception
          warn "\nError fetching image path for record ID #{record_id.to_s} (#{exception.class}): #{exception}"
        end
      end

      path.sub(/^(\/*)/,'')
    end
  end

  # künstler
  def artist
    artist_name = record.xpath('.//Kuenstler/name/text()').to_s
    artist_dates = record.xpath('.//Kuenstler/lebensdaten/text()').to_s

    if artist_dates.blank?
      [artist_name]
    else
      [artist_name + " (" + artist_dates + ")"]
    end
  end

  def artist_normalized
    an = record.xpath('.//Kuenstler/name/text()').map { |a|
      a.to_s.split(', ').reverse.join(' ')
    }
    super(an)
  end

  # titel
  def title
    record.xpath('.//Bilder/titel/text()')
  end

  # datierung
  def date
    record.xpath('.//Bilder/datierung/text()').to_s
  end

  def date_range
    # Preprocess date.
    pd = date.strip
    non_dates = ['ca.', 'um', 'nicht datiert', 'keine Angaben', 'ohne Datierung', 'unbekannt', 'x', '-']

    if !non_dates.include?(pd)
      super(date.to_s)
    end
  end

  # standort
  def location
    record.xpath('.//Bilder/standort/text()')
  end

  # material
  def technique
    record.xpath('.//Bilder/technik/text()')
  end

  # Gattung
  def genre
    record.xpath('.//Bilder/gattung/text()')
  end

  def size
    record.xpath('.//Bilder/masse/text()')
  end

  # abbildungsnachweis
  def credits
    record.xpath('.//Bilder/bildnachweis/text()')
  end

  def rights_work
    if is_record_id_a_rights_work_warburg_record_id?
      rights_work_warburg
    elsif is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end

  def annotation
    record.xpath('.//Bilder/ort/text()')
  end

  def comment
    record.xpath('.//Bilder/kommentar/text()')
  end
end
