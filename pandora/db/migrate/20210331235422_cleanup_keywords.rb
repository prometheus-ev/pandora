class CleanupKeywords < ActiveRecord::Migration[5.2]
  def up
    # eliminate duplicate keywords
    Keyword.group('trim(title)').count.each do |title, count|
      next if count < 2

      keywords = Keyword.where('trim(title) LIKE ?', title).to_a
      keep = keywords.shift

      ids = keywords.map{|k| k.id}.join(',')
      ['collections_keywords', 'keywords_sources', 'keywords_uploads'].each do |t|
        execute "UPDATE #{t} SET keyword_id = #{keep.id} WHERE keyword_id IN (#{ids})"
      end
      execute "DELETE FROM keywords WHERE id IN (#{ids})"
    end

    # eliminate duplicate keyword assignments
    result = execute [
      "SELECT keyword_id, collection_id, count(*) AS c",
      "FROM collections_keywords",
      "GROUP BY keyword_id, collection_id",
      "HAVING c > 1",
    ].join(' ')
    result.each do |row|
      keyword_id, id, count = row
      execute "
        DELETE FROM collections_keywords
        WHERE keyword_id = #{keyword_id} AND collection_id = #{id}
        LIMIT #{count - 1}
      "
    end
    result = execute [
      "SELECT keyword_id, source_id, count(*) AS c",
      "FROM keywords_sources",
      "GROUP BY keyword_id, source_id",
      "HAVING c > 1",
    ].join(' ')
    result.each do |row|
      keyword_id, id, count = row
      execute "
        DELETE FROM keywords_sources
        WHERE keyword_id = #{keyword_id} AND source_id = #{id}
        LIMIT #{count - 1}
      "
    end
    result = execute [
      "SELECT keyword_id, upload_id, count(*) AS c",
      "FROM keywords_uploads",
      "GROUP BY keyword_id, upload_id",
      "HAVING c > 1",
    ].join(' ')
    result.each do |row|
      keyword_id, id, count = row
      execute "
        DELETE FROM keywords_uploads
        WHERE keyword_id = #{keyword_id} AND upload_id = #{id}
        LIMIT #{count - 1}
      "
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
