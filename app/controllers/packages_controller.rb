require 'zlib'
require 'rubygems/package'
require 'open-uri'

class PackagesController < ApplicationController
  URI_CRAN = "http://cran.r-project.org/src/contrib/"

  OpenURI::Buffer.send :remove_const, 'StringMax'
  OpenURI::Buffer.const_set 'StringMax', 0

  def index
    result = Net::HTTP.get(URI.parse("#{URI_CRAN}/PACKAGES"))
    parsed = parse(result)

    # For each package/version, download the tar.gz to get all the data.
    parsed.map do |package|
      name = package["Package"]
      version = package["Version"]
      if name[0] == "a"
        unless Package.where(name: name, version: version).exists?
          uri_package = URI.open("#{URI_CRAN}/#{name}_#{version}.tar.gz")
          description_file = "#{name}/DESCRIPTION"
          content = ""
          gzip = Zlib::GzipReader.open(uri_package)
          Gem::Package::TarReader.new gzip do |tar|
            content << tar.seek(description_file, &:read).force_encoding("UTF-8")
          end

          package_info = parse_description(content)
          package_name = package_info["Package"]
          version = package_info["Version"]
          date_publication = package_info["Date/Publication"]
          title = package_info["Title"]
          description = package_info["Description"]
          authors = package_info["Author"]
          maintainers = package_info["Maintainer"]

          Package.create(name: package_name,
                         version: version,
                         date_publication: date_publication,
                         title: title,
                         description: description,
                         authors: authors,
                         maintainers: maintainers)

        end
      end

    end
    @packages = Package.all
  end


  def parse_description(data)
    parse(data)[0]
  end

  def parse (data)
    # This takes the packages info raw as a string and convert it into an array of packages (as hash).
    result_array = Array.new

    array = data.encode("UTF-8", invalid: :replace, replace: "").split("\n\n") # get array of packages as strings

    array.map do |package|
      h = Hash.new
      package.split("\n").map do |info|
        key, value = info.split(': ')
        h[key] = value
      end
      result_array << h
    end

    result_array

  end

end

