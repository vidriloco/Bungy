class Instant < ActiveRecord::Base
  include Geography
  
  belongs_to :gps_unit
  
  def self.convert_to_signed_twos_complement(integer_value, num_of_bits)
    length       = num_of_bits
    mid          = 2**(length-1)
    max_unsigned = 2**length
    (integer_value >= mid) ? integer_value - max_unsigned : integer_value
  end
  
  def self.parse_plot(data)
    # IP Message Mode
    if data[0,4] == 'MCGP'
      mode = data[4].unpack('C*').first
      p "MODE: #{mode}"

      # Status location mode
      if mode == 0
        unit_id = "#{data[5]}#{data[6]}#{data[7]}#{data[8]}".unpack("H*").first
        unit_id = unit_id.scan(/../).reverse.join.to_i( 16 ) 
        
        longitude = "#{data[44]}#{data[45]}#{data[46]}#{data[47]}".unpack("H*").first
        longitude = convert_to_signed_twos_complement(longitude.scan(/../).reverse.join.to_i( 16 ), 32)
        longitude = longitude * 180 / (Math::PI * 10 ** 8)
        
        latitude = "#{data[48]}#{data[49]}#{data[50]}#{data[51]}".unpack("H*").first
        latitude = latitude.scan(/../).reverse.join.to_i( 16 )
        latitude = latitude * 180 / (Math::PI * 10 ** 8)
        
        altitude = "#{data[52]}#{data[53]}#{data[54]}#{data[55]}".unpack("H*").first
        altitude = altitude.scan(/../).reverse.join.to_i( 16 ) * 0.01

        # Kilometers per Hour
        speed = "#{data[56]}#{data[57]}#{data[58]}#{data[59]}".unpack("H*").first
        speed = speed.scan(/../).reverse.join.to_i( 16 ) * 0.036
        
        # 61 y 62
        heading = "#{data[60]}#{data[61]}}".unpack("H*").first
        heading = heading.scan(/../).reverse.join.to_i( 16 ) 
        heading = heading * 180 / (Math::PI * 10 ** 3)
        
        seconds = data[62].unpack("H*").first.to_i( 16 )
        minutes = data[63].unpack("H*").first.to_i( 16 )
        hours = data[64].unpack("H*").first.to_i( 16 )
        day = data[65].unpack("H*").first.to_i( 16 )
        month = data[66].unpack("H*").first.to_i( 16 )
        year = "#{data[67]}#{data[68]}".unpack("H*").first
        year = year.scan(/../).reverse.join.to_i( 16 ) 
        
        gps_unit = GpsUnit.where(:identifier => unit_id.to_s).first
        p gps_unit
        unless gps_unit.blank?
          instant = Instant.new(
            :gps_unit_id => gps_unit.id, 
            :altitude => altitude, 
            :speed => speed, 
            :heading => heading, 
            :measurement_time => DateTime.new(year, month, day, hours, minutes, seconds))
          instant.apply_geo({"lon" => longitude, "lat" => latitude})
          instant.save
        end  
      # Programming data mode
      elsif mode == 1
        
      end
    # SMS Mode
    elsif data[0,4] == 'MCGS' 
      
    end
  end
  
  def self.all_for(company)
    instants = []
    company.gps_units.each do |unit|
      instants << unit.instants.order(measurement_time: :desc).first
    end
    instants
  end
end
