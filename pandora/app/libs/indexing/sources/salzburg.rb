class Indexing::Sources::Salzburg < Indexing::Sources::Parents::Dilps
  def path
    path_for('salzburg_khi')
  end

  # epoche
  def epoch
    record.xpath('.//Epoche/text()')
  end

  # signature
  def signature
    record.xpath('.//Signatur/text()')
  end

  # inventory_no
  def inventory_no
    record.xpath('.//Inventarnummer/text()')
  end
end
