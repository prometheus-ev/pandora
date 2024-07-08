class Pandora::Indexing::Parser::Parents::HamburgRecord < Pandora::Indexing::Parser::Record
  def record_id
    @record_id ||= record.xpath('./bild/files/file/eas-id/text()').to_s
  end

  def record_object_id
    unless title.blank?
      record_object_id = [name, Digest::SHA1.hexdigest(title.to_s)].join('-')
    end
  end

  def record_object_id_count
    @record_object_id_count[record_object_id]
  end

  def path
    "#{record.at_xpath('./bild/files/file/versions/version[@name="original"]/url/text()')}".
      sub(/http:\/\/kultdokuhh.fbkultur.uni-hamburg.de\//, '').
      sub(/http:\/\/localhost\//, '').
      sub(/https:\/\/kultdokuhh4.fbkultur.uni-hamburg.de\//, '').
      sub(/http:\/\/kultdokuhh-4.fbkultur.uni-hamburg.de\//, '').
      sub(/https:\/\/kultdokuhh-4.fbkultur.uni-hamburg.de\//, '')
  end

  def artist
    @artist ||= record.xpath("./_nested__bilder__kuenstler/bilder__kuenstler/lk_kuenstler_id/kuenstler/name/text()")
  end

  def artist_normalized
    return @artist_normalized if @artist_normalized

    an = artist.map {|a|
      a.to_s.split(', ').reverse.join(' ')
    }

    @artist_normalized = @artist_parser.normalize(an)
  end

  def title
    @title ||= record.xpath("./titel/text()").to_s
  end

  def date
    @date ||= record.xpath("./datum/text()")
  end

  def date_range
    return @date_range if @date_range

    d = date.to_s.strip

    if d == 'um 14886-90'
      d = 'um 1488-90'
    elsif d == '330. n. Chr.'
      d = '330 n. Chr.'
    elsif d == 'um 330. n. Chr.'
      d = 'um 330 n. Chr.'
    elsif d == 'um 1480.'
      d = 'um 1480'
    elsif ['1361/62-64', '1361/62 - 64'].include?(d)
      d = '1361 - 64'
    end

    @date_range = @date_parser.date_range(d)
  end

  def location
    "#{record.xpath('./ort_id/ort/name/text()')}, " \
    "#{record.xpath('./institution/text()')}".
      gsub(/\A, /, '').
      gsub(/, \z/, '')
  end

  def manufacture_place
    record.xpath("./herstellort_id/ort/name/text()")
  end

  def material
    record.xpath("./technik_material/text()")
  end

  def genre
    record.xpath("./gattung/text()")
  end

  def size
    record.xpath("./masse/text()")
  end

  def credits
    record.xpath("./abbildungsnachweis/text()")
  end

  def rights_work
    if @warburg_parser.is_record_id_a_rights_work_warburg_record_id?(record_id, name)
      @warburg_parser.rights_work_warburg
    elsif @vgbk_parser.is_any_artist_in_vgbk_artists_list?(artist_normalized, date_range)
      @vgbk_parser.rights_work_vgbk
    end
  end

  def rights_reproduction
    record.xpath("./copyrightnachweis/text()")
  end

  def keyword
    record.xpath("./darstellung_thema/text()")
  end
end
