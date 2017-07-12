require 'geokit'

class Geofences

  def initialize()
    loadFences
  end

  def loadFences(reload=false)
    @@fences ||= {}
    if reload or @@fences.empty?

      begin
        fences = { 'fences' => {} }
        Dir.glob('config/fences/*.json').each do |config_file|
          begin
            puts "[Geofences] Loading JSON #{config_file}"
            file = File.open(config_file, "r")
            tmpfences = JSON.parse(file.read)['fences']
            file.close
            fences['fences'].merge!(tmpfences)
          rescue
            puts "[Geofences] Error loading JSON #{config_file}"
            next
          end
        end
      rescue => e
        puts "[Geofences] Error loading JSON"
        puts e.inspect
        puts e.backtrace
      end

      begin
        puts '[Geofences] Building Fences'
        fences['fences'].each do |name,fence|
          items = []
          if fence['type'] == 'polygon'
            fence['coordinates'].each do |coord|
              items << Geokit::LatLng.new(coord[0],coord[1])
            end
            puts "[Geofences] - Built fence #{name}"
            @@fences[name] = Geokit::Polygon.new(items)
          else
            sw = Geokit::LatLng.new(fence['sw'][0],fence['sw'][1])
            ne = Geokit::LatLng.new(fence['ne'][0],fence['ne'][1])
            puts "[Geofences] - Built fence #{name}"
            @@fences[name] =  Geokit::Bounds.new(sw,ne)
          end 
        end
      rescue => error
        puts "[Geofences] ERROR: Could not build fences"
        puts error.backtrace
        puts error.inspect
      end
    end
  end

  def fence fencename
    if @@fences.has_key? fencename
      return @@fences[fencename]
    else
      return false
    end
  end

end
