class Indexing::Sources::Parents::Rba < Indexing::SourceSuper
  def records
    document.xpath('//a8540')
  end

  def record_id
    record.xpath('.//text()')
  end

  def record_object_id
    obj_obj = "#{record.xpath('.//ancestor::obj[2]/a5000/text()')}"
    if obj_obj.blank?
      [name, Digest::SHA1.hexdigest(record.xpath('.//../../a5000/text()').to_a.join('|'))].join('-')
    else
      [name, Digest::SHA1.hexdigest(record.xpath('.//ancestor::obj[2]/a5000/text()').to_a.join('|'))].join('-')
    end
  end

  def path
    "#{record.at_xpath('.//text()')}.jpg"
  end

  # künstler
  def artist
    number = record.xpath('count(../../aob30)')
    (1..(number.to_i)).map{|index|
      "#{record.xpath(".//../../aob30[#{index}]/a3100/text()")} (#{record.xpath(".//../../aob30[#{index}]/a3475/text()")})".gsub(/\(\)/, "")
    }
  end

  def artist_normalized
    an = record.xpath('.//../../aob30/a3100/text()').map {|a|
      a.to_s.split(', ').reverse.join(' ')
    }
    super(an)
  end

  # titel
  def title
    "#{record.xpath('.//../../a5200/text()')} (#{record.xpath('.//ancestor::obj[2]/a5200/text()')})".gsub(/\(\)/, "")
  end

  # datierung
  def date
    if (date = "#{record.xpath('.//../../a5060/a5064/text()')}").blank?
      "#{record.xpath('.//../../a5060/a5071/text()')} - #{record.xpath('.//../../a5060/a5077/text()')}".gsub(/\A - /, '')
    else
      date
    end
  end

  def location
    standort = "#{record.xpath('.//../../aob26[text()="Standort"]/a2664/text()')}, #{record.xpath('.//../../aob26[text()="Standort"]/a2662/text()')}, #{record.xpath('.//../../aob26[text()="Standort"]/a2660/text()')}, #{record.xpath('.//../../aob26[text()="Standort"]/a2661/text()')} (#{record.xpath('.//../../aob26[text()="Standort"]/a266f/text()')} #{record.xpath('.//../../aob26[text()="Standort"]/a266h/text()')})".gsub(/, , /, '').gsub(/\A, /, '').gsub(/\( \)/, "")
    number = record.xpath('count(../../aob28[starts-with(text(),"Besitzer")])')
    standort_besitzer = (1..(number.to_i)).map{|index|
      "#{record.xpath(".//../../aob28[starts-with(text(),'Besitzer')][#{index}]/a2864/text()")}, #{record.xpath(".//../../aob28[starts-with(text(),'Besitzer')][#{index}]/a2900/text()")}, #{record.xpath(".//../../aob28[starts-with(text(),'Besitzer')][#{index}]/a2910/text()")}".gsub(/, ,/, '').gsub(/\A, /, '').gsub(/, \z/, '')
    }
    number2 = record.xpath('count(../../aob28[starts-with(text(),"Eigentümer")])')
    standort_eigentuemer = (1..(number2.to_i)).map{|index|
      "#{record.xpath(".//../../aob28[starts-with(text(),'Eigentümer')][#{index}]/a2864/text()")}, #{record.xpath(".//../../aob28[starts-with(text(),'Eigentümer')][#{index}]/a2900/text()")}, #{record.xpath(".//../../aob28[starts-with(text(),'Eigentümer')][#{index}]/a2910/text()")}".gsub(/, ,/, '').gsub(/\A, /, '').gsub(/, \z/, '')
    }

    # standort_besitzer="#{record.xpath('.//../../aob28[starts-with(text(),"Besitzer")]/a2864/text()')}, #{record.xpath('.//../../aob28[starts-with(text(),"Besitzer")]/a2900/text()')}, #{record.xpath('.//../../aob28[starts-with(text(),"Besitzer")]/a2910/text()')}".gsub(/, ,/, '').gsub(/\A, /, '').gsub(/, \z/, '')
    # standort_eigentuemer="#{record.xpath('.//../../aob28[starts-with(text(),"Eigentümer")]/a2864/text()')}, #{record.xpath('.//../../aob28[starts-with(text(),"Eigentümer")]/a2900/text()')}, #{record.xpath('.//../../aob28[starts-with(text(),"Eigentümer")]/a2910/text()')}".gsub(/, ,/, '').gsub(/\A, /, '').gsub(/, \z/, '')
    standort_verwalter = "#{record.xpath('.//../../aob28[text()="Verwalter"]/a2864/text()')}, #{record.xpath('.//../../aob28[text()="Verwalter"]/a2900/text()')}, #{record.xpath('.//../../aob28[text()="Verwalter"]/a2910/text()')}".gsub(/, ,/, '').gsub(/\A, /, '').gsub(/, \z/, '')
    [standort, standort_besitzer, standort_eigentuemer, standort_verwalter].flatten
  end

  # Herkunftsort
  def origin
    number = record.xpath('count(../../aob26[text()="Herkunftsort"])')
    (1..(number.to_i)).map{|index|
      "#{record.xpath(".//../../aob26[text()='Herkunftsort'][#{index}]/a2664/text()")}, #{record.xpath(".//../../aob26[text()='Herkunftsort'][#{index}]/a2690/text()")}, #{record.xpath(".//../../aob26[text()='Herkunftsort'][#{index}]/a2700/text()")}, #{record.xpath(".//../../aob26[text()='Herkunftsort'][#{index}]/a2730/text()")}, #{record.xpath(".//../../aob26[text()='Herkunftsort'][#{index}]/a2796/text()")}".gsub(/, , , , /, '').gsub(/, , , /, '').gsub(/, , /, '').gsub(/\A, /, '').gsub(/, \z/, '')
    }
  end

  # Entstehungsort
  def origin_point
    ["#{record.xpath('.//../../a5130/text()')}", "#{record.xpath('.//../../a5140[text()="Faktischer Entstehungsort"]/a5145/text()')}", "#{record.xpath('.//../../a5140[text()="Stilistischer Entstehungsort"]/a5145/text()')}"].reject(&:blank?).join(" | ")
  end

  # Format
  def size
    number = record.xpath('count(../../a5364)')
    if !number.blank?
      (1..(number.to_i)).map{|index|
        "#{record.xpath(".//../../a5364[#{index}]/text()")}: #{record.xpath(".//../../a5364[#{index}]/a5365/text()")}"
      }
    else
      record.xpath('.//../../a5360/text()')
    end
  end

  # material
  def material
    "#{record.xpath('.//../../a5260/text()')}; #{record.xpath('.//../../a5300/text()')}".gsub(/\A; /, '').gsub(/; \z/, '')
  end

  # Gattung
  def genre
    ["#{record.xpath('.//../../a5220/text()')}", "#{record.xpath('.//../../a5226/text()')}", "#{record.xpath('.//../../a5230/text()')}"].reject(&:blank?).join(" | ")
  end

  def comment
    record.xpath('.//../../a599a/a599e/text()')
  end

  def provenance
    vorbesitzer = ["#{record.xpath('.//../../aob28[text()="Vorbesitzer"]/a2864/text()')}", "#{record.xpath('.//../../aob28[text()="Vorbesitzer"]/a2890/text()')}", "#{record.xpath('.//../../aob28[text()="Vorbesitzer"]/a2910/text()')}", "#{record.xpath('.//../../aob28[text()="Vorbesitzer"]/a2996/text()')}"].reject(&:blank?).join(", ")

    erster_vorbesitzer = ["#{record.xpath('.//../../aob28[text()="erster Vorbesitzer"]/a2864/text()')}", "#{record.xpath('.//../../aob28[text()="erster Vorbesitzer"]/a2890/text()')}", "#{record.xpath('.//../../aob28[text()="erster Vorbesitzer"]/a2910/text()')}", "#{record.xpath('.//../../aob28[text()="Vorbesitzer"]/a2996/text()')}"].reject(&:blank?).join(", ")

    zweiter_vorbesitzer = ["#{record.xpath('.//../../aob28[text()="zweiter Vorbesitzer"]/a2864/text()')}", "#{record.xpath('.//../../aob28[text()="zweiter Vorbesitzer"]/a2890/text()')}", "#{record.xpath('.//../../aob28[text()="zweiter Vorbesitzer"]/a2910/text()')}", "#{record.xpath('.//../../aob28[text()="Vorbesitzer"]/a2996/text()')}"].reject(&:blank?).join(", ")

    dritter_vorbesitzer = ["#{record.xpath('.//../../aob28[text()="dritter Vorbesitzer"]/a2864/text()')}", "#{record.xpath('.//../../aob28[text()="dritter Vorbesitzer"]/a2890/text()')}", "#{record.xpath('.//../../aob28[text()="dritter Vorbesitzer"]/a2910/text()')}", "#{record.xpath('.//../../aob28[text()="Vorbesitzer"]/a2996/text()')}"].reject(&:blank?).join(", ")

    vierter_vorbesitzer = ["#{record.xpath('.//../../aob28[text()="vierter Vorbesitzer"]/a2864/text()')}", "#{record.xpath('.//../../aob28[text()="vierter Vorbesitzer"]/a2890/text()')}", "#{record.xpath('.//../../aob28[text()="vierter Vorbesitzer"]/a2910/text()')}", "#{record.xpath('.//../../aob28[text()="Vorbesitzer"]/a2996/text()')}"].reject(&:blank?).join(", ")

    fünfter_vorbesitzer = ["#{record.xpath('.//../../aob28[text()="fünfter Vorbesitzer"]/a2864/text()')}", "#{record.xpath('.//../../aob28[text()="fünfter Vorbesitzer"]/a2890/text()')}", "#{record.xpath('.//../../aob28[text()="fünfter Vorbesitzer"]/a2910/text()')}", "#{record.xpath('.//../../aob28[text()="Vorbesitzer"]/a2996/text()')}"].reject(&:blank?).join(", ")

    sechster_vorbesitzer = ["#{record.xpath('.//../../aob28[text()="sechster Vorbesitzer"]/a2864/text()')}", "#{record.xpath('.//../../aob28[text()="sechster Vorbesitzer"]/a2890/text()')}", "#{record.xpath('.//../../aob28[text()="sechster Vorbesitzer"]/a2910/text()')}", "#{record.xpath('.//../../aob28[text()="Vorbesitzer"]/a2996/text()')}"].reject(&:blank?).join(", ")

    siebter_vorbesitzer = ["#{record.xpath('.//../../aob28[text()="siebter Vorbesitzer"]/a2864/text()')}", "#{record.xpath('.//../../aob28[text()="siebter Vorbesitzer"]/a2890/text()')}", "#{record.xpath('.//../../aob28[text()="siebter Vorbesitzer"]/a2910/text()')}", "#{record.xpath('.//../../aob28[text()="Vorbesitzer"]/a2996/text()')}"].reject(&:blank?).join(", ")

    vorhergehender_Besitzer = ["#{record.xpath('.//../../aob28[text()="vorhergehender Besitzer"]/a2864/text()')}", "#{record.xpath('.//../../aob28[text()="vorhergehender Besitzer"]/a2890/text()')}", "#{record.xpath('.//../../aob28[text()="vorhergehender Besitzer"]/a2910/text()')}", "#{record.xpath('.//../../aob28[text()="Vorbesitzer"]/a2996/text()')}"].reject(&:blank?).join(", ")

    vorhergehender_Eigentümer = ["#{record.xpath('.//../../aob28[text()="vorhergehender Eigentümer"]/a2864/text()')}", "#{record.xpath('.//../../aob28[text()="vorhergehender Eigentümer"]/a2890/text()')}", "#{record.xpath('.//../../aob28[text()="vorhergehender Eigentümer"]/a2910/text()')}", "#{record.xpath('.//../../aob28[text()="Vorbesitzer"]/a2996/text()')}"].reject(&:blank?).join(", ")

    vorhergehender_Eigentümer_Besitzer = ["#{record.xpath('.//../../aob28[text()="vorhergehender Eigentümer&amp;Besitzer"]/a2864/text()')}", "#{record.xpath('.//../../aob28[text()="vorhergehender Eigentümer&amp;Besitzer"]/a2890/text()')}", "#{record.xpath('.//../../aob28[text()="vorhergehender Eigentümer&amp;Besitzer"]/a2910/text()')}", "#{record.xpath('.//../../aob28[text()="Vorbesitzer"]/a2996/text()')}"].reject(&:blank?).join(", ")

    vorhergehender_Verwalter = ["#{record.xpath('.//../../aob28[text()="vorhergehender Verwalter"]/a2864/text()')}", "#{record.xpath('.//../../aob28[text()="vorhergehender Verwalter"]/a2890/text()')}", "#{record.xpath('.//../../aob28[text()="vorhergehender Verwalter"]/a2910/text()')}", "#{record.xpath('.//../../aob28[text()="Vorbesitzer"]/a2996/text()')}"].reject(&:blank?).join(", ")

    [erster_vorbesitzer, zweiter_vorbesitzer, dritter_vorbesitzer, vierter_vorbesitzer, fünfter_vorbesitzer, sechster_vorbesitzer, siebter_vorbesitzer, vorbesitzer, vorhergehender_Besitzer, vorhergehender_Eigentümer, vorhergehender_Eigentümer_Besitzer, vorhergehender_Verwalter]
  end

  def owner
    number = record.xpath('count(../../aob28[starts-with(text(),"Besitzer")])')
    standort_besitzer = (1..(number.to_i)).map{|index|
      "#{record.xpath(".//../../aob28[starts-with(text(),'Besitzer')][#{index}]/a2864/text()")}, #{record.xpath(".//../../aob28[starts-with(text(),'Besitzer')][#{index}]/a2900/text()")}, #{record.xpath(".//../../aob28[starts-with(text(),'Besitzer')][#{index}]/a2910/text()")}".gsub(/, ,/, '').gsub(/\A, /, '').gsub(/, \z/, '')
    }
    number2 = record.xpath('count(../../aob28[starts-with(text(),"Eigentümer")])')
    standort_eigentuemer = (1..(number2.to_i)).map{|index|
      "#{record.xpath(".//../../aob28[starts-with(text(),'Eigentümer')][#{index}]/a2864/text()")}, #{record.xpath(".//../../aob28[starts-with(text(),'Eigentümer')][#{index}]/a2900/text()")}, #{record.xpath(".//../../aob28[starts-with(text(),'Eigentümer')][#{index}]/a2910/text()")}".gsub(/, ,/, '').gsub(/\A, /, '').gsub(/, \z/, '')
    }
    [standort_besitzer, standort_eigentuemer].flatten
  end

  def production
    "#{record.xpath('.//../../aob35/a3600/text()')} (#{record.xpath('.//../../aob35/a3975/text()')})".gsub(/\(\)/, "")
  end

  # bildrecht
  def rights_reproduction
    "#{record.xpath('.//../a8460/text()')}; #{record.xpath('.//../a8490/text()')}".gsub(/\A; /, '').gsub(/; \z/, '')
  end

  def rights_work
    rights_work = record.xpath('.//../../a9266/text()')

    if is_any_artist_in_vgbk_artists_list?
      rights_work.to_a + [rights_work_vgbk]
    end
  end

  # abbildungsnachweis
  def credits
    "http://www.kulturelles-erbe-koeln.de/documents/obj/#{record.xpath('.//../../a5000/text()')}"
  end

  def literature
    ["#{record.xpath('.//../../a8330/text()')}", "#{record.xpath('.//../../a8330/a8334/text()')}"].reject(&:blank?).join(", ")
  end

  def exhibition
    record.xpath('.//../../a7790/text()')
  end

  # schlagwörter
  def iconclass
    record.xpath('.//../../a5560/text()') + record.xpath('.//../../a5500/text()')
  end

  def inscription
    "#{record.xpath('.//../../a5650[text()="Inschrift"]/a5686/text()')} (#{record.xpath('.//../../a5650[text()="Inschrift"]/a5694/text()')})".gsub(/\(\)/, "")
  end

  def signature
    record.xpath('.//../../a5650[text()="Signatur"]/a5686/text()')
  end

  def inventory_no
    record.xpath('.//../a8470/text()')
  end

  # Bild in Quelldatenbank
  def source_url
    "http://www.kulturelles-erbe-koeln.de/documents/obj/#{record.xpath('.//../../a5000/text()')}"
  end
end
