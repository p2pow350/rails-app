module Uploader

    def self.upload(file)
      _f_path = File.join("tmp", file.original_filename)
      File.open(_f_path, "wb") { |f| f.write(IO.read file.tempfile.path) }
      _f_path 
    end  
    
end