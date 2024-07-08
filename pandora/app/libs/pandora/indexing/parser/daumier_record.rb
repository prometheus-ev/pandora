class Pandora::Indexing::Parser::DaumierRecord < Pandora::Indexing::Parser::Record
  def record_id
    dr_nr = record.xpath('./DRNr/text()').to_s
    if dr_nr.length < 4
      dr_nr = "0" * (4 - dr_nr.length) + dr_nr
    end
    "DR#{dr_nr}_#{record.at_xpath('./SammlungID/text()')}"
  end

  def record_object_id
    [name, Digest::SHA1.hexdigest(record.xpath('./DRNr/text()').to_a.join('|'))].join('-')
  end

  def record_object_id_count
    @record_object_id_count[record_object_id]
  end

  def path
    # return "img/#{record_id}.jpg"
    url = URI.parse("https://www.daumier-register.org/img/#{record_id}.jpg")
    request = Net::HTTP.new(url.host, url.port)
    request.use_ssl = true
    result = request.request_head(url.path)
    if result.code == "200"
      "img/#{record_id}.jpg"
    else
      "img/#{record_id}_a.jpg"
    end
  end

  def artist
    ["Honoré Victorin Daumier"]
  end

  def title
    "#{object.xpath('./Text_f/text()')} [franz./Original], #{object.xpath('./Text_g/text()')} [deutsch]"
  end

  def location
    object.xpath('./sammlungen/listesammlungen_g/NameSammlung/text()')
  end

  def print
    record.xpath('./listedruck_g/DruckBezeichnung/text()')
  end

  def technique
    object.xpath('./listetechniken_g/NameTechnik/text()')
  end

  def rights_reproduction
    record.xpath('./listesammlungen_g/NameSammlung/text()')
  end

  def credits
    number = object.xpath('count(publikation)')
    (1..(number.to_i)).map{|index|
      "#{object.xpath("./publikation[#{index}]/listepublikationen/NamePublikation/text()")}, #{object.xpath("./publikation[#{index}]/Bemerkung_g/text()")}, #{object.xpath("./publikation[#{index}]/PublikationDatum/text()")}".gsub(/\A, /, '').gsub(/, \z/, '')
    }
  end

  def description
    object.xpath('./Hintergrund_d/text()').map {|description|
      description.to_s.gsub(/&lt;a \S*&gt;/, '').gsub(/&lt;\/a&gt;/, '')
    }
  end

  def printdetails
    object.xpath('./druckdetails/Druckdetail/text()') +
      object.xpath('./druckdetails/Druckdetail/text()')
  end

  def keyword
    object.xpath('./thema/listethemen_g/NameThema/text()')
  end

  def comment
    record.xpath('./Bemerkung_g/text()')
  end

  def size
    "#{object.xpath('./Hoehe/text()')} x #{object.xpath('./Breite/text()')}"
  end

  def series
    object.xpath('./listeserien/NameSerie/text()')
  end

  def condition
    object.xpath('./zustand/ZustandBeschreibung_g/text()')
  end

  def work_catalogue
    object.xpath('./werkverzeichnis/listewerkverzeichnisse/NameVerzeichnis/text()')
  end

  def inventory_no
    "DR#{record.xpath('./DRNr/text()')}"
  end

  def source_url
    "http://www.daumier-register.org/werkview.php?key=#{record.xpath('./DRNr/text()')}"
  end
end
