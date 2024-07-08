require 'net/http'
require 'uri'
require 'json'

namespace :harvest do
  namespace :paris_musees do
    URL = "http://apicollections.parismusees.paris.fr/graphql"
    CONTENT_TYPE = "application/json"
    AUTHENTICATION_TOKEN = "secret"

    QUERY_LIMIT = 110
    START_OFFSET = 0

    # Lists all artworks with free image
    QUERY = "{
      nodeQuery(
        filter: {
          conditions:[
            {field: \"field_visuels_principals.entity.field_image_libre\", value: \"1\"}
            {field: \"type\", value: \"oeuvre\"}
          ]
        }
        sort: [
          {field: \"created\", direction: ASC}
        ]
        limit: #{QUERY_LIMIT.to_s}
        offset: #{START_OFFSET.to_s}
      )
      {
        count
        entities {
          ... on NodeOeuvre {
            entityId
            title
            absolutePath
            fieldUrlAlias
            fieldTitreDeMediation
            fieldSousTitreDeMediation
            fieldOeuvreAuteurs {
              entity {
                fieldAuteurAuteur {
                  entity {
                    name
                    fieldPipDateNaissance {
                      startYear
                    }
                    fieldPipLieuNaissance
                    fieldPipDateDeces {
                      startYear
                    }
                     fieldLieuDeces
                  }
                }
                fieldAuteurFonction {
                  entity {
                    name
                  }
                }

              }
            }
            fieldVisuelsPrincipals {
              entity {
                entityId
                entityLabel
                entityType
                name
                vignette
                publicUrl
                fieldCopyright
                fieldImageDroits
                fieldImageLegendeCplementaire
                fieldImageLibre
                fieldLegende
              }
            }
            fieldDateProduction {
              startPrecision
              startYear
              startMonth
              startDay
              sort
              endPrecision
              endYear
              endMonth
              endDay
              century
            }
            fieldOeuvreSiecle {
               entity {
                name
              }
            }
            fieldOeuvreTypesObjet {
              entity {
                name
              }
            }
            fieldDenominations {
              entity {
                name
              }
            }
            fieldMateriauxTechnique{
              entity {
                name
              }
            }
            fieldOeuvreDimensions {
              entity {
                fieldDimensionPartie {
                  entity {
                    name
                  }
                }
                fieldDimensionType {
                  entity {
                    name
                  }
                }
                fieldDimensionValeur
                fieldDimensionUnite {
                 entity {
                    name
                  }
                }
              }
            }
            fieldOeuvreInscriptions{
              entity {
                fieldInscriptionType {
                  entity {
                    name
                  }
                }
                fieldInscriptionMarque {
                  value
                }
                fieldInscriptionEcriture {
                  entity {
                    name
                  }
                }
              }
            }
            fieldOeuvreDescriptionIcono {
              value
            }
            fieldCommentaireHistorique {
              value

            }
            fieldOeuvreThemeRepresente   {
              entity {
                name
              }
            }
            fieldLieuxConcernes {
              entity {
                name
              }
            }
            fieldModaliteAcquisition {
              entity {
                name
              }
            }
            fieldDonateurs {
              entity {
                name
              }
            }
            fieldDateAcquisition {
              startPrecision
              startYear
              startMonth
              startDay
              sort
              endPrecision
              endYear
              endMonth
              endDay
              century
            }
            fieldOeuvreNumInventaire
            fieldOeuvreStyleMouvement {
              entity {
                name
              }
            }
            fieldMusee {
              entity {
                entityId
                name
                fieldMuseeTitreCourt
                fieldMuseeLogo {
                  url
                }
                fieldAdresse {
                  countryCode
                  locality
                  postalCode
                  addressLine1
                  addressLine2
                }
                fieldGeolocation {
                  lat
                  lng
                  latSin
                  latCos
                  lngRad
                  data
                }
              }
            }
            fieldOeuvreExpose {
              entity {
                name
              }
            }
            fieldReferenceExport {
              value
            }
            fieldOeuvreEpoquePeriode {
              entity {
                name
              }
            }
            fieldOeuvreLieuxProductions {
              entity {
                name
              }
            }
            fieldOeuvreLieuxDecouvertes {
              entity {
                name
              }
            }
            fieldOeuvreDateDecouverte {
              startPrecision
              startYear
              startMonth
              startDay
              sort
              endPrecision
              endYear
              endMonth
              endDay
              century
            }
            fieldOeuvreFaitPartieDe {
              targetId
            }
            fieldDescription {
              value
            }
            fieldOeuvresEnRapport {
              targetId
            }
            fieldOeuvreFonction {
              entity {
                name
              }
            }
            fieldPersonnesConcernees {
              entity {
                name
                fieldPipDateNaissance {
                  startYear
                }
                fieldPipLieuNaissance
                fieldPipDateDeces {
                  startYear
                }
                fieldLieuDeces
                fieldPipEmployePour
                fieldPipNomEquivalent
              }
            }
            fieldDocumentations {
              entity {
                title
                fieldRessAdresseEditoriale {
                  value
                }
                fieldRessAnnee
                fieldRessGenreDocument
                fieldRessNumero
                fieldRessNumeroFascicule
                fieldRessPagination
                fieldRessPeriodicite
                fieldRessTomaison
                fieldRessTome
                fieldRessVolume
                fieldRessAuteurs {
                  entity {
                    fieldAuteurRessPersoPhysique {
                      entity {
                        name
                        fieldPipDateNaissance {
                          startYear
                        }
                        fieldPipLieuNaissance
                        fieldPipDateDeces {
                          startYear
                        }
                        fieldLieuDeces
                        fieldPipEmployePour
                        fieldPipNomEquivalent
                      }
                    }
                    fieldAuteurRessAuteurCollect {
                      entity {
                        name
                        fieldPipDateNaissance {
                          startYear
                        }
                        fieldPipLieuNaissance
                        fieldPipDateDeces {
                          startYear
                        }
                        fieldLieuDeces
                        fieldPipEmployePour
                        fieldPipNomEquivalent
                      }
                    }
                    fieldAuteurRessFctAuteur {
                      entity {
                        descriptionOfTaxonomyTermRole {
                          value
                        }
                      }
                    }
                    fieldAuteurRessRole {
                      entity {
                        descriptionOfTaxonomyTermRole {
                          value
                        }
                      }
                    }
                  }
                }
                fieldRessAutresTitre {
                  entity {
                    title
                    fieldTitreDeFormeType
                  }
                }
                fieldRessEditeurImprimeur {
                  entity {
                    name
                    fieldPipDateNaissance {
                      startYear
                    }
                    fieldPipLieuNaissance
                    fieldPipDateDeces {
                      startYear
                    }
                    fieldLieuDeces
                    fieldPipEmployePour
                    fieldPipNomEquivalent
                  }
                }
                fieldRessCollections {
                  entity {
                    title
                    fieldCollectionSousTitre
                  }
                }
              }
            }
            fieldArchivesEnRapport {
              entity {
                title
                fieldArchiveInventoriee
                fieldArchiveNiveauDescription
                fieldArchiveNombreDocument

                fieldArchiveAuteursDocument {
                  entity {
                    name
                    fieldPipDateNaissance {
                      startYear
                    }
                    fieldPipLieuNaissance
                    fieldPipDateDeces {
                      startYear
                    }
                    fieldLieuDeces
                    fieldPipEmployePour
                    fieldPipNomEquivalent
                  }
                }
                fieldArchiveProducteurs {
                  entity {
                    name
                    fieldPipDateNaissance {
                      startYear
                    }
                    fieldPipLieuNaissance
                    fieldPipDateDeces {
                      startYear
                    }
                    fieldLieuDeces
                    fieldPipEmployePour
                    fieldPipNomEquivalent
                  }
                }

                fieldArchiveDatePrecise {
                  value
                  date
                }
                fieldArchiveDestinataires {
                  entity {
                    name
                    fieldPipDateNaissance {
                      startYear
                    }
                    fieldPipLieuNaissance
                    fieldPipDateDeces {
                      startYear
                    }
                    fieldLieuDeces
                    fieldPipEmployePour
                    fieldPipNomEquivalent
                  }
                }
                fieldArchivePeriodes {
                  entity {
                    descriptionOfTaxonomyTermPeriode {
                      value
                    }
                  }
                }
                fieldArchivePeriodeConcernee {
                  startPrecision
                  startYear
                  startMonth
                  startDay
                  sort
                  endPrecision
                  endYear
                  endMonth
                  endDay
                  century
                }
              }
            }
          }
        }
      }
    }"

    desc "harvest paris musees free image data"
    task :harvest_paris_musees => :environment do
      puts "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
      puts "<pm-entities>"
      uri = URI.parse(URL)

      response = request_data(uri, 0 + START_OFFSET)
      json_response = JSON.parse(response.body)

      count_global = json_response["data"]["nodeQuery"]["count"]
      count = count_global.to_i - START_OFFSET * QUERY_LIMIT

      puts_entities(json_response)

      max_i = (count.to_f / QUERY_LIMIT.to_f).ceil

      (1...max_i).each do |i|
        begin
          response = request_data(uri, START_OFFSET + (i * QUERY_LIMIT))
          json_response = JSON.parse(response.body)
        rescue JSON::ParserError # for 502 Bad Gateway response
          sleep 60
          retry
        end

        puts_entities(json_response)
      end

      puts "</pm-entities>"
    end

    def request_data(uri, offset)
      request = Net::HTTP::Post.new(uri)
      request.content_type = CONTENT_TYPE
      request["Auth-Token"] = AUTHENTICATION_TOKEN
      request.body = JSON.dump(
        {
          "query" => offset_query(offset)
        }
      )

      get_response(uri, request)
    end

    def get_response(uri, request)
      begin
        response = Net::HTTP.start(uri.hostname, uri.port) do |http|
          http.request(request)
        end
      rescue SocketError, Net::ReadTimeout, Net::OpenTimeout
        retry
      end
    end

    def offset_query(offset)
      query = QUERY.gsub(/offset: [0-9]*/, "offset: #{offset}")
    end

    def puts_entities(json_response)
      entities = json_response["data"]["nodeQuery"]["entities"]
      entities.each do |entity|
        puts entity.to_xml(:root => "pm-entity").gsub("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n", "") if entity
      end
    end
  end
end
