class Indexing::Sources::ArtemisBk < Indexing::Sources::Parents::Artemis
  def records
    document.xpath('//datensatz[contains(bemerkung, "Bayerische Kunstgeschichte")]')
  end
end
