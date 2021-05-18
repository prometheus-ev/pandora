class Indexing::Sources::Piranesi < Indexing::SourceSuper
  def records
    document.xpath("//ROW")
  end

  def record_id
    record.xpath(".//Bildreferenz/text()")
  end

  def path
    record.at_xpath(".//Bildreferenz/text()").to_s.strip + '700.jpg'
  end

  def artist
    record.xpath(".//Kuenstler/text()")
  end

  def title
    record.xpath(".//Bildtitel/text()")
  end

  def location
    record.xpath(".//Aufbewahrungsort/text()")
  end

  def date
    record.xpath(".//Datierung/text()")
  end

  def credits
    record.xpath(".//Abildungsnachweis/text()", ".//Literatur/text()")
  end

  def technique
    record.xpath(".//Technik/text()")
  end

  def literature
    record.xpath(".//Literatur/text()")
  end
end
