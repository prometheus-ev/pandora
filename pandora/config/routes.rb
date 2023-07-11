Rails.application.routes.draw do
  root to: 'redirect#locale_redirect'

  scope path: '(pandora)/oauth', controller: 'oauth' do
    post 'request_token', action: 'request_token'
    post 'authorize', action: 'authorize'
    post 'access_token', action: 'access_token'
    get 'revoke', action: 'revoke'
  end

  post '/payment/paypal_ipn', to: 'payment#paypal_ipn'

  # legacy redirect
  get '/image/show/:pid', to: redirect('/image/%{pid}')

  # toggle between legacy and ng frontends
  get '/toggle-frontend', to: 'pandora#toggle_frontend'

  # API
  opts = {
    path: '(pandora)/api(/:api_version)/:format',
    constraints: {
      id: /v\d+/,
      format: /json|xml|blob/
    },
    format: false,
    defaults: {api_version: 'v1'}
  }
  scope opts do
    get 'announcement/current', to: 'announcements#current'

    controller 'pandora' do
      get 'about'
      get 'facts'
      get 'translations'
    end

    scope 'source', controller: 'sources', constraints: {id: /[a-z0-9_\-]+/} do
      get 'list', action: 'index'
      get 'show', action: 'show'
    end

    scope 'search', controller: 'searches' do
      get 'advanced_search', action: 'advanced', as: nil
      get 'index', action: 'index'
      get 'search', action: 'index', as: nil
      get 'hits', action: 'hits'
    end

    scope 'image', controller: 'images', constraints: {id: /[a-z0-9_\-]+/} do
      get 'small(/:id)', action: 'small'
      get 'medium(/:id)', action: 'medium'
      get 'large(/:id)', action: 'large'
      get 'r:resolution(:mode)(/:id)', {
        action: 'custom',
        constraints: {resolution: /\d+/, mode: /m/}
      }
      get 'show(/:id)', action: 'show'
      get 'list', action: 'list'
      get 'display_fields', action: 'display_fields'
    end

    scope 'upload', controller: 'uploads', constraints: {id: /[a-z0-9_\-]+/} do
      get 'index', action: 'index'
      get 'list', action: 'index'
      post 'create', action: 'create'
      match 'edit(/:id)', action: 'show', via: ['GET']
      match 'edit(/:id)', action: 'update', via: ['PUT']
      # TODO Remove legacy compatibility HTTP POST.
      match 'destroy(/:id)', action: 'destroy', via: ['DELETE', 'POST']
      get ':id', action: 'record'
    end

    scope 'box', controller: 'boxes' do
      get 'list', action: 'index'
      post 'create', action: 'create'
      # TODO Remove legacy compatibility HTTP POST.
      match 'delete', action: 'destroy', via: ['DELETE', 'POST']
    end

    scope 'account', controller: 'accounts' do
      # TODO Remove legacy compatibility app account POST route.
      match 'show', action: 'show', via: ['GET', 'POST']
    end

    scope 'account', controller: 'terms' do
      get 'terms_of_use', action: 'show'
      post 'terms_of_use', action: 'update'
    end

    scope 'collection', controller: 'collections', constraints: {id: /\d+/} do
      post 'create', action: 'create'
      # TODO Remove legacy compatibility HTTP POST.
      match 'delete', action: 'destroy', via: ['DELETE', 'POST']
      get 'number_of_pages', action: 'number_of_pages'
      get 'own', action: 'index'
      # get 'own_all', action: 'own_all'

      get 'shared', action: 'shared'
      get 'public', action: 'public'
      get 'writable', action: 'writable'
      get 'public_owners_fullname', action: 'public_owners_fullname'
      get 'shared_owners_fullname', action: 'shared_owners_fullname'
      post 'store', action: 'store'
      post 'remove', action: 'remove'
      get 'images/:id', action: 'images'
    end

    scope 'user_metadata', controller: 'user_metadata' do
      patch ':pid/:field/(:position)', action: 'update', constraints: {field: /[a-z0-9\._]+/}
    end
  end

  # install *both* the normal route and a corresponding one with :locale prefix
  opts = {
    path: ":locale",
    constraints: {locale: Regexp.union(*ORDERED_LOCALES)}
  }
  scope opts do
    get 'pandora.js', to: 'js#pandora'

    get 'pandora.wadl', to: 'pandora#wadl', defaults: {format: 'xml'}

    controller 'payment' do
      get 'transaction', action: 'transaction'
      post 'paypal_ipn', action: 'paypal_ipn'
      post 'payment/paypal_ipn', action: 'paypal_ipn'
    end

    controller 'pandora' do
      get 'start', action: 'start'
      get 'about', action: 'about'
      get 'back', action: 'back'
      get 'sitemap', action: 'sitemap'
      get 'feedback', action: 'feedback_form'
      post 'feedback', action: 'feedback'
      get 'remote_ip', action: 'remote_ip', defaults: {format: 'plain'}
      get 'api', action: 'api'

      # TODO: is this still needed?
      get 'conference_sign_up', to: redirect('conference_signup')

      get 'conference_signup', action: 'conference_signup_form'
      post 'conference_signup', action: 'conference_signup'
      get 'conference_signup_confirmation', action: 'conference_signup_confirmation'

      scope constraints: {format: 'js'} do
        post 'update', action: 'toggle_news', constraints: {key: 'news_collapsed'}
      end

      if Rails.env.test?
        get :raise_exception
      end
    end

    get 'u(/:token)', to: 'short_urls#redirect'

    resources :searches, only: ['index'] do
      collection do
        get 'advanced'
      end
    end

    scope 'institutional_databases' do
      root to: 'institutional_uploads#index', as: 'institutional_databases'

      scope ':id' do
        resources :uploads, {
          controller: 'institutional_uploads', 
          as: 'institutional_uploads', 
          only: ['index', 'new', 'create']
        }
      end
    end

    resources :uploads do
      collection do
        get 'all'
        get 'approved'
        get 'unapproved'
        get 'edit_selected'
        post 'update_selected'
        # get 'suggest_keywords'
      end
      member do
        get 'record_image_url'
        get 'disconnect'
        get 'associated'
        # post 'suggest_keywords'
      end
    end

    scope ':type/comments', controller: 'comments' do
      root action: 'create', via: ['POST'], as: 'comments'
      match ':id', action: 'update', via: ['PATCH', 'PUT'], as: 'comment'
      match ':id', action: 'destroy', via: ['DELETE']
    end

    scope 'image', controller: 'images', constraints: {id: /[a-z0-9_\-]+/} do
      get ':id/edit', action: 'edit'
      get ':id/vote', action: 'vote'
      get 'download', action: 'download'
      match 'publish/:id', action: 'publish', via: ['GET', 'POST']

      # TODO: needed for box js code
      # match ':id', action: 'show', via: ['GET', 'POST']
      get ':id', action: 'show'

      get 'large/:id', action: 'large'
    end

    resources :sources do
      collection do
        get 'open_access'
        # match 'suggest_keywords', via: ['GET', 'POST']
      end
      member do
        get 'ratings'
        get 'open_access', action: 'open_access_login'
        # post 'suggest_keywords'
      end
    end

    resources :announcements do
      member do
        get 'publish'
        get 'withdraw'
      end
      collection do
        get 'list'
        get 'current'
        delete 'hide'
      end
    end

    opts = {
      constraints: {id: /[_a-zA-Z,%\s\-0-9\(\)\u00C0-\u00F6\u00F8-\u00FF\.]+/},
      except: ['destroy']
    }
    resources :institutions, opts do
      collection do
        get 'licensed'
        get 'mine'
        post 'renew_license'
      end
    end

    resources :licenses, only: ['destroy']

    resources 'collections' do
      collection do
        get :all
        get :sharing
        get :shared
        get :public
        match :store, via: ['POST', 'GET']
        # post :suggest_keywords
        get :number_of_pages
      end

      member do
        get :download
        post :remove

        # for box loading, because Ajax.Updater seems to always send post
        # requests
        # post :show
      end
    end

    resources :boxes, only: ['show', 'index', 'create', 'destroy'] do
      collection do
        post :reorder
      end
      member do
        post :toggle
      end
    end

    # scope 'box', controller: 'box' do
    #   post 'order', action: 'order'
    #   root action: 'create', via: 'POST'
    #   delete ':id', action: 'delete'
    # end

    scope 'administration', controller: 'administration' do
      root action: 'index', via: 'GET', as: 'administration'
    end

    controller 'sessions' do
      get 'login', action: 'new', as: 'login'
      post 'create'
      get 'logout', action: 'destroy', as: 'logout'
      get 'campus'
    end

    resource :terms, only: ['show', 'edit', 'update']

    controller 'subscriptions' do
      get 'subscribe', action: 'subscribe_form'
      post 'subscribe'
      get 'confirm_subscribe'
      get 'unsubscribe', action: 'unsubscribe_form'
      post 'unsubscribe'
      get 'confirm_unsubscribe'
    end

    controller 'signup' do
      get 'signup', action: 'signup_form', as: 'signup'
      post 'signup'
      get 'confirm_email', action: 'confirm_email_form'
      post 'change_email'
      get 'confirm_email_linkback'
      get 'license', action: 'license_form'
      post 'license'
      get 'password', action: 'password_form'
      post 'password'
      get 'payment_status'
      get 'signup_completed'
      get 'email_confirmation_sent'

      # we keep the url for now not to have to change paypal config
      get 'account/payment_status/:client_id/:payment_id', action: 'payment_status'
    end

    # prom App legacy route
    get 'account/signup', to: 'signup#signup_form'

    resources 'accounts', constraints: {id: /[^\/]+/} do
      collection do
        get 'active'
        get 'pending'
        get 'expired'
        get 'guest'

        # TODO: should go to its own controller
        get 'email'
        post 'email'

        match 'suggest_names', via: ['GET', 'POST']
      end

      member do
        patch 'disable'
      end
    end

    resource 'profile', controller: 'profile', only: ['show', 'edit', 'update'], constraints: {id: /[^\/]+/} do
      member do
        patch 'disable'
      end
    end
    get 'profile/:id/download_legacy_presentation/:presentation_id/:presentation_filename',
      to: 'profile#download_legacy_presentation',
      as: 'download_legacy_presentation'

    resources :newsletters do
      collection do
        get :archive
        get :pending
      end
      member do
        get :recipients
        get :webview
        post :deliver
      end
    end

    # compatibility for existing newsletters
    get 'emails/newsletters/:id', to: redirect('/newsletters/%{id}/webview')

    resources :stats, only: ['new', 'create'] do
      collection do
        get 'facts', action: 'facts_form'
        post 'facts'
      end
    end

    resources 'oauth_clients', as: 'client_applications'

    resources 'keywords', except: ['show'] do
      collection do
        get 'similar'
        get 'untranslated'
        match 'suggest', via: ['GET', 'POST']
      end
      member do
        patch :merge
      end
    end

    resources 'wikidata', only: ['index']

    scope path: 'help', controller: 'help' do
      get '(:section)', action: 'show', as: 'help'
    end

    get 'powerpoint/collection/:collection_id', controller: 'power_point', action: 'collection'

    root to: 'pandora#start', as: 'locale_root'
  end

  # mount rack-images on a sub-uri so that we don't have to manage it in
  # development and in testing
  unless Rails.env.production?
    require 'rack_images'
    mount RackImages::Server, at: '/rack-images'
  end

  get '*path', {
    to: 'redirect#locale_redirect',
    constraints: lambda{ |r| !r.path.match(/^\/(en|de|pandora|oauth)/) }
  }
end
