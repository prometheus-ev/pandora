class Pandora::ImageVectors::DominantColors < Pandora::ImageVectors::Base
  def run(pid)
    si = Pandora::SuperImage.new(pid)
    dominant_colors(si.original_filename)
  end

  def dominant_colors(file)
    out = Pandora.run('convert',
                      file,
                      '+dither',
                      '-colors', '5',
                      '-define', 'histogram:unique-colors=true',
                      '-colorspace', 'hsv',
                      '-format', '%c',
                      'histogram:info:')

    results = []

    out.split("\n").each do |line|
      count = line.scan(/\s+(\d+)/)[0][0].to_i
      hsv = line.scan(/hsv\(([\d\.]+),([\d\.%]+),([\d\.%]+)\)/).first
      unless hsv.blank?
        color = hsv.map(&:to_f)
        results << {'count' => count, 'hsv' => color}
      end
    end
    results.sort!{|x, y| y['count'] - x['count']}

    @count += 1

    # legacy method, scale to 1x1 returning the actual average color, doesn't
    # really give good results though
    # out = `magick convert #{file} -resize 1x1 txt:- 2> /dev/null`
    # color = out.scan(/#[0-9A-F]{6}/).first
    # record[:average] = {
    #   hex: color
    # }

    results
  end
end
