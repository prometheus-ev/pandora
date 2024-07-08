xml.application(
  :xmlns => 'http://wadl.dev.java.net/2009/02',
  'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema',
  'xmlns:html' => 'http://www.w3.org/1999/xhtml'
) do
  xml.resources :base => root_url(locale: nil) do
    xml.resource :path => 'api' do
      xml.resource :path => 'v1' do
        xml.doc 'xml:lang' => 'en', :title => 'The prometheus image archive API, v1' do
          xml.itext! 'Perform searches, retrieve images, and query collections.'
        end

        xml.param :name => 'Authorization', :style => 'header' do
          xml.doc 'xml:lang' => 'en', :title => 'Authorization header' do
            xml.itext! 'Some API calls require authorization. Supported schemes are Basic and OAuth.'
          end
        end

        o = {
          name: 'locale',
          style: 'query',
          type: 'xsd:string',
          default: DEFAULT_LANGUAGE
        }
        xml.param o do
          ORDERED_LOCALES.each{|locale| xml.option :value => locale}
        end

        @api_formats.sort_by_key(&:to_s).each do |format, controllers|
          xml.resource :path => format do
            controllers.sort_by_key(&:to_s).each do |controller, actions|
              skip, acts = actions.
                partition{|_, methods| methods[:skip_controller]}.
                map{|partition| partition.sort_by_key(&:to_s)}

              act = lambda do |action, methods|
                xml.resource :path => action do
                  methods.sort_by_key(&:to_s).each do |method, opts|
                    next if method == :skip_controller

                    id = [method, controller, action, format].compact.join('_').camelcase(:lower)

                    xml.method :name => method.to_s.upcase, :id => id do
                      xml.doc 'xml:lang' => 'en', :title => 'Description' do
                        xml.itext! opts[:doc]
                      end if opts[:doc]

                      xml.request do
                        opts[:params].sort_by_key(&:to_s).each do |param, popts|
                          _popts = popts.merge(:name => param).except(:doc, :select)
                          _popts[:type] = "xsd:#{popts[:type]}"

                          blocks = []
                          blocks << lambda{xml.doc 'xml:lang' => 'en', :title => popts[:doc]} if popts[:doc]
                          blocks << lambda{popts[:select].each{|value| xml.option :value => value}} if popts[:select]
                          block = lambda{|*args| blocks.each(&:call)} unless blocks.empty?

                          xml.param _popts, &block
                        end
                      end unless opts[:params].empty?

                      xml.response do
                        ropts = {:mediaType => opts[:type]}

                        if root = opts[:root]
                          ropts[:element] = root
                          rparams = opts[:hints]
                        end

                        xml.representation ropts do
                          rparams.each do |param, repeating|
                            popts = {:name => param, :path => "/#{root}/#{param}"}
                            popts[:repeating] = repeating unless repeating.nil?

                            xml.param popts
                          end unless rparams.blank?
                        end
                      end
                    end
                  end
                end
              end

              skip.to_h.each{|k, v| act.call(k, v)}
              unless acts.empty?
                xml.resource(:path => controller) do
                  acts.to_h.each{|k, v| act.call(k, v)}
                end
              end
            end
          end
        end
      end
    end
  end
end
