require 'yaml'
require 'net/http'
require 'fileutils'

class TileMapLoader
  def start config_path
    puts "config #{config_path}"
    @config = YAML.load_file config_path
    puts @config.inspect
    @folder_path = @config["folder"]
    @map_path = @config["map"]
    @borders = {
        # папин участок
        #     10 => [[761,345],[761,345]],ok
        #     11 => [[1522,691],[1523,691]],ok
        #     12 => [[3044,1382],[3046,1383]],ok
        #     13 => [[6089,2765],[6092,2767]],ok
        #     14 => [[12179,5530],[12185,5534]],ok
        #     15 => [[24359,11062],[24371,11068]],ok
        #     16 => [[48719,22124],[48743,22137]],ok
        #     17 =>[[97438,44248],[97486,44275]], ok
        #     18 =>[[194877,88496],[194973,88551]] ok
        }

        # # телецкое озеро
        # {
        #
        #     # 6 => [[42,19],[49,21]],  ok
        #     # 7 => [[85,39], [98,43]],  ok
        #     # 8 => [[170,78],[193,86]],  ok
        #     # 9 => [[375,165],[386,172]],  ok
        #     # 10 => [[760, 339], [763, 341]], ok
        #     # 11 => [[1520, 678], [1526, 682]], ok
        #     # 12 => [[3040, 1356], [3052, 1365]], ok
        #     # 13 => [[6080, 2713], [6104, 2731]], ok
        #     # 14 => [[12161, 5426], [12208, 5462]], ok
        #     # 15 => [[24322, 10852], [24416, 10924]], ok
        #     # 16 => [[48644, 21704], [48833, 21849]],
        #     # 17 => [[97289, 43409], [97666, 43698]],
        #     # 18 => [[194578, 86818], [195332, 87396]]
        # }



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
  #
  #
  # def latlng2xyz lat, lng, z
  #
  # end

end


TileMapLoader.new.start(ARGV[0] || "config.yml")


"{\"10\":[[760,339],[763,341]],\"11\":[[1520,678],[1526,682]],\"12\":[[3040,1356],[3052,1365]],\"13\":[[6080,2713],[6104,2731]],\"14\":[[12161,5426],[12208,5462]],\"15\":[[24322,10852],[24416,10924]],\"16\":[[48644,21704],[48833,21849]],\"17\":[[97289,43409],[97666,43698]],\"18\":[[194578,86818],[195332,87396]]}"





