class Indexing::IndexFields
  def self.indexing
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

  # Fields used in class IndexMappings.
  def self.index_mapping
    ['location',
     'discoveryplace',
     'genre',
     'material',
     'keyword',
     'credits',
     'rights_work',
     'rights_reproduction',
     'rating_count',
     'user_comments']
  end

  # Search field select box fields.
  def self.search
    ['all',
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
      # Search in all index fields.
      # Remove fields which do not have type 'text'.
      # Remove fields which will be boosted.
      all = index - ['comment_count', 'date_range', 'image_vector'] - ['artist', 'title']
      # Prepend boost fields.
      all.prepend('artist^2', 'title^2')
    when 'artist'
      ['artist^2',
       'artist_normalized',
       'identity_artist']
    when 'title'
      ['title^2',
       'subtitle']
    when 'location'
      ['location',
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
       'rights_reproduction']
    when 'rights_reproduction'
      ['rights_reproduction']
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
    when 'comment_count'
      ['comment_count']
    when 'user_comments'
      ['user_comments']
    else
      raise Pandora::Exception, "There is no mapping defined for field '#{field}'."
    end
  end

  def self.display
    index - non_display
  end
  
  def self.non_display
    ['artist_normalized',
     'comment_count',
     'date_range',
     'image_vector',
     'keyword_artigo',
     'path',
     'rating_average',
     'rating_count',
     'record_id',
     'record_id_original',
     'record_object_id',
     'source_url',
     'user_comments']
  end

  def self.index
    # Show the search result list fields first.
    ['artist',
     'title',
     'location',
     'date',
     'credits',
     'rights_work',
     'rights_reproduction',
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
     'authority_files',
     'authority_files_artist',
     'based_on',
     'beneficiary_of_charter',
     'biographical_data',
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
     'person_of_interest',
     'photoagency',
     'photographer',
     'photographed_location',
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
     'reference_master',
     'related_works',
     'restauration',
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
