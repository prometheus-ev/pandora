namespace :pandora do
  desc 'reset tables and indices'
  task reset: :environment do
    if Rails.env.development?
      Rake::Task['db:drop'].invoke
      Rake::Task['db:create'].invoke
      Rake::Task['db:schema:load'].invoke
      Rake::Task['db:migrate'].invoke
      Rake::Task['db:seed'].invoke

      cmd = "rm -rf #{ENV['PM_IMAGES_DIR']}/upload/*"
      system(cmd)

      Indexing::Index.delete('*')
      Indexing::IndexTasks.new.load(['robertin'])
      Indexing::IndexTasks.new.load(['daumier'])
    else
      puts 'A reset is only available in a development environment.'
    end
  end

  desc 'reset tables and indices'
  task reset_test: :environment do
    if Rails.env.test?
      Rake::Task['db:drop'].invoke
      Rake::Task['db:create'].invoke
      Rake::Task['db:schema:load'].invoke
      Rake::Task['db:migrate'].invoke

      Indexing::Index.delete('*')
    else
      puts 'Test reset is only available in a test environment.'
    end
  end

  desc 'reset indices'
  task reset_indices: :environment do
    if Rails.env.development? || Rails.env.test?
      Indexing::Index.delete('*')
    else
      puts 'A indices reset is only available in a development and test environment.'
    end
  end
end
