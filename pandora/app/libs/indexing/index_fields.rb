class Indexing::IndexFields
  # Custom mapping fields used in class IndexMappings.
  # @see app/libs/indexing/index_mappings.rb
  def self.index_mapping
    index -
    ['record_id',
     'record_object_id',
     'record_object_id_count',
     'artist_nested',
     'artist_nested.dating',
     'artist_nested.name',
     'artist_nested.wikidata',
     'artist',
     'artist_normalized',
     'artist_wikidata',
     'title_nested',
     'title_nested.name',
     'title_nested.wikidata',
     'title',
     'license_nested',
     'license_nested.name',
     'license_nested.url',
     'location_nested',
     'location_nested.name',
     'location_nested.wikidata',
     'location',
     'date',
     'date_range',
     'date_range_from',
     'date_range_to',
     'credits_nested',
     'credits_nested.link_text',
     'credits_nested.link_url',
     'credits',
     'rights_work',
     'rights_reproduction_nested',
     'rights_reproduction_nested.license',
     'rights_reproduction_nested.license_url',
     'rights_reproduction_nested.name',
     'rights_reproduction_nested.wikidata',
     'rights_reproduction',
     'rating_average',
     'description',
     'person_nested',
     'person_nested.dating',
     'person_nested.name',
     'person_nested.wikidata',
     'authority_files',
     'authority_files.label',
     'authority_files.id',
     'image_vector']
  end

  def self.sort
    ['relevance',
     'artist',
     'title',
     'location',
     'date',
     'credits',
     'rights_work',
     'rights_reproduction',
     'rating_average',
     'rating_count']
  end

  # Search field select box fields.
  def self.search
    ['all',
     'all_with_keyword_artigo',
     'artist',
     'title',
     'location',
     'discoveryplace',
     'genre',
     'material',
     'keyword',
     'description',
     'date',
     'credits',
     'rights_work',
     'rights_reproduction',
     'record_id',
     'record_object_id',
     'rating_average',
     'rating_count',
     'user_comments']
  end

  def self.search_mapping(field:)
    case field
    when 'all'
      all
    when 'all_with_keyword_artigo'
      all + ['keyword_artigo']
    when 'artist'
      ['artist^2',
       'artist_nested.dating',
       'artist_nested.name',
       'artist_nested.wikidata',
       'artist_normalized',
       'identity_artist']
    when 'title'
      ['title^2',
       'title_nested.name',
       'title_nested.wikidata',
       'subtitle']
    when 'location'
      ['location',
       'location_nested.name',
       'location_nested.wikidata',
       'institution']
    when 'discoveryplace'
      ['discoveryplace']
    when 'genre'
      ['genre']
    when 'material'
      ['material']
    when 'keyword'
      ['keyword',
       'keyword_artigo']
    when 'description'
      ['description']
    when 'date'
      ['date']
    when 'credits'
      ['credits',
       'credits_nested.link_text',
       'credits_nested.link_url',
       'rights_reproduction']
    when 'rights_reproduction'
      ['rights_reproduction',
       'rights_reproduction_nested.license',
       'rights_reproduction_nested.license_url',
       'rights_reproduction_nested.name',
       'rights_reproduction_nested.wikidata']
    when 'rights_work'
      ['rights_work']
    # Use the raw, unanalyzed string field to find exact matches.
    when 'record_id'
      ['record_id.raw']
    # Use the raw, unanalyzed string field to find exact matches.
    when 'record_object_id'
      ['record_object_id.raw']
    # Use the raw, unanalyzed float field to find number matches.
    when 'rating_average'
      ['rating_average.raw']
    # Integer fields do not need to use raw.
    when 'rating_count'
      ['rating_count']
    when 'user_comments'
      ['user_comments']
    else
      raise Pandora::Exception, "There is no mapping defined for field '#{field}'."
    end
  end

  def self.display
    index - non_display
  end

  def self.display_upload
    display - non_display_upload
  end

  def self.display_app
    display + ['database']
  end

  def self.non_display
    ['artist_normalized',
     # 'artist' is used as display field.
     'artist_nested',
     'artist_nested.dating',
     'artist_nested.name',
     'artist_nested.wikidata',
     'artist_wikidata',
     'comment_count',
     'credits_nested',
     'credits_nested.link_text',
     'credits_nested.link_url',
     'date_range',
     'iframe_url',
     'image_vector',
     'license_nested',
     'license_nested.name',
     'license_nested.url',
     # 'location' is used as display field.
     'location_nested',
     'location_nested.name',
     'location_nested.wikidata',
     'path',
     'person_nested.dating',
     'person_nested.name',
     'person_nested.wikidata',
     'rating_average',
     'rating_count',
     'record_id',
     'record_id_original',
     # 'rights_reproduction' is used as display field.
     'rights_reproduction_nested',
     'rights_reproduction_nested.license',
     'rights_reproduction_nested.license_url',
     'rights_reproduction_nested.name',
     'rights_reproduction_nested.wikidata',
     'source_url',
     'user_comments',
     # 'title' is used as display field.
     'title_nested',
     'title_nested.name',
     'title_nested.wikidata']
  end

  def self.non_display_upload
    ['owner']
  end

  def self.all
    # Remove fields which do not have type 'text'.
    all = index - ['comment_count', 'date_range', 'image_vector']
    # Remove fields which will be boosted.
    all = all - ['artist', 'title']
    # Remove keyword_artigo, see #1636.
    all = all - ['keyword_artigo']
    # Prepend boost fields.
    all.prepend('artist^2', 'title^2')
  end

  def self.location
    ['country',
     'discoveryplace',
     'geographic_coordinates',
     'location',
     'location_building',
     'manufacture_place',
     'manufacture_place_city',
     'manufacture_place_grave',
     'manufacture_place_region',
     'place',
     'place_of_issue',
     'pictured_location',
     'printing_place',
     'production_place',
     'publicationplace',
     'venue']
  end

  # All index fields.
  def self.index
    # Show the search result list fields first.
    ['artist',
     'artist_nested',
     'artist_nested.dating',
     'artist_nested.name',
     'artist_nested.wikidata',
     'title',
     'title_nested',
     'title_nested.name',
     'title_nested.wikidata',
     'location',
     'location_nested',
     'location_nested.name',
     'location_nested.wikidata',
     'date',
     'credits',
     'credits_nested',
     'credits_nested.link_text',
     'credits_nested.link_url',
     'rights_work',
     'rights_reproduction',
     'rights_reproduction_nested',
     'rights_reproduction_nested.license',
     'rights_reproduction_nested.license_url',
     'rights_reproduction_nested.name',
     'rights_reproduction_nested.wikidata',
     # Ratings and comments.
     'rating_count',
     'rating_average',
     'comment_count',
     'user_comments',
     # All other fields in alphabetical order.
     'acquisition',
     'acquisition_date',
     'addition',
     'adopted_from',
     'annotation',
     'annotation_technical',
     'archives',
     'artist_information',
     'artist_normalized',
     'artist_wikidata',
     'authority_files',
     'authority_files.label',
     'authority_files.id',
     'authority_files_artist',
     'based_on',
     'beneficiary_of_charter',
     'biographical_data',
     'building',
     'caption',
     'carrier_medium',
     'catalogue',
     'century',
     'circumference',
     'classification',
     'collection',
     'colour',
     'comment',
     'commissioning',
     'condition',
     'constituents',
     'containerform',
     'context_of_publication',
     'corporate_body',
     'costumer',
     'country',
     'creation_context',
     'culture',
     'date_original',
     'date_range',
     'department',
     'depository',
     'depth',
     'description',
     'description_source',
     'detail',
     'diameter',
     'dimensions',
     'discoverycontext',
     'discoveryplace',
     'discovery_date',
     'documentation',
     'donor',
     'edition',
     'editions',
     'engraver',
     'epoch',
     'exhibition',
     'external_references',
     'footnote',
     'format_foto',
     'former_location',
     'frame',
     'function',
     'further_context_of_publication',
     'genre',
     'geographic_coordinates',
     'granted_by',
     'group_works',
     'height',
     'height_relief',
     'history',
     'iconclass',
     'iconclass_description',
     'iconography',
     'iframe_url',
     'image_code',
     'image_information',
     'image_vector',
     'identity_artist',
     'inscription',
     'institution',
     'inventory_no',
     'isbn',
     'issuer_of_charter',
     'keyword',
     'keyword_artigo',
     'keyword_content',
     'keyword_general',
     'keyword_location',
     'keyword_person',
     'keyword_main_topic',
     'keyword_denotated_connotated_incidents_ontogenetics',
     'keyword_collections',
     'keyword_persons_beings_objects',
     'keyword_composition_proximity_persons_objects',
     'keyword_posture',
     'keyword_gestics',
     'keyword_mimics',
     'keyword_gaze',
     'keyword_body_movement',
     'keyword_emotions',
     'keywords',
     'labels_collection',
     'labels_creator',
     'language',
     'length',
     'library_origin',
     'license',
     'license_nested',
     'license_nested.name',
     'license_nested.url',
     'links',
     'literature',
     'location_building',
     'made_by',
     'manufacture_place',
     'manufacture_place_city',
     'manufacture_place_grave',
     'manufacture_place_region',
     'maps',
     'marks',
     'material',
     'material_technique',
     'measure',
     'modification',
     'motif',
     'negative_identifier',
     'notationnote',
     'number_of_preserved_seals',
     'objecttype',
     'origin',
     'origin_point',
     'original_number_of_seals',
     'other_seals',
     'owner',
     'part_of',
     'path',
     'pattern',
     'person',
     'person_nested',
     'person_nested.dating',
     'person_nested.name',
     'person_nested.wikidata',
     'person_of_interest',
     'photoagency',
     'photographer',
     'photographed_location',
     'photographic_context',
     'photographic_type',
     'picture_variation',
     'pictured_location',
     'place',
     'place_of_issue',
     'plan',
     'pool',
     'portrayal',
     'previous_owner',
     'print',
     'printdetails',
     'printer',
     'printingplace',
     'production',
     'production_place',
     'provenance',
     'publication',
     'publicationplace',
     'publisher',
     'published_in',
     'reception',
     'record_id',
     'record_id_original',
     'record_identifier',
     'record_object_id',
     'record_object_id_count',
     'reference_master',
     'related_works',
     'restauration',
     'restoration_history',
     'restriction',
     'scene',
     'sealing',
     'series',
     'sheetsize',
     'short_explanation',
     'shot',
     'shot_composition',
     'signature',
     'similar_pictures_collection',
     'size',
     'slide_creator',
     'sound',
     'source_url',
     'source_type',
     'state',
     'status_record',
     'structural_element',
     'structural_type',
     'style_or_mouvement',
     'subject',
     'subtitle',
     'taxonomy',
     'technique',
     'text',
     'textform',
     'title_variants',
     'topic',
     'tradition',
     'venue',
     'view',
     'watermark',
     'weblink_literature',
     'weight',
     'width',
     'work_catalogue',
     'year']
  end
end
