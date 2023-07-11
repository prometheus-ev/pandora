class Pandora::Indexing::Parser::BochumUgRecord < Pandora::Indexing::Parser::Parents::DilpsRecord
  def path
    path_for('bochum_ug')
  end

  def date_range
    return @date_range if @date_range

    d = date.sub '?', ''
    d = d.strip

    @date_range = @date_parser.date_range(d)
  end
end
