class Pandora::Indexing::Parser::HamburgRecord < Pandora::Indexing::Parser::Parents::HamburgRecord
  def record_id
    return @record_id if @record_id

    text = "#{record.xpath('./easydb4_reference/text()')}"

    @record_id = if text.blank?
      record.xpath('./bild/files/file/eas-id/text()')
    else
      current_id = text.sub(/Bilder:/, "")
      @mapping[current_id] || current_id
    end
  end

  def path
    return @miro_parser.miro if @miro_parser.miro?(record_id, name)

    super
  end
end
