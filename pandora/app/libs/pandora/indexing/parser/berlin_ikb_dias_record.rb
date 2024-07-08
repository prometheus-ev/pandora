class Pandora::Indexing::Parser::BerlinIkbDiasRecord < Pandora::Indexing::Parser::Parents::BerlinIkbRecord
  def record_id
    if !(importsource = "#{record.xpath('.//importsource/text()')}").empty?
      importsource.gsub(/http:\/\/imeji-mediathek.de\/imeji\/item\//, '')
    else
      record.xpath('.//Ressourcen-ID/text()')
    end
  end

  def path
    "download.php?ref=#{record.at_xpath('.//Ressourcen-ID/text()')}&size=scr&ext=jpg&noattach=true"
  end
end
