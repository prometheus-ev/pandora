class Indexing::Sources::BerlinIkbDias < Indexing::SourceSuper

  def records
    document.xpath('.//result')
  end

  def record_id
    record.xpath('.//id/text()')
  end

  def path
    record.at_xpath(".//fileUrl/text()").to_s.gsub(/http:\/\/imeji-mediathek.de\/imeji\/file\//, '')
  end

  def artist
   record.xpath('.//metadata/Subject-Artist/Subject-Artist/text()')
  end

  def title
    "#{record.xpath('.//metadata/SUBJECT-Name/SUBJECT-Name/SUBJECT-Name/text()')}, #{record.xpath('.//metadata/SUBJECT-Name/SUBJECT-Name/Detail/Detail/text()')}".gsub(/\A, /, '').gsub(/, \z/, '')
  end

  def description
    record.xpath('.//metadata/Description-Slide/text()')
  end

  def location
    record.xpath('.//metadata/Subject-Place-Architecture/text()')
  end

  def inventory_no
    record.xpath('.//metadata/Inscriptions/Inventory-No./text()')
  end

  def taxonomy
    record.xpath('.//metadata/Taxonomy/text()')
  end

  def inscription
    record.xpath('.//metadata/Inscriptions/Inscriptions/text()')
  end

  def marks
    record.xpath('.//metadata/Inscriptions/Other-marks/Other-mark/text()')
  end

  def labels_collection
    record.xpath('.//metadata/Inscriptions/Labels-Collection/Labels-Collection/text()')
  end

  def labels_creator
    record.xpath('.//metadata/Inscriptions/Labels-Creator/text()')
  end

  def slide_creator
    record.xpath('.//metadata/SLIDE-CreatorPhotographer/SLIDE-CreatorPhotographer/SLIDE-CreatorPhotographer/text()')
  end

  def date
    production_master_date = record.xpath('.//metadata/MASTER-Creator/Date-of-production-master/text()').to_s.strip
    production_slide_date = record.xpath('.//metadata/SLIDE-CreatorPhotographer/SLIDE-CreatorPhotographer/Date-of-production-slide/text()').to_s.strip

    if !production_master_date.blank? && !production_slide_date.blank?
      "#{record.xpath('.//metadata/MASTER-Creator/Date-of-production-master/text()')} (Bildvorlage), #{record.xpath('.//metadata/SLIDE-CreatorPhotographer/SLIDE-CreatorPhotographer/Date-of-production-slide/text()')} (Dia)".gsub(/\A \(Bildvorlage\), /,'').gsub(/\A \(Dia\)/,'').gsub(/,  \(Dia\)/,'')
    elsif !production_master_date.blank?
      "#{record.xpath('.//metadata/MASTER-Creator/Date-of-production-master/text()')} (Bildvorlage)".gsub(/\A \(Bildvorlage\), /,'').gsub(/\A \(Dia\)/,'').gsub(/,  \(Dia\)/,'')
    elsif !production_slide_date.blank?
      "#{record.xpath('.//metadata/SLIDE-CreatorPhotographer/SLIDE-CreatorPhotographer/Date-of-production-slide/text()')} (Dia)".gsub(/\A \(Bildvorlage\), /,'').gsub(/\A \(Dia\)/,'').gsub(/,  \(Dia\)/,'')
    end

  end

  def date_range
    # Preprocess.
    production_master_date = record.xpath('.//metadata/MASTER-Creator/Date-of-production-master/text()').to_s.strip
    production_slide_date = record.xpath('.//metadata/SLIDE-CreatorPhotographer/SLIDE-CreatorPhotographer/Date-of-production-slide/text()').to_s.strip

    if !production_master_date.blank?
      super(production_master_date)
    elsif !production_slide_date.blank?
      super(production_slide_date)
    end
  end

  def credits
    record.xpath('.//metadata/MASTER-Creator/MASTER-Creator/text()')
  end

  def reference_master
    link_labels = record.xpath('.//metadata/reference-master/link/text()')
    link_uris = record.xpath('.//metadata/reference-master/url/text()')
    links = (0..(link_uris.length-1)).map{ |index| "#{link_labels[index]},#{link_uris[index]}"}
  end

  def external_references
    link_labels = record.xpath('.//metadata/external-References/external-Reference/link/text()')
    link_uris = record.xpath('.//metadata/external-References/external-Reference/url/text()')
    links = (0..(link_uris.length-1)).map{ |index| "#{link_labels[index]},#{link_uris[index]}"}
  end

  # Return an Array of String elements in form of "name,URL".
  # The Array elements will be transformed to links in pandora
  # @see app/helpers/application_helper.rb, def link_to_links(name_and_url)
  # @todo Evaluate saving HTML links directly into the index.
  def authority_files
    link_labels = record.xpath('.//metadata/SUBJECT-Name/SUBJECT-Name/Authority-Files/Authority-File/link/text()')
    link_uris = record.xpath('.//metadata/SUBJECT-Name/SUBJECT-Name/Authority-Files/Authority-File/url/text()')
    links = (0..(link_uris.length-1)).map{ |index| "#{link_labels[index]},#{link_uris[index]}"}
  end

  def license
    record.xpath('.//metadata/License/text()')
  end

  def comment
    record.xpath('.//metadata/remarks/text()')
  end

  def rights_reproduction
    record.xpath('.//metadata/License/text()')
  end

  def rights_work
    record.xpath('.//metadata/License/text()')
  end

  def status_record
    record.xpath('.//metadata/status-of-the-record/text()')
  end

  def source_url
    "http://imeji-mediathek.de/imeji/item/#{record.xpath('.//id/text()')}"
  end
end
