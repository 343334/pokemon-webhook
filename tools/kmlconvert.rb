require "rubygems"
require "crack"
require "json"
require "pp"

myXML  = Crack::XML.parse(File.read("test3.kml"))


placemarks = myXML['kml']['Document']['Placemark']

placemarks = [placemarks] if placemarks.is_a?(Hash)


output = {'fences' => {}}
fences = output['fences'] 

placemarks.each do |polygon|
  
  name = polygon['name'].gsub(/[^0-9a-zA-Z]/, '').downcase
  coords = polygon['Polygon']['outerBoundaryIs']['LinearRing']['coordinates'].split
  
  coordinates = []
  coords.each do |coord|
    items = coord.split(',')
    coordinates << [items[1],items[0]]
  end

  fences[name] = { type: 'polygon', coordinates: coordinates }
end
puts output.to_json
