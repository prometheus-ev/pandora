class Indexing::Sources::OldenburgAfrika < Indexing::Sources::Parents::Dilps
  def path
    path_for('oldenburg_uni_afrika')
  end

  def date_range
    super(date)
  end
end
