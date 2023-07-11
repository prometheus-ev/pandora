class Indexing::Sources::KasselKuwi < Indexing::Sources::Parents::Dilps
  def path
    path_for('kassel_kuwi')
  end

  def date_range
    super(date)
  end
end
