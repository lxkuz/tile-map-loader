require 'yaml'
require 'net/http'
require 'fileutils'

class TileMapLoader
  def start config_path
    @config = YAML.load_file config_path
    @folder_path = @config["folder"] || "./map"
    @map_path = @config["map"]
    @borders = {1 => [[0, 0], [1, 1]]}

    @borders.each do |z, xy|
      startPoint = xy.first
      endPoint = xy.last
      xs = startPoint[0]..endPoint[0]
      ys = startPoint[1]..endPoint[1]
      xs.each do |x|
        ys.each do |y|
          load_tile x, y, z
        end
      end
    end
  end

  private

  def save_tile content, x, y, z
    puts "saving: #{z}/#{x}/#{y}.png"
    file_name = "#{y}.png"
    folder_name = "#{@folder_path}/#{z}/#{x}"
    FileUtils.mkdir_p folder_name
    File.write("#{folder_name}/#{file_name}", content)
  end

  def load_tile x, y, z
    puts "loading: #{z}/#{x}/#{y}.png"
    url = @map_path.sub("{x}", x.to_s).sub("{y}", y.to_s).sub("{z}", z.to_s)
    uri = URI(url)
    res = Net::HTTP.get_response(uri)
    save_tile res.body, x, y, z
  end
end


TileMapLoader.new.start(ARGV[0] || "config.yml")
