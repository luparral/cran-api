require 'zlib'

class DownloadService
  # https://stackoverflow.com/questions/13306003/cant-convert-stringio-into-string-typeerror-in-ruby
  OpenURI::Buffer.send :remove_const, 'StringMax'
  OpenURI::Buffer.const_set 'StringMax', 0

  def initialize(name, version)
    @name = name
    @version = version
  end

  def download_data
    uri_package = URI.open("#{URI_CRAN}/#{@name}_#{@version}.tar.gz")
    description_file = "#{@name}/DESCRIPTION"
    content = ""
    gzip = Zlib::GzipReader.open(uri_package)
    Gem::Package::TarReader.new gzip do |tar|
      content << tar.seek(description_file, &:read).force_encoding("UTF-8")
    end
    content
  end
end