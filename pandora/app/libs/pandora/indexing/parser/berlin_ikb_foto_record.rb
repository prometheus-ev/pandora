class Pandora::Indexing::Parser::BerlinIkbFotoRecord < Pandora::Indexing::Parser::Parents::BerlinIkbRecord
  def record_id
    record.xpath('.//Ressourcen-ID/text()')
  end

  def path
    "download.php?ref=#{record.at_xpath('.//Ressourcen-ID/text()')}&size=scr&ext=jpg&noattach=true"
  end
end
