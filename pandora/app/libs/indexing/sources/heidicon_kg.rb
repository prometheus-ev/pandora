class Indexing::Sources::HeidiconKg < Indexing::Sources::Parents::Heidicon
  def path
    return miro if miro?

    super
  end

  def pool_name
    'IEK Europäische Kunstgeschichte'
  end
end
