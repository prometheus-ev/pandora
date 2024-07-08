class Pandora::Indexing::Parser::HamburgDiasRecord < Pandora::Indexing::Parser::Parents::HamburgRecord
  def title
    record.xpath('./dias_bildinhalt/text()').to_s
  end

  def location
    location = "#{record.xpath('./dias_lk_eigentuemer_id/dias_personen/name/text()')}"

    unless location.blank?
      "Dia: #{location}"
    end
  end

  def owner
    record.xpath('./dias_lk_eigentuemer_id/dias_personen/name/text()')
  end

  def previous_owner
    record.xpath('./_nested__bilder__dias_vorbesitzer/bilder__dias_vorbesitzer/lk_person_id/dias_personen/name/text()')
  end

  def inventory_no
    record.xpath('./dias_eigentuemer_inv_nr/text()')
  end

  def slide_creator
    record.xpath('./dias_lk_hersteller_id/dias_personen/name/text()')
  end

  def taxonomy
    record.xpath('./dias_ordnungsschema/text()')
  end

  def material
    record.xpath('./dias_lk_material_id_neu/dias_attribute_dias_material/name/text()')
  end

  def size
    record.xpath('./dias_lk_masse_id_neu/dias_attribute_dias_masse/name/text()')
  end

  def credits
    record.xpath('./dias_quelle/text()')
  end
end
