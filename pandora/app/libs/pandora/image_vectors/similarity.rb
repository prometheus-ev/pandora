class Pandora::ImageVectors::Similarity < Pandora::ImageVectors::Base
  def run(pid)
    client = HTTPClient.new
    @count += 1

    url = ENV['PM_SIMILARITY_API_URL']
    response = client.request('POST', url, {}, {pids: pid}, {})
    JSON.parse(response.body)
  end
end
