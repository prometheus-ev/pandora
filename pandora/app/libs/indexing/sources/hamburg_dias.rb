class Indexing::Sources::HamburgDias < Indexing::SourceSuper
  def records
    document.xpath('//bilder/bild')
  end

  def record_id
    record.xpath('./files/file/eas-id/text()')
  end

  def path
    "#{record.at_xpath('.//files/file/versions/version[@name="original"]/url/text()')}".sub(/http:\/\/kultdokuhh.fbkultur.uni-hamburg.de\//, '').sub(/http:\/\/localhost\//, '').sub(/https:\/\/kultdokuhh4.fbkultur.uni-hamburg.de\//,'').sub(/http:\/\/kultdokuhh-4.fbkultur.uni-hamburg.de\//,'').sub(/https:\/\/kultdokuhh-4.fbkultur.uni-hamburg.de\//,'')
  end

  # titel
  def title
    record.xpath('ancestor::bilder/dias_bildinhalt/text()')
  end

  # standort
  def location
    "Dia: #{record.xpath('ancestor::bilder/dias_lk_eigentuemer_id/dias_personen/name/text()')}"
  end

  def owner
    record.xpath('ancestor::bilder/dias_lk_eigentuemer_id/dias_personen/name/text()')
  end

  def previous_owner
    record.xpath('ancestor::bilder/_nested__bilder__dias_vorbesitzer/bilder__dias_vorbesitzer/lk_person_id/dias_personen/name/text()')
  end

  def inventory_no
    record.xpath('ancestor::bilder/dias_eigentuemer_inv_nr/text()')
  end

  # hersteller
  def slide_creator
    record.xpath('ancestor::bilder/dias_lk_hersteller_id/dias_personen/name/text()')
  end

  def taxonomy
    record.xpath('ancestor::bilder/dias_ordnungsschema/text()')
  end

  # technik
  def material
    record.xpath('ancestor::bilder/dias_lk_material_id_neu/dias_attribute_dias_material/name/text()')
  end

  # Masse
  def size
    record.xpath('ancestor::bilder/dias_lk_masse_id_neu/dias_attribute_dias_masse/name/text()')
  end

  # abbildungsnachweis
  def credits
    record.xpath('ancestor::bilder/dias_quelle/text()')
  end
end
