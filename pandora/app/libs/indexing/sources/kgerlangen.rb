class Indexing::Sources::Kgerlangen < Indexing::Sources::Parents::Erlangen
  def path
    @miro_record_ids ||= Rails.configuration.x.athene_search_record_ids['miro'][name]
    if @miro_record_ids.include?(process_record_id(record_id))
      "miro"
    else
      super
    end
  end

  # künstler
  def artist
    (super + record.xpath('.//Weitere_Kuenstler/text()')).map { |a|
      a.to_s.strip
    }.delete_if { |a|
      a.blank?
    }
  end

  # standort
  def location
    "#{record.xpath('.//Land/text()')}, #{record.xpath('.//Standort/text()')}, #{record.xpath('.//Aufbewahrungsort/text()')}".gsub(/\A(?:, )+/, "").gsub(/(?:, )+\z/, "")
  end

  # bildnachweis
  def credits
    ("#{record.xpath('.//Titel/text()')}, " +
    "#{record.xpath('.//Jahr/text()')}, " +
    "#{record.xpath('.//Verweis/text()')}").gsub(/\A(?:, )+/, "").gsub(/(?:, )+\z/, "").gsub(/, $/, "")
  end

  # bildrecht
  def rights_reproduction
    record.xpath('.//Copyright/text()')
  end

  def size
    record.xpath('.//Masswerte/text()')
  end
end
