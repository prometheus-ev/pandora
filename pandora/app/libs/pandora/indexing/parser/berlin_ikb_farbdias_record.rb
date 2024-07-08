class Pandora::Indexing::Parser::BerlinIkbFarbdiasRecord < Pandora::Indexing::Parser::Parents::BerlinIkbRecord
  def record_id
    record.xpath('.//Ressourcen-ID/text()')
  end

  def path
    "Scaler?&dh=2000&fn=#{record.at_xpath('.//bildvollbilddigilib/text()')}"
  end
end
