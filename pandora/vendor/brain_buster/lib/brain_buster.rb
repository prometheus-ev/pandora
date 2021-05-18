# Simple model to hold sets of questions and answers.
class BrainBuster < ApplicationRecord
  Ones = %w[ zero one two three four five six seven eight nine ]
  Teen = %w[ ten eleven twelve thirteen fourteen fifteen
             sixteen seventeen eighteen nineteen ]
  Tens = %w[ zero ten twenty thirty forty fifty
             sixty seventy eighty ninety ]
  Mega = %w[ hundred thousand million billion ]

  class << self

    def to_english(str)
      name, places = [], str.split(//).map { |s| s.to_i }.reverse

      ((places.length + 2) / 3).times { |i|
        strings, a, b, c = [], *places[i * 3, 3]

        if b == 1
          strings << Teen[a]
        elsif b && b > 0
          strings << (a == 0 ? Tens[b] : "#{Tens[b]}-#{Ones[a]}")
        elsif a > 0
          strings << Ones[a]
        end

        strings << Mega[0] << Ones[c] if c && c > 0

        name << Mega[i] if i > 0 && !strings.empty?
        name.concat(strings)
      }

      name.empty? ? Ones[0] : name.reverse.join(' ')
    end

    def find_random_or_previous(id = nil, lang = 'en')
      find(id || random_id(lang))
    end

    private

    def random_id(lang = 'en')
      ids = ids_by_lang[lang] and ids.at(Kernel.rand(ids.size))
    end

    def ids_by_lang
      # REWRITE: inject does the work here which is removed .. simplifying:
      # @ids_by_lang ||= inject(Hash.nest { [] }) { |h, r| h[r.lang] << r.id; h }
      @ids_by_lang ||= {
        :en => where(lang: 'en').pluck(:id).sort,
        :de => where(lang: 'de').pluck(:id).sort
      }
    end

  end

  def attempt?(str)
    str, ans = str.strip.downcase, answer.downcase

    str == ans || ((ans.to_i != 0 || ans == '0') && str == (
      lang == 'en' ? self.class.to_english(ans) : ans.t.downcase))
  end

end
