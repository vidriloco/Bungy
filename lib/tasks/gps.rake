namespace :gps do
  desc "Starts a TCP server that fetches and integrates a GPS plot"
  task listener: :environment do
    require 'eventmachine'

     class EchoServer < EM::Connection
       def post_init
         puts "-- someone connected to the echo server!"
       end

       def receive_data data
        response_header = Instant.parse_plot(data)
        
        p response_header
        send_data(response_header)
       end
       
       def bind
         p "Binded"
       end
       
       def unbind
         puts "-- someone disconnected from the echo server!"
      end
    end

    # Note that this will block current thread.
    EventMachine.run {
      EventMachine.start_server "0.0.0.0", 3001, EchoServer
    }
  end

end

