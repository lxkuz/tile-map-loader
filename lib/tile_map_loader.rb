require 'yaml'
require 'net/http'
require 'fileutils'

class TileMapLoader
  def start config_path
    @config = YAML.load_file config_path
    @folder_path = @config["folder"] || "./map"
    @map_path = @config["map"]

    @borders = compile_borders(
      @config["min_zoom"], @config["max_zoom"],
      @config["border"][0],  @config["border"][1]
    )

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

  def compile_borders(min_zoom, max_zoom, left_top_point, right_bottom_point)
    zoom = max_zoom
    borders = {}
    while zoom >= min_zoom
      borders[zoom] = [
        deg2num(left_top_point, zoom),
        deg2num(right_bottom_point, zoom)
      ]
      zoom -= 1
    end
    borders
  end

  def deg2num(point, zoom)
    lat_deg, lon_deg = point
    lat_rad = lat_deg * Math::PI / 180
    n = 2.0 ** zoom
    xtile = ((lon_deg + 180.0) / 360.0 * n).to_i
    ytile = ((1.0 - Math.log(Math.tan(lat_rad) + (1 / Math.cos(lat_rad))) / Math::PI) / 2.0 * n).to_i
    [xtile, ytile]
  end

  def load_tile(x, y, z)
    puts "loading: #{z}/#{x}/#{y}.png"
    url = @map_path.sub("{x}", x.to_s).sub("{y}", y.to_s).sub("{z}", z.to_s)
    uri = URI(url)
    res = Net::HTTP.get_response(uri)
    save_tile res.body, x, y, z
  end

  def save_tile(content, x, y, z)
    puts "saving: #{z}/#{x}/#{y}.png"
    file_name = "#{y}.png"
    folder_name = "#{@folder_path}/#{z}/#{x}"
    FileUtils.mkdir_p folder_name
    File.write("#{folder_name}/#{file_name}", content)
  end
end