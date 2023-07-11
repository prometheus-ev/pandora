class Indexing::Sources::Leipzig < Indexing::Sources::Parents::Dilps
  def path
    return miro if miro?

    path_for('kuge_leipzig')
  end

  def date_range
    super(date)
  end
end
