class Pandora::Indexing::Parser::Dresden < Pandora::Indexing::Parser::XmlReader
  def initialize(source)
    source[:kind] = Source::KINDS[:institutional]
    records_to_exclude = %w[21370 23516 59386 83893 85736 89303 90378 155528 155529 155530 155531 155532 155481 155490 155491 155492 155493 155494 155495 155496 155497 155498 155499 155482 155500 155501 155502 155503 155504 155505 155506 155507 155508 155509 155483 155510 155511 155512 155513 155514 155515 155516 155517 155518 155519 155484 155520 155521 155522 155523 155524 155525 155526 155527 155485 155486 155487 155488 155489]

    super(source,
      record_node_name: "row",
      records_to_exclude: records_to_exclude)
  end

  def preprocess
    Pandora.puts "#{@source[:name]}: loading MiroParser..."
    @miro_parser = Pandora::Indexing::Parser::MiroParser.new(@source[:name])

    super
  end
end
