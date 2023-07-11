class Pandora::KeywordList
  def initialize(owner)
    @owner = owner
  end

  def read
    @owner.keywords.map{|k| k.t}.join("\n")
  end

  def write(value)
    unless value.nil?
      titles = value.split(/\s*(?:\r?\n+|,)\s*/).reject{|i| i.blank?}
      @owner.keywords = titles.map do |title|
        a = (I18n.locale == :de ? :title_de : :title)
        Keyword.find_or_initialize_by(a => title)
      end
    end
  end
end
