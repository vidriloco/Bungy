class Instant < ActiveRecord::Base
  include Geography
  attr_accessor :lat, :lon
  
  before_validation :apply_coordinates
  belongs_to :gps_unit
  
  #after_save :register_tracking
  
  def apply_coordinates
    self.apply_geo({"lon" => lon, "lat" => lat})
  end
  
  def lat
    return @lat unless @lat.nil?
    return coordinates.lat unless coordinates.nil?
  end
  
  def lon
    return @lon unless @lon.nil?
    return coordinates.lon unless coordinates.nil?
  end
  
  def register_tracking
    Tracking.register(self)
  end
  
  def self.convert_to_signed_twos_complement(integer_value, num_of_bits)
    length       = num_of_bits
    mid          = 2**(length-1)
    max_unsigned = 2**length
    (integer_value >= mid) ? integer_value - max_unsigned : integer_value
  end
  
  rails_admin do 
    label do
      I18n.t('models.instant.name')
    end
    
    edit do
      include_fields :speed, :gps_unit, :heading, :measurement_time, :altitude
      
      field :lat do 
        label I18n.t('models.checkpoint.fields.latitude')
        help I18n.t('admin.form.required')
      end
      
      field :lon do
        label I18n.t('models.checkpoint.fields.longitude')
        help I18n.t('admin.form.required')
      end
    end
    
  end
  
  def self.parse_plot(data)
    # IP Message Mode
    if data[0,4] == 'MCGP'
      mode = data[4].unpack('C*').first
      transmission_reason = data[18].unpack("C*").first
      transmission_reason_specific = data[17].unpack("C*").first
      
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
        
        unless gps_unit.blank?
          instant = Instant.new(
            :gps_unit_id => gps_unit.id, 
            :altitude => altitude, 
            :speed => speed, 
            :heading => heading, 
            :measurement_time => DateTime.new(year, month, day, hours, minutes, seconds),
            :lat => latitude, 
            :lon => longitude,
            :transmission_reason => transmission_reason,
            :transmission_reason_specific_data => transmission_reason_specific)
          instant.save
          #p "Instant saved at #{instant.created_at.to_s} with GPS unit: #{gps_unit.identifier}"
        end  
      # Programming data mode
      elsif mode == 1
        
      end
    # SMS Mode
    elsif data[0,4] == 'MCGS' 
      
    end
    
    header_request = data[0,8]
    header_request[4] = [4].pack("C*")
    
    command_numerator = [0].pack("C*")
    auth_code = [0,0,0,0].pack("C*")
    action_code = [0].pack("C*")
    
    p "BIN: #{data[11].unpack("B")[0]} HEX: #{data[11]} DEC: #{data[11].unpack("C*")} MSB: #{data[11].unpack("B")[0].to_i} LSB: #{data[11].unpack("b")[0].to_i}"
    
    main_ack_lsb = [0].pack("C*")
    main_ack_msb = data[11]
    #main_ack_lsb = [0].pack("C*")
    #main_ack_msb = [1].pack("C*")
    seco_ack_duo = [0,0].pack("C*")
    reserved = ([0]*8).pack("C*")
    
    #p "#{(data[11] & 0x0F)}"
    # HR: byte 1-9 | CNF: byte 10 | AC: byte 11-14 | ACTC: 15 |
    pre_response = header_request+command_numerator+auth_code+action_code+main_ack_lsb+main_ack_msb+seco_ack_duo+reserved
    
    pre_response+[pre_response[4,27].unpack("C*").inject(0) { |cu, co| co+=cu }].pack("C*")
  end
  
  #00 00 00 00 00 00 02 00 00 00 00 0E A1 52 EB 80 00 00 63 
  #02 00 00 00 00 00
  #00 00 00 00 00 01 01 00 00 00 00 00 00 00 00 00 00 D1 
  
  def self.all_for(company)
    instants = []
    company.gps_units.each do |unit|
      instant = unit.instants.last
      instants << instant unless instant.nil?
    end
    instants
  end
end
