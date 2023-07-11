class Indexing::Sources::BochumUg < Indexing::Sources::Parents::Dilps
  def path
    path_for('bochum_ug')
  end

  def date_range
    d = date.sub '?', ''
    d = d.strip

    super(d)
  end
end
