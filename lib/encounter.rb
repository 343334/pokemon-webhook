require 'geokit'
require 'json'
require_relative 'pokedex.rb'
require_relative 'geofences.rb'

class Encounter

  def initialize(message,source='unknown')
    @source = source
    @@geofences ||= Geofences.new
    @message = message
  end

  def pokemon_name
    return Pokedex.new(self.pokemon).name
  end

  def disappeartimestamp
    return @message['message']['disappear_time'].to_i
  end

  def disappear
    return Time.at(@message['message']['disappear_time'].to_i).strftime("%I:%M%p")
  end

  def iv(stat=false)
    begin
      if stat
        if stat=='percent'
          return ((( self.iv('attack') + self.iv('defense') + self.iv('stamina').to_f ) / 45) * 100).to_i
        else
          return @message['message']['individual_' + stat].to_i
        end
      else
        stats = "#{self.iv('attack')}/#{self.iv('defense')}/#{self.iv('stamina')}"
        return false if stats == '//'
        return stats
      end
    rescue
      return false
    end 
  end

  def pokemon
    return @message['message']['pokemon_id']
  end

  def lat
    return @message['message']['latitude']
  end

  def lon
    return @message['message']['longitude']
  end

  def city
    begin
      geo = self.geocode
      return self.geocode.city
    rescue
      return 'Unknown'
    end
  end

  def address
    begin
      geo = self.geocode
      return geo.street_address + ', ' + geo.city
    rescue
      return 'Unknown, Unknown'
    end
  end

  def geocode
    begin
      @geo ||= Geokit::Geocoders::GoogleGeocoder.reverse_geocode("#{self.lat},#{self.lon}")
      return @geo
    rescue
      puts "Could not geocode the coordinates #{self.lat} #{self.lon}"
      return false
    end
  end

  def notification
    begin
      city = self.city
      address = self.address
    rescue
      city = 'Unknown'
      address = 'Unknown, Unknown'
    end

    begin
      stats = "[ #{self.iv('percent')}% | #{self.iv} ]" if self.iv('attack') > 0
      data = { message: "#{self.pokemon_name} #{stats} until #{self.disappear}", 
               attachments: {
                 'pokemon_name' => self.pokemon_name,
                 'mapaddress' => address,
                 'mapcity' => city,
                 'mapurl' => "http://maps.google.com/maps?q=#{self.lat},#{self.lon}",
                 'mapurl_apple' => "http://maps.apple.com/maps?daddr=#{self.lat},#{self.lon}&z=10&t=s&dirflg=w", 
                 'mapimage' => "https://##insertcloudiotokenhere#.cloudimg.io/cdn/n/n/https://maps.googleapis.com/maps/api/staticmap?center=#{self.lat},#{self.lon}&markers=color:red%7C#{self.lat},#{self.lon}&maptype=roadmap&size=200x150&zoom=12&key=##insertgoogleapikeyhere#",
                 'pokemonimage' => "https://##insertcloudiotokenhere#.cloudimg.io/s/width/75/http://assets.pokemon.com/assets/cms2/img/pokedex/full/#{self.pokemon.to_s.rjust(3, "0")}.png" 
               }
             }
      return data 
#"#{self.pokemon_name} #{stats} until #{self.disappear} - http://maps.google.com/maps/?q=#{self.lat},#{self.lon} <https://maps.googleapis.com/maps/api/staticmap?center=#{self.lat},#{self.lon}&markers=color:red%7C#{self.lat},#{self.lon}&maptype=roadmap&size=200x150&zoom=14&key=##insertgoogleapikeyhere#|Image>" 
    rescue => e
      puts e.inspect
      puts e.backtrace
      return false
    end
  end

  def to_s
    return @message.to_json
  end

  def isValid?
    if @message['type']=='pokemon' 

      source = @source || 'unknown'

      if [10,13,16,19,46,69,98,161,167,198,165,177].include? self.pokemon
        #puts "[Encounter] Garbage Pokemon (#{self.pokemon_name}) - Not Sending"
        return false
      end

      if self.disappeartimestamp < (Time.now.to_i + 300) 
        puts "[#{source.upcase}][Encounter] Expired Pokemon (#{self.pokemon_name} expired at #{self.disappear}) - Not Sending"
        return false
      end

      return true

    else
      return false
    end
  end

  def inFence? fence
    lat = self.lat
    lon = self.lon

    if lat.nil? or lon.nil? 
      return false
    end

    begin
      search = Geokit::LatLng.new(lat,lon)
    rescue
      puts "Invalid Search Location #{lot},#{lon}"
      return false
    end

    begin
      geofence = @@geofences.fence fence
      #sw = Geokit::LatLng.new(fence['sw'][0],fence['sw'][1])
      #ne = Geokit::LatLng.new(fence['ne'][0],fence['ne'][1])
      #bounds = Geokit::Bounds.new(sw,ne)
      if geofence.contains? search
        return true
      end
      return false
    rescue => e
      puts "Could not check fence"
      puts "Fence:  SW: #{fence['sw']}   NE: #{fence['ne']}"
      puts "Coords: #{lat}, #{lon}"
      puts "Message: #{@message}"
      puts e.inspect
      puts e.backtrace
      return false
    end
  end

end
