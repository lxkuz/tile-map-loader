require 'yaml'
require 'net/http'
require 'fileutils'

class TileMapLoader
  def start config_path
    @config = YAML.load_file config_path
    @folder_path = @config["folder"] || "./map"
    @map_path = @config["map"]
    lat, lng = @config["lat"], @config["lng"]


    @borders = {1 => [[0, 0], [1, 1]]} #TODO temp

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

  # TODO add support of original geocoords
  # def long2tile(lon,zoom) 
  #   (( lon + 180 ) / 360 * Math.pow( 2, zoom )).floor
  # end

  # def lat2tile(lat,zoom)
  #   ((1 - Math.log(Math.tan(lat * Math::PI/180) +
  #    1 / Math.cos(lat*Math::PI/180)) / Math::PI) / 2 * Math.pow(2,zoom)).floor
  # end
end