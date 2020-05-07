module ExtendedRTesseract
  refine RTesseract do
    def to_s
      save
      super
    end

    private

    def save
      return if File.exists?(@source) && /data\/[a-z]{2,}\//.match(@source)

      c  = caller.find { |e| /crawlers\/states/.match(e) }
      st = /([a-z]{2,})_crawler\.rb/.match(c)[1]

      dir_path  = [__dir__, 'data', st].join('/')
      timestamp = Time.now.to_s[0..18].tr(' ', '-').tr(':', '.')

      Dir.mkdir(dir_path) unless Dir.exists?(dir_path)


      `curl -s #{@source} > #{dir_path}/image_#{timestamp}`
      
      true
    end
  end
end
