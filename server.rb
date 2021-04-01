require 'socket'
require_relative 'memory'
require_relative 'validation'
require_relative 'CRUD'
include CRUD 


class Server

   def initialize(socket_address, socket_port)

      @server_socket = TCPServer.open(socket_port, socket_address)
      @connections_details = Hash.new
      @connected_clients = Hash.new
      @connections_details[:server] = @server_socket
      @connections_details[:clients] = @connected_clients

      @hash_value = Hash.new
      @hash_flag = Hash.new
      @hash_exptime = Hash.new
      @hash_bytes = Hash.new
      @hash_token = Hash.new
      @hash_date = Hash.new
      @data = Memory.new(@hash_value, @hash_flag, @hash_exptime, @hash_bytes, @hash_token, @hash_date)
      @validate = Validation.new
      @set = Sets.new
      @add = Add.new
      @replace = Replace.new
      @prepend = Prepend.new
      @append = Append.new
      @cas = Cas.new
      @get = Get.new
      @gets = Gets.new

      puts 'Started server.........'
      run

   end

   def run
      loop{
         client_connection = @server_socket.accept
         Thread.start(client_connection) do |conn| 
            conn_name = conn.gets.chomp.to_sym
            if(@connections_details[:clients][conn_name] != nil) # avoid connection if same user is connected
               conn.puts "This username already exist"
               conn.puts "quit"
               conn.kill self
            end

            puts "Connection established #{conn_name} => #{conn}"
            @connections_details[:clients][conn_name] = conn
            conn.puts "Connection established successfully #{conn_name} => #{conn}"

            commands(conn_name, conn) # allow entering commands
         end
      }.join
   end

   def commands(username, connection)
      loop do
        message = connection.gets.chomp
        (@connections_details[:clients]).keys.each do |client|
          if client == username
            array = message.split(" ")


            if @validate.validate_command(array)
              cm = array[0]
              key = array[1]
              flag = array[2]
              exptime = array[3].to_i
              bytes = array[4].to_i
              noreply = array[5]
              
              puts noreply

              case cm

              when "get"

                @get.get_void(@connections_details, client, key, @data)

              when "gets"

                @gets.gets_void(@connections_details,client,@data,array)

              when "set"

                @set.set_void(@connections_details,client,key,bytes,flag,exptime,noreply,@data,@validate,connection)

              when "add"

                @add.add_void(@connections_details,client,key,bytes,flag,exptime,noreply,@data,@validate,connection)

              when "replace"

                @replace.replace_void(@connections_details,client,key,bytes,flag,exptime,noreply,@data,@validate,connection)

              when "append"

                @append.append_void(@connections_details,client,key,bytes,flag,exptime,noreply,@data,@validate,connection)

              when "prepend"

                @prepend.prepend_void(@connections_details,client,key,bytes,flag,exptime,noreply,@data,@validate,connection)

              when "cas"

                @cas.cas_void(@connections_details,client,key,token,bytes,flag,exptime,noreply,@data,@validate,connection)

              else

                @connections_details[:clients][client].puts "ERROR"

              end
            else
              @connections_details[:clients][client].puts "ERROR"
            end
          end
         end
      end
   end
end


Server.new( 8080, "localhost" )
