class Indexing::Sources::Daumier < Indexing::SourceSuper
  def records
    @node_name = 'sammlungen'
    document.xpath('//sammlungen')
  end

  def record_id
    if "#{record.xpath('./Abbildung/text()')}" == "1"
      dr_nr = record.xpath('.//DRNr/text()').to_s
      if dr_nr.length < 4
        dr_nr = "0" * (4 - dr_nr.length) + dr_nr
      end
      "DR#{dr_nr}_#{record.at_xpath('.//SammlungID/text()')}"
    end
  end

  def record_object_id
    if "#{record.xpath('./Abbildung/text()')}" == "1"
      [name, Digest::SHA1.hexdigest(record.xpath('./DRNr/text()').to_a.join('|'))].join('-')
    end
  end

  def record_object_id_count
    @record_object_id_count[record_object_id]
  end

  def path
    # return "img/#{record_id}.jpg"
    url = URI.parse("http://www.daumier-register.org/img/tn/#{record_id}.jpg")
    request = Net::HTTP.new(url.host, url.port)
    result = request.request_head(url.path)
    if result.code == "200"
      "img/#{record_id}.jpg"
    else
      "img/#{record_id}_a.jpg"
    end
  end

  # künstler
  def artist
    ["Honoré Victorin Daumier"]
  end

  # titel
  def title
    "#{record.xpath('.//ancestor::row/Text_f/text()')} [franz./Original], #{record.xpath('.//ancestor::row/Text_g/text()')} [deutsch]"
  end

  # standort
  def location
    record.xpath('.//ancestor::row/sammlungen/listesammlungen_g/NameSammlung/text()')
  end

  def print
    record.xpath('.//listedruck_g/DruckBezeichnung/text()')
  end

  # technik
  def technique
    record.xpath('.//ancestor::row/listetechniken_g/NameTechnik/text()')
  end

  # bildrecht
  def rights_reproduction
    record.xpath('.//listesammlungen_g/NameSammlung/text()')
  end

  # abbildungsnachweis
  def credits
    number = record.xpath('count(ancestor::row/publikation)')
    (1..(number.to_i)).map{ |index|
      "#{record.xpath(".//ancestor::row/publikation[#{index}]/listepublikationen/NamePublikation/text()")}, #{record.xpath(".//.//ancestor::row/publikation[#{index}]/Bemerkung_g/text()")}, #{record.xpath(".//.//ancestor::row/publikation[#{index}]/PublikationDatum/text()")}".gsub(/\A, /,'').gsub(/, \z/,'')
    }
  end

  # beschreibung
  def description
    record.xpath('.//ancestor::row/Hintergrund_d/text()').map { |description|
      description.to_s.gsub(/&lt;a \S*&gt;/, '').gsub(/&lt;\/a&gt;/, '')
    }
  end

  # druckdetails
  def printdetails
    record.xpath('.//ancestor::row/druckdetails/Druckdetail/text()') + record.xpath('.//ancestor::row/druckdetails/Druckdetail/text()')
  end

  # Schlagwoerter
  def keyword
    record.xpath('.//ancestor::row/thema/listethemen_g/NameThema/text()')
  end

  def comment
    record.xpath('.//Bemerkung_g/text()')
  end

  def size
    "#{record.xpath('.//ancestor::row/Hoehe/text()')} x #{record.xpath('.//ancestor::row/Breite/text()')}"
  end

  def series
    record.xpath('.//ancestor::row/listeserien/NameSerie/text()')
  end

  def condition
    record.xpath('.//ancestor::row/zustand/ZustandBeschreibung_g/text()')
  end

  def work_catalogue
    record.xpath('.//ancestor::row/werkverzeichnis/listewerkverzeichnisse/NameVerzeichnis/text()')
  end

  def inventory_no
    "DR#{record.xpath('.//DRNr/text()')}"
  end

  def source_url
    "http://www.daumier-register.org/werkview.php?key=#{record.xpath('.//DRNr/text()')}"
  end
end
