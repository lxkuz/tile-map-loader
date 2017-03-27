require './lib/tile_map_loader.rb'
TileMapLoader.new.start(ARGV[0] || "config.yml")
