class Pandora::Indexing::Parser::BerlinWinckelmann < Pandora::Indexing::Parser::XmlReader
  def initialize(source)
    source[:kind] = Source::KINDS[:institutional]
    records_to_exclude = %w[53468 53469 53470 53471 53472 53473 53474 53475 53476 53477 53478 53479 53480 53481 53482 53483 53484 53485 53486 53487 53488 53489 53490 53491 53492 53493 53494 53495 53496 53497 53498 53499 53500 53501 53502 53503 53504 53505 53506 53507 53508 53509 53510 53511 53512 53513 53514 53515 53665 53666 53667]

    super(
      source,
      record_node_name: 'OBJECT',
      records_to_exclude: records_to_exclude)
  end
end
