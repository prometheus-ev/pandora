class Indexing::Sources::MarburgLba < Indexing::SourceSuper
  def records
    document.xpath('//Datensatz')
  end

  def record_id
    [record.xpath('.//Zugangsnummer/text()').to_s, record.xpath('.//Negativnummer/text()').to_s]
  end

  def path
    dirty = %Q{width/"5000"/height/"5000"/url/"http:{|}{|}137.248.186.134{|}lba-cgi-local{|}pic.sh{-}jpg{|}#{record.at_xpath('.//Negativnummer/text()')}.jpg"}
    dirty.
      gsub('"', '%22').
      gsub('{', '%7B').
      gsub('|', '%7C').
      gsub('}', '%7D')
  end

  def negative_identifier
    record.xpath('.//Negativnummer/text()')
  end

  def record_identifier
    record.xpath('.//Zugangsnummer/text()')
  end

  # titel
  def title
    "Siegel (Urkunde von #{record.xpath('.//Aussteller/text()')} f&uuml;r #{record.xpath('.//Empfaenger/text()')})".gsub(/\(Urkunde von f&uuml;r \)/, "").gsub(/f&uuml;r \)$/, "").gsub(/von  /, "")
  end

  # Aussteller
  def issuer_of_charter
    record.xpath('.//Aussteller/text()')
  end

  # Empfänger
  def beneficiary_of_charter
    record.xpath('.//Empfaenger/text()')
  end

  def other_seals
    record.xpath('.//Mitsiegler/text()')
  end

  def type_seal
    record.xpath('.//Siegel_Art/text()')
  end

  def original_number_of_seals
    record.xpath('.//Anzahl_Siegel_orig/text()')
  end

  def number_of_preserved_seals
    record.xpath('.//Anzahl_Siegel_praes/text()')
  end

  # datierung
  def date
    "#{record.xpath('.//Ausstellungsdatum/text()')} (Ausstellungsdatum)"
  end

  def date_range
    d = record.xpath('.//Ausstellungsdatum/text()').to_s.strip

    super(d)
  end

  # groesse
  def size
    record.xpath('.//Format/text()')
  end

  # aufbewahrungsort
  def location
    record.xpath('.//Archiv/text()')
  end

  # Ausstellungsort
  def place_of_issue
    record.xpath('.//Ausstellungsort/text()')
  end

  # Signatur
  def signature
    record.xpath('.//Signatur/text()')
  end

  # Druck
  def edition
    record.xpath('.//Druck/text()')
  end

  # Überlieferung
  def tradition
    record.xpath('.//Ueberlieferung/text()')
  end

  # Bemerkung
  def annotation
    record.xpath('.//Bemerkungen/text()')
  end

  # bildnachweis
  def credits
    'Lichtbildarchiv Älterer Originalurkunden (LBA) bis 1250'
  end

  # Bild in Quelldatenbank
  def source_url
    "http://lba.hist.uni-marburg.de/lba-cgi/kleioc/0010KlLBA/exec/showrecord/zugangsnummer/%22#{record.xpath('.//Zugangsnummer/text()')}%22"
  end
end
