class UserMetadata < ApplicationRecord
  attr_accessor :field
  attr_accessor :account
  attr_accessor :position
  attr_accessor :value

  serialize :updates, code: JSON

  validates :pid, presence: true
  validates :field, presence: true, inclusion: [
    'artist_nested.wikidata',
    'artist_wikidata',
    'artist',
    'title'
  ]
  validates :account, presence: true

  before_save :store_updates

  def self.updates_for(pid, field: nil, account: nil)
    um = find_by(pid: pid)
    updates = (um ? um.updates : [])

    if field
      updates.select! do |c|
        c['field'] == field ||
        c['field'].match?(/^#{field}(\.|$)/)
      end
    end

    if account
      updates.select!{|c| c['account_id'] == account.id}
    end

    updates
  end

  # Retrieves field updates from the database and applies them to given list
  # of values for that field
  def self.apply_updates_to(record, pid, field, account: nil)
    result = Array(record.dup)
    updates = updates_for(pid, field: field, account: account)
    nested = field.match?(/_nested$/)

    updates.each do |update|
      if nested
        tl_field, sub_field = update['field'].split('.')
        result[update['position']] ||= {}
        result[update['position']][sub_field] = update['value']
      else
        result[update['position']] = update['value']
      end
    end

    result
  end

  def self.upsert(pid, attribs)
    um = find_by(pid: pid) || new(pid: pid)
    um.attributes = attribs
    um
  end

  def self.original_for(pid, field, position = 0)
    um = find_by(pid: pid) || new(pid: pid)
    um.original_for(field, position)
  end

  def self.to_elastic(index_name = '_all', strict_original_checking: false)
    scope = (
      index_name == '_all' ?
      all :
      where('pid LIKE ?', "#{index_name}-%")
    )

    indexed = 0

    scope.each do |um|
      success = um.to_elastic(
        strict_original_checking: strict_original_checking
      )

      indexed += 1 if success
    end

    {count: scope.count, indexed: indexed}
  end

  def original_for(field, position = 0)
    updates.each do |u|
      if u['field'] == field && u['position'] == position
        return u['original']
      end
    end

    si = Pandora::SuperImage.from(pid)
    nested = field.match?(/\./)
    if nested
      tl_field, sub_field = field.split('.')
      value = si.display_field(tl_field) || []
      value = value[position] || {}
      value[sub_field]
    else
      value = si.display_field(field) || []
      value[position]
    end
  end

  def updates
    self[:updates] ||= []
  end

  def store_updates
    return unless field

    record = {
      'field' => field,
      'position' => position || 0,
      'value' => value,
      'account_id' => account.id
    }

    if updates.empty?
      si = Pandora::SuperImage.from(pid)
      v = si.display_field(field)

      if v.is_a?(Array)
        v = v[position || 0]
      end

      record['original'] = v
    end

    updates << record
  end

  def update_attribs_for(existing, strict_original_checking: false)
    attribs = {}

    updates.each do |u|
      f, sf = u['field'].split('.')

      orig = u['original']
      pos = u['position']

      if strict_original_checking && orig
        ev = sf ? existing[u['position']][sf] : existing[f]
        ev = ev[pos] if ev.is_a?(Array)

        if ev != orig
          self.destroy
          return {}
        end
      end

      if sf
        value = existing[f] || [{}]
        value[u['position']][sf] = u['value']
        attribs[f] = value
      else
        value = u['value']
        value = [value] if existing[f].is_a?(Array)
        attribs[f] = value
      end
    end

    attribs
  end

  def to_elastic(strict_original_checking: false)
    existing = Pandora::SuperImage.from(pid).elastic_record['_source']
    attribs = update_attribs_for(
      existing,
      strict_original_checking: strict_original_checking
    )

    source = pid.split('-')[0]
    self.class.elastic.update(source, pid, attribs)
    self.class.elastic.require_ok!(pass: [200..299, 404])

    unless Rails.env.production?
      self.class.elastic.refresh
    end
  end

  def self.elastic
    @elastic ||= Pandora::Elastic.new
  end
end
