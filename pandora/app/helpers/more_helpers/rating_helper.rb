module MoreHelpers

  module RatingHelper

    def stars(rating, options = {}, html_options = {})
      out, counter = '', { :i => 0 }

      if rating
        rating = rating.to_f
        full  = rating.round_hd
        half  = rating % -1 > -0.5 ? 0 : 1
        empty = MAX_RATING - full - half

        full.times  { out << star(:full,  options, html_options, counter) }
        half.times  { out << star(:half,  options, html_options, counter) }
        empty.times { out << star(:empty, options, html_options, counter) }
      else
        MAX_RATING.times { out << star(:inactive, options, html_options, counter) }
      end

      out.html_safe
    end

    def star(which = :full, options = {}, html_options = {}, counter = { :i => 0 })
      counter = counter[:i] += 1

      if options.blank?
        title = html_options[:title]
        image_tag(star_path(which, !title.nil?), :title => title)
      else
        img = image_tag(
          star_path(which),
          :_hover_src     => image_path(star_path(:full)),
          :_alt_hover_src => image_path(star_path(:inactive))
        )

        title = case title = html_options[:title]
          when /%d/
            title % counter
          when /%s/
            title % rating_to_human(counter, :image)
          when String
            title
          else
            counter
        end

        if url = options[:url]
          url  = url.merge(:rating => counter)
          href = html_options[:href] || url_for(url)

          # REMOTE: use rails ujs instead
          # link_to_remote(img, options.merge(:url => url), html_options.merge(:title => title, :href => href))
          link_to(img, options.merge(url: url, remote: true), html_options.merge(:title => title, :href => href, :class => 'on-rating-done'))
        else
          link_to(img, options.merge(:rating => counter), html_options.merge(:title => title))
        end
      end
    end

    def star_path(which, big = true)
      "stars/star#{'_big' if big}_#{which}.gif"
    end

    def rating_title_for(image, rating = image.rating, style = false)
      rating, rating_to_s = rating if rating.is_a?(Array)

      if rating
        style = 'strong' if style == true

        (
          "#{style ? "<#{style}>%s</#{style[/\S+/]}>" : '%s'} – %s" % [
            "",
            "#{image.rating} in #{image.votes}"
          ]
        ).html_safe
      else
        'No ratings yet'.t
      end
    end

    RATING_DESCRIPTIONS = {
      :image => ['unusable', 'poor', 'usable', 'good', 'very good']
    }

    def rating_to_human(rating, type = nil)
      rating = rating.to_f
      if ratings = RATING_DESCRIPTIONS[type]
        ratings[(MIN_RATING..MAX_RATING).quantile(rating, ratings.size) - 1].t
      else
        rating.to_s
      end
    end

    def link_to_rating(image, options = {}, html_options = {})
      si = Pandora::SuperImage.from(image)
      link_to(stars(image.rating), options.merge(:controller => 'images', :action => 'show', :id => si.pid, :anchor => 'rating'), html_options.reverse_merge(:title => rating_title_for(image)))
    end

    def rewarded_stars(ratings, *args)
      return star(:empty, *args) if ratings.zero?

      stars = star(:full, *args) * (ratings / 100.0).round_hd
      ratings % -100 > -50 ? stars.html_safe : (stars << star(:half, *args)).html_safe
    end

  end

end
