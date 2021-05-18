require 'net/http'
require 'uri'

namespace :harvest do
  namespace :classicmayan do

    ### harvest

    ENTITIES_BASE_URL = "https://classicmayan.kor.de.dariah.eu/api/oai-pmh/entities"
    RELATIONSHIPS_BASE_URL = "https://classicmayan.kor.de.dariah.eu/api/oai-pmh/relationships"

    LIST_RECORDS_VERB = "ListRecords"
    METADATA_PREFIX = "kor"

    OAI_PMH_NAMESPACE = "http://www.openarchives.org/OAI/2.0/"
    KOR_NAMESPACE = "https://coneda.net/XMLSchema/1.1/"

    ### extract

    ARTEFACT = { name: "artefact", uid: "fd912460-88df-4c3e-adde-492ed761a79f" }
    COLLECTION = { name: "collection", uid: "f6054973-2531-4c4d-9275-ca90e419fa73" }
    HOLDER = { name: "holder", uid: "6d9249b1-d9f1-41c0-a4a2-d2f11386decc" }
    MEDIUM = { name: "medium", uid: "93a03d5c-e439-4294-a8d4-d4921c4d0dbc" }
    PERSON = { name: "person", uid: "935d8b1a-ff3e-402f-a4d0-96ed41b3acdd" }
    PLACE = { name: "place", uid: "ff799435-1764-4a29-835c-ad6ad3f7585c" }
    PROVENANCE = { name: "provenance", uid: "bdf8db6b-976a-4c7d-af3b-055128806205" }

    ARTEFACT_IS_WAS_LOCATED_IN_PLACE = { name: "artefact is / was located in place" , uid: "165a8dce-8fdf-4264-8cff-0bf83561b3ec" }
    ARTEFACT_IS_DEPICTED_BY_MEDIUM = { name: "artefact is depicted by medium" , uid: "6326599b-3ebd-4c46-be87-b26ebdb58b36" }
    ARTEFACT_HAS_ARTEFACT_PART = { name: "artefact has artefact part" , uid: "09e7ce7e-f9ef-497c-9290-854f1f5c07fd" }
    ARTEFACT_IS_RELATED_WITH_ARTEFACT = { name: "artefact is related with artefact" , uid: "efe115cb-2263-4b83-a70f-200ac63545c2" }
    ARTEFACT_ORIGINATES_FROM_PROVENANCE = { name: "artefact originates from provenance" , uid: "f11af951-4de0-460e-bf63-031946503a7a" }
    ARTEFACT_WAS_DOCUMENTED_BY_PERSON = { name: "artefact was documented by person" , uid: "1f46a281-f57b-408f-b716-17c55a953638" }
    COLLECTION_HOLDS_HELD_ARTEFACT = { name: "collection holds / held artefact" , uid: "c834cb70-ecbe-4f94-b4e2-29fa6e8f4914" }
    COLLECTION_IS_WAS_HELD_BY_HOLDER = { name: "collection is / was held by holder" , uid: "bf5df40b-2481-4f6e-a0e1-14b95d5b09a3" }
    COLLECTION_IS_WAS_LOCATED_IN_PLACE = { name: "collection is / was located in place" , uid: "ac0969c6-5eb2-4547-b4ec-b4dca422eb23" }
    HOLDER_DOCUMENTED_ARTEFACT = { name: "holder documented artefact" , uid: "abfcfd41-506e-43e5-8a63-4a1d604b9bda" }
    HOLDER_IS_WAS_LOCATED_IN_PLACE = { name: "holder is / was located in place" , uid: "a46d5a7d-e864-425c-84b2-7745b3936bb9" }
    MEDIUM_DEPICTS_PERSON = { name: "medium depicts person" , uid: "7a412234-4753-452e-87ff-eb43db722d79" }
    MEDIUM_WAS_CREATED_AT_PLACE = { name: "medium was created at place" , uid: "5fe67ef4-71b5-4b5b-a576-5ba7baa1d06a" }
    MEDIUM_WAS_CREATED_BY_HOLDER = { name: "medium was created by holder" , uid: "f6d4a0a1-2361-4ec3-8786-b7d6e281374d" }
    MEDIUM_WAS_CREATED_BY_PERSON = { name: "medium was created by person" , uid: "4c03ca36-28ce-4e8d-bb00-4e789c9bd94f" }
    MEDIUM_WAS_CREATED_FROM_COLLECTION = { name: "medium was created from collection" , uid: "3a9e6518-e1a5-4af4-a0ed-69ea2caa8b52" }
    PLACE_IS_WAS_LOCATED_IN_PLACE = { name: "place is / was located in place" , uid: "8cd862e9-8b78-4c70-898a-0e18badc698d" }
    PLACE_WAS_VISITED_BY_PERSON = { name: "place was visited by person" , uid: "bbc24837-3152-4dde-a334-12c8536e82aa" }

    FROM = "from"
    TO = "to"

    PLACE_MAPPING = {
      kind:PLACE,
      relations: [
        {
          relation: PLACE_IS_WAS_LOCATED_IN_PLACE,
          direction: TO,
          target: {
            kind: PLACE
          }
        },
        {
          relation: PLACE_WAS_VISITED_BY_PERSON,
          direction: TO,
          target: {
            kind: PERSON
          }
        }
      ]
    }

    HOLDER_MAPPING = {
      kind: HOLDER,
      relations: [
        {
          relation: HOLDER_IS_WAS_LOCATED_IN_PLACE,
          direction: TO,
          target: {
            kind: PLACE
          }
        }
      ]
    }

    COLLECTION_MAPPING = {
      kind: COLLECTION,
      relations: [
        {
          relation: COLLECTION_IS_WAS_HELD_BY_HOLDER,
          direction: TO,
          target: HOLDER_MAPPING
        },
        {
          relation: COLLECTION_IS_WAS_LOCATED_IN_PLACE,
          direction: TO,
          target: {
            kind: PLACE
          }
        }
      ]
    }

    ARTEFACT_MAPPING = {
      kind: ARTEFACT,
      relations: [
        {
          relation: ARTEFACT_IS_WAS_LOCATED_IN_PLACE,
          direction: TO,
          target: PLACE_MAPPING
        },
        {
          relation: ARTEFACT_HAS_ARTEFACT_PART,
          direction: TO,
          target: {
            kind: ARTEFACT
          }
        },
        {
          relation: ARTEFACT_IS_RELATED_WITH_ARTEFACT,
          direction: TO,
          target: {
            kind: ARTEFACT
          }
        },
        {
          relation: ARTEFACT_ORIGINATES_FROM_PROVENANCE,
          direction: TO,
          target: {
            kind: PROVENANCE
          }
        },
        {
          relation: ARTEFACT_WAS_DOCUMENTED_BY_PERSON,
          direction: TO,
          target: {
            kind: PERSON
          }
        },
        {
          relation: COLLECTION_HOLDS_HELD_ARTEFACT,
          direction: FROM,
          target: COLLECTION_MAPPING
        },
        {
          relation: HOLDER_DOCUMENTED_ARTEFACT,
          direction: FROM,
          target: {
            kind: HOLDER
          }
        }
      ]
    }

    MEDIUM_MAPPING = {
      kind: MEDIUM,
      relations: [
        { 
          relation: ARTEFACT_IS_DEPICTED_BY_MEDIUM,
          direction: FROM,
          target: ARTEFACT_MAPPING
        },
        {
          relation: MEDIUM_DEPICTS_PERSON,
          direction: TO,
          target: {
            kind: PERSON
          }
        },
        {
          relation: MEDIUM_WAS_CREATED_AT_PLACE,
          direction: TO,
          target: {
            kind: PLACE
          }
        },
        {
          relation: MEDIUM_WAS_CREATED_BY_HOLDER,
          direction: TO,
          target: {
            kind: HOLDER
          }
        },
        {
          relation: MEDIUM_WAS_CREATED_BY_PERSON,
          direction: TO,
          target: {
            kind: PERSON
          }
        },
        {
          relation: MEDIUM_WAS_CREATED_FROM_COLLECTION,
          direction: TO,
          target: {
            kind: COLLECTION
          }
        }
      ]
    } 


    desc 'Harvest and transform Classicmayan data'
    task harvest_and_extract_classicmayan_data: :environment do
      timestamp = Time.now.utc.strftime("%Y%m%d%H%M%S")
      classicmayan_relationships_harvest_path = "tmp/classicmayan_relationships#{timestamp}.xml"
      classicmayan_entities_harvest_path = "tmp/classicmayan_entities#{timestamp}.xml"

      File.open(classicmayan_entities_harvest_path, "w") { |f| f.puts harvest_classicmayan_entities }
      File.open(classicmayan_relationships_harvest_path, "w") { |f| f.puts harvest_classicmayan_relationships }

      @entities_doc = File.open("tmp/classicmayan_entities.xml") { |f| Nokogiri::XML(f) }
      @entities_doc.remove_namespaces!

      @relationships_doc = File.open("tmp/classicmayan_relationships.xml") { |f| Nokogiri::XML(f) }
      @relationships_doc.remove_namespaces!

      extract_classicmayan_records

      File.delete(classicmayan_relationships_harvest_path)
      File.delete(classicmayan_entities_harvest_path)
    end

    desc 'Harvest Classicmayan relationships'
    task harvest_classicmayan_relationships: :environment do
      puts harvest_classicmayan_relationships
    end

    def harvest_classicmayan_relationships
      builder = Nokogiri::XML::Builder.new do |xml|
        xml['kor'].relationships({"xmlns:kor" => "https://coneda.net/XMLSchema/1.1/"}) do |r|
          url = RELATIONSHIPS_BASE_URL + "?" + "verb=" + LIST_RECORDS_VERB + "&" + "metadataPrefix=" + METADATA_PREFIX
          loop do
            response = get_response(parse_url(url))
            relationships_doc = Nokogiri::XML(response)
            relationships_doc.xpath("//kor:relationship", "kor" => KOR_NAMESPACE).each do |relationship| 
              r.__send__ :insert, relationship
            end
            resumption_token = relationships_doc.xpath("//xmlns:resumptionToken").text
            break if resumption_token.blank?
            url = RELATIONSHIPS_BASE_URL + "?" + "verb=" + LIST_RECORDS_VERB + "&" + "metadataPrefix=" + METADATA_PREFIX + "&" +"resumptionToken=" + resumption_token
          end
        end
      end

      builder.to_xml
    end

    desc 'Harvest Classicmayan entities'
    task harvest_classicmayan_entities: :environment do
      puts harvest_classicmayan_entities
    end

    def harvest_classicmayan_entities
      builder = Nokogiri::XML::Builder.new do |xml|
        xml['kor'].entities({"xmlns:kor" => "https://coneda.net/XMLSchema/1.1/"}) do |e|
          url = ENTITIES_BASE_URL + "?" + "verb=" + LIST_RECORDS_VERB + "&" + "metadataPrefix=" + METADATA_PREFIX
          loop do
            response = get_response(parse_url(url))
            entities_doc = Nokogiri::XML(response)
            entities_doc.xpath("//kor:entity", "kor" => KOR_NAMESPACE).each do |entity| 
              e.__send__ :insert, entity
            end
            resumption_token = entities_doc.xpath("//xmlns:resumptionToken").text
            break if resumption_token.blank?
            url = ENTITIES_BASE_URL + "?" + "verb=" + LIST_RECORDS_VERB + "&" + "metadataPrefix=" + METADATA_PREFIX + "&" +"resumptionToken=" + resumption_token
          end
        end
      end
      builder.to_xml
    end

    desc 'Extract Classicmayan records'
    task :extract_classicmayan_records, [:entities_doc_path, :relationships_doc_path] => :environment do |task, args|
      @entities_doc = File.open(args[:entities_doc_path]) { |f| Nokogiri::XML(f) }
      @entities_doc.remove_namespaces!

      @relationships_doc = File.open(args[:relationships_doc_path]) { |f| Nokogiri::XML(f) }
      @relationships_doc.remove_namespaces!

      extract_classicmayan_records
    end

    def extract_classicmayan_records
      puts "<classicmayan>"
      puts "<entities>"
      write_entities(MEDIUM_MAPPING)
      puts "</entities>"
      puts "</classicmayan>"
    end

    def write_entities(kind_mapping)
      entities = @entities_doc.xpath("//entity[type[@id='#{kind_mapping[:kind][:uid]}']]")
      entities.each do |entity|
        write_entity(kind_mapping, entity)
      end
    end

    def write_entity(kind_mapping, entity)
      puts "<#{tag_name(kind_mapping[:kind][:name])}>"
      puts entity.to_xml
      entity_id = entity.xpath("./id").text
      if relations_maping = kind_mapping[:relations]
        puts "<relationships>"
        write_relationships(relations_maping, entity_id)
        puts "</relationships>"
      end
      puts "</#{tag_name(kind_mapping[:kind][:name])}>"
    end

    def write_relationships(relations_mapping, origin_entity_id)
      relations_mapping.each do |relation_mapping|
        relationships = @relationships_doc.xpath("//relationship[relation[@id='#{relation_mapping[:relation][:uid]}'] 
          and #{inverse_direction(relation_mapping[:direction])}='#{origin_entity_id}']")
        relationships.each do |relationship|
          write_relationship(relation_mapping, relationship)
        end
      end
    end

    def write_relationship(relation_mapping, relationship)
      puts "<#{tag_name(relation_mapping[:relation][:name])}>"
      puts relationship.to_xml
      target_entity_id = relationship.xpath("./#{relation_mapping[:direction]}").text
      target_entity = @entities_doc.at_xpath("//entity[id='#{target_entity_id}']")
      if target_entity
        puts "<#{relation_mapping[:direction]}>"
        write_entity(relation_mapping[:target], target_entity)
        puts "</#{relation_mapping[:direction]}>"
      end
      puts "</#{tag_name(relation_mapping[:relation][:name])}>"
    end

    def tag_name(name)
      name.gsub("/ ", "").gsub("\s", "-")
    end

    def inverse_direction(direction)
      direction == "from" ? "to" : "from"
    end

    def get_response(uri)
      begin
        response = Net::HTTP.get(uri)
      rescue SocketError, Net::ReadTimeout, Net::OpenTimeout
        retry
      end
    end

    def parse_url(url)
      URI.parse(url)
    # rescue URI::InvalidURIError
      # URI.parse(URI.escape(url))
    end

  end
end