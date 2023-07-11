class Indexing::Sources::ParisMusees < Indexing::SourceSuper

  CRD_IMAGES_URL = "http://parismuseescollections.paris.fr"

  CREATIVE_COMMONS_0_LINE = "Creative Commons Zero (CC0),https://creativecommons.org/publicdomain/zero/1.0/"
  URL_PARIS_MUSEES = "http://parismuseescollections.paris.fr/"
  NAME_PARIS_MUSEES = "Paris Musées"

  def records
    Indexing::XmlReaderNodeSet.new(document, "pm-entity", "//fieldVisuelsPrincipals/fieldVisuelsPrincipal[entity/fieldImageLibre=\"true\"]")
  end

  def record_id
    record.xpath('./entity/entityId/text()')
  end

  def record_object_id
    if record_object_id_count > 1
      [name, Digest::SHA1.hexdigest(record.xpath('../../entityId/text()').to_s)].join('-')
    end
  end

  def record_object_id_count
    record.xpath('../..').xpath('//fieldVisuelsPrincipal').count
  end

  def path
    record.xpath('./entity/publicUrl/text()').to_s.gsub(/\n/, "").gsub(/(#{CRD_IMAGES_URL})/, "").sub(/^(\/*)/,'')
  end

  ##############################################################################

  # künstler
  def artist
    record.xpath('../../fieldOeuvreAuteurs/fieldOeuvreAuteur/entity/fieldAuteurAuteur/entity').map do |entity|
      fieldPerson(entity)
    end.reject(&:blank?).join (" | ")
  end

  # titel
  def title
    record.xpath('../../title/text()')
  end

  # datierung
  def date
    fieldDate(record.xpath('../../fieldDateProduction'))
  end

  def date_range
    date_range = date.to_s

    if date_range.match?(/.*[(].*[)]/)
      date_range = date_range[/\((.*?)\)/, 1]
    end

    super(date_range)
  end

  # standort
  def location
    [
      record.xpath('../../fieldMusee/entity/fieldMuseeTitreCourt/text()'), 
      record.xpath('../../fieldMusee/entity/fieldAdresse/locality/text()')
    ].reject(&:blank?).join(", ")
  end

  # bildnachweis
  def credits
    [record.xpath('../../fieldMusee/entity/fieldMuseeTitreCourt/text()'), "#{NAME_PARIS_MUSEES},#{URL_PARIS_MUSEES}"].reject(&:blank?).join (", ")
  end

  def rights_reproduction
    CREATIVE_COMMONS_0_LINE
  end

  def rights_work
  end

  ##############################################################################

  def century
    record.xpath('../../fieldOeuvreSiecle/entity/name/text()')
  end

  def objecttype
    record.xpath('../../fieldOeuvreTypesObjet/fieldOeuvreTypesObjet/entity/name/text()').
      reject(&:blank?).join(" | ")
  end

  def genre
    record.xpath('../../fieldDenominations/fieldDenomination/entity/name/text()').
      reject(&:blank?).join(" | ")
  end

  def material_technique
    record.xpath('../../fieldMateriauxTechnique/fieldMateriauxTechnique/entity/name/text()').
      reject(&:blank?).join(" | ")
  end

  def size
    record.xpath('../../fieldOeuvreDimensions/fieldOeuvreDimension/entity').map do |entity|
      fieldDimension(entity)
    end.reject(&:blank?).join (" | ")
  end

  def inscription
    record.xpath('../../fieldOeuvreInscriptions/fieldOeuvreInscription/entity').map do |entity|
      fieldInscription(entity)
    end.reject(&:blank?).join (" | ")
  end

  def iconography
    record.xpath('../../fieldOeuvreDescriptionIcono/value/text()')
  end

  def history
    record.xpath('../../fieldCommentaireHistorique/value/text()')
  end

  def subject
    record.xpath('../../fieldOeuvreThemeRepresente/fieldOeuvreThemeRepresente/entity/name/text()').
      reject(&:blank?).join (" | ")
  end

  def place
    record.xpath('../../fieldLieuxConcernes/fieldLieuxConcern/entity/name/text()').
      reject(&:blank?).join (" | ")
  end

  def acquisition
    record.xpath('../../fieldModaliteAcquisition/entity/name/text()')
  end

  def donor
    record.xpath('../../fieldDonateurs/fieldDonateur/entity/name/text()').
      reject(&:blank?).join (" | ")
  end

  def acquisition_date
    fieldDate(record.xpath('../../fieldDateAcquisition'))
  end

  def inventory_no
    record.xpath('../../fieldOeuvreNumInventaire/text()')
  end

  def style_or_mouvement
    record.xpath('../../fieldOeuvreStyleMouvement/fieldOeuvreStyleMouvement/entity/name/text()').
      reject(&:blank?).join (" | ")
  end

  def exhibition
    record.xpath('../../fieldOeuvreExpose/entity/name/text()')
  end

  def epoch
    record.xpath('../../fieldOeuvreEpoquePeriode/fieldOeuvreEpoquePeriode/entity/name/text()').
      reject(&:blank?).join (" | ")
  end

  def production_place
    record.xpath('../../fieldOeuvreLieuxProduction/fieldOeuvreLieuxProduction/entity/name/text()').
      reject(&:blank?).join (" | ")
  end

  def discoveryplace
    record.xpath('../../fieldOeuvreLieuxDecouvertes/fieldOeuvreLieuxDecouverte/entity/name/text()').
      reject(&:blank?).join (" | ")
  end

  def discovery_date
    fieldDate(record.xpath('../../fieldOeuvreDateDecouverte'))
  end

  def description
    record.xpath('../../fieldDescription/value/text()')
  end

  def function
    record.xpath('../../fieldOeuvreFonction/fieldOeuvreFonction/entity/name/text()').
      reject(&:blank?).join (" | ")
  end

  def person_of_interest
    record.xpath('../../fieldPersonnesConcernees/fieldPersonnesConcernee/entity').map do |entity|
      fieldPerson(entity)
    end.reject(&:blank?).join (" | ")
  end

  def archives
    record.xpath('../../fieldArchivesEnRapport/fieldArchivesEnRapport/entity').map do |entity|
      fieldArchives(entity)
    end.reject(&:blank?).join (" | ")
  end

  def documentation
    record.xpath('../../fieldDocumentations/fieldDocumentation/entity').map do |entity|
      fieldDocumentation(entity)
    end.reject(&:blank?).join (" | ")
  end

  ##############################################################################

  private
    def fieldDate(fieldElement)
      start_date = [
        fieldElement.xpath('./startDay/text()'),
        fieldElement.xpath('./startMonth/text()'),
        fieldElement.xpath('./startYear/text()')
      ].reject(&:blank?).join("/")
      end_date = [
        fieldElement.xpath('./endDay/text()'),
        fieldElement.xpath('./endMonth/text()'),
        fieldElement.xpath('./endYear/text()')
      ].reject(&:blank?).join("/")

      date = [ 
        start_date, 
        end_date        
      ].reject(&:blank?).join(" - ")

      if !(century = fieldElement.xpath('./century/text()')).blank?
        if !date.blank?
          "#{century} (#{date})"
        else
          century
        end
      else
        date
      end
    end

    def fieldPerson(fieldElement)
      person = [
        fieldElement.xpath('./name/text()'),
        fieldElement.xpath('./fieldPipNomEquivalent/text()'),
      ].reject(&:blank?).join("; ")

      birth_year = fieldElement.xpath('./fieldPipDateNaissance/startYear/text()')
      death_year = fieldElement.xpath('./fieldPipDateDeces/startYear/text()')
      birth_place = fieldElement.xpath('./fieldPipLieuNaissance/text()')
      death_place = fieldElement.xpath('./fieldPipLieuDeces/text()')

      if person && (!birth_year.blank? || !death_year.blank? || !birth_place.blank? || !death_place.blank?)
        "#{person} (#{[birth_place, birth_year].reject(&:blank?).join(", ")} - #{[death_place, death_year].reject(&:blank?).join(", ")})"
      else
        person
      end
    end

    def fieldDimension(fieldElement)
      [
        [
          fieldElement.xpath('./fieldDimensionPartie/entity/name/text()'),
          fieldElement.xpath('./fieldDimensionType/entity/name/text()')
        ].reject(&:blank?).join(", "),
        [
          fieldElement.xpath('./fieldDimensionValeur/text()'),
          fieldElement.xpath('./fieldDimensionUnite/entity/name/text()')
        ].reject(&:blank?).join(" ")
      ].reject(&:blank?).join(": ")
    end

    def fieldInscription(fieldElement)
      [
        fieldElement.xpath('./fieldInscriptionType/entity/name/text()'),
        fieldElement.xpath('./fieldInscriptionEcriture/entity/name/text()'),
        fieldElement.xpath('./fieldInscriptionMarque/value/text()')
      ].reject(&:blank?).join(", ")
    end

    def fieldArchives(fieldElement)
      [
        fieldElement.xpath('./title/text()'),
        fieldElement.xpath('./fieldArchiveProducteurs/fieldArchiveProducteur/entity/name/text()').
          reject(&:blank?).join(" | "),
        fieldDate(fieldElement.xpath('./fieldArchivePeriodeConcernee'))
      ].reject(&:blank?).join(", ")
    end

    def fieldDocumentation(fieldElement)
      # fieldRessAuteurs/entity is always nil
      [
        fieldElement.xpath('./title/text()'),
        fieldElement.xpath('./fieldRessAutresTitre/fieldRessAutresTitre/entity/title/text()').
          reject(&:blank?).join(" | "),
        fieldElement.xpath('./fieldRessAdresseEditoriale/value/text()'),
        fieldElement.xpath('./fieldRessTomaison/text()'),
        fieldElement.xpath('./fieldRessPagination/text()'),
        fieldElement.xpath('./fieldRessTome/text()'),
        fieldElement.xpath('./fieldRessVolume/text()'),
        fieldElement.xpath('./fieldRessNumero/text()'),
        fieldElement.xpath('./fieldRessNumeroFascicule/text()')
      ].reject(&:blank?).join(", ")
    end

end
