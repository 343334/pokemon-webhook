require 'json'

class Pokedex

  DATAFILE = 'lib/pokemon.json'

  def initialize (id=0)
    file = File.read(DATAFILE)
    @@dex = JSON.parse(file) 
    @current = id
  end

  def show
    puts @@dex
  end

  def find (id=0)
    if id.is_a? String 
      p = @@dex.select {|k,v| v['name'].downcase==id.downcase}
      @current =  p.keys[0].to_i
    else
      @current = id.to_i
    end
    self
  end

  def name
    begin
      return @@dex[@current.to_s]['name']
    rescue => e
      puts e.inspect
      puts e.backtrace
      return false
    end
  end

  def id
    begin
      return @current.to_i
    rescue => e
      puts e.inspect
      puts e.backtrace
      return false
    end
  end

end

#dex = Pokedex.new
#puts dex.find(149).name
#puts dex.find('Dragonite').id
