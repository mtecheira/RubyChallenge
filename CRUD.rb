module CRUD

  class RetrivalCommand
    def put(connections_details,client,key,data)
      if data.hash_value.has_key?(key)
        date = Time.now
        date_value = data.hash_date["#{key}"]
        diference = date - date_value
        if diference < data.hash_exptime["#{key}"] || data.hash_exptime["#{key}"] == 0
          connections_details[:clients][client].puts "#{data.hash_value["#{key}"]} #{key}  #{data.hash_flag["#{key}"]}  #{data.hash_bytes["#{key}"]}"
        else
          data.delete_data(key)
          connections_details[:clients][client].puts "NOT_STORED"
        end
      else
        connections_details[:clients][client].puts "NOT_STORED"
      end
    end
  end

  class Get < RetrivalCommand
    def get_void(connections_details,client,key,data)
      put(connections_details,client,key,data)
    end
  end

  class Gets < RetrivalCommand
    def gets_void (connections_details,client,data,array)
      array.each do |n|
        if n != "gets"
          put(connections_details,client,n,data)
        end
      end
    end
  end

  class StorageCommand
    def set(connections_details,client,key,bytes,flag,exptime,noreply,data,validate,value)
      if validate.validate_value(value,bytes)
        data.asign_data(key,value,bytes,flag,exptime)
        if noreply != "noreply"
          connections_details[:clients][client].puts "STORED"
        end
      else
        connections_details[:clients][client].puts "CLIENT_ERROR [WRONG VALUE OR WRONG BYTES]"
      end
    end
  end

  class Sets < StorageCommand
    def set_void(connections_details,client,key,bytes,flag,exptime,noreply,data,validate,connection)
      value = connection.gets.chomp
      set(connections_details,client,key,bytes,flag,exptime,noreply,data,validate,value)
    end
  end

  class Add < StorageCommand
    def add_void(connections_details,client,key,bytes,flag,exptime,noreply,data,validate,connection)
      if !data.hash_value.has_key?(key)
        value = connection.gets.chomp
        set(connections_details,client,key,bytes,flag,exptime,noreply,data,validate,value)
      else
        connections_details[:clients][client].puts "NOT_STORED"
      end
    end
  end

  class Replace < StorageCommand
    def replace_void(connections_details,client,key,bytes,flag,exptime,noreply,data,validate,connection)
      if data.hash_value.has_key?(key)
        value = connection.gets.chomp
        set(connections_details,client,key,bytes,flag,exptime,noreply,data,validate,value)
      else
        connections_details[:clients][client].puts "NOT_STORED"
      end
    end
  end

  class Append < StorageCommand
    def append_void(connections_details,client,key,bytes,flag,exptime,noreply,data,validate,connection)
      if data.hash_value.has_key?(key)
        value = connection.gets.chomp
        new_value = data.hash_value["#{key}"] + value
        new_bytes = data.hash_bytes["#{key}"] + bytes
        set(connections_details,client,key,new_bytes,flag,exptime,noreply,data,validate,new_value)
      else
        connections_details[:clients][client].puts "NOT_STORED"
      end
    end
  end

  class Prepend < StorageCommand
    def prepend_void(connections_details,client,key,bytes,flag,exptime,noreply,data,validate,connection)
      if data.hash_value.has_key?(key)
        value = connection.gets.chomp
        new_value = value + data.hash_value["#{key}"]
        new_bytes = data.hash_bytes["#{key}"] + bytes
        set(connections_details,client,key,new_bytes,flag,exptime,noreply,data,validate,new_value)
      else
        connections_details[:clients][client].puts "NOT_STORED"
      end
    end
  end

  class Cas < StorageCommand
    def cas_void(connections_details,client,key,token,bytes,flag,exptime,noreply,data,validate,connection)
      if data.hash_value.has_key?(key)
        unless data.hash_token.has_key?(key)
          data.hash_token["#{key}"] = token
        end
        if data.hash_token["#{key}"] == token
          value = connection.gets.chomp
          set(connections_details,client,key,bytes,flag,exptime,noreply,data,validate,value)
        else
          connections_details[:clients][client].puts "EXIST"
        end
      else
        if client == username
          connections_details[:clients][client].puts "NOT_FOUND"
        end
      end
    end
  end

end
