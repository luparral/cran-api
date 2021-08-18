require 'zlib'
require 'rubygems/package'
require 'open-uri'

class PackagesController < ApplicationController
  URI_CRAN = "http://cran.r-project.org/src/contrib/"

  # https://stackoverflow.com/questions/13306003/cant-convert-stringio-into-string-typeerror-in-ruby
  OpenURI::Buffer.send :remove_const, 'StringMax'
  OpenURI::Buffer.const_set 'StringMax', 0

  def index
    packages = Net::HTTP.get(URI.parse("#{URI_CRAN}/PACKAGES"))
    parsed_packages = parse(packages)

    # For each package/version, download the tar.gz to get all the data.
    parsed_packages.map do |package|
      name = package["Package"]
      version = package["Version"]
      if name[0] == "a" #simple constraint to avoid downloading all the packages
        unless package_already_exists(name, version)
          full_package_info = download_data(name, version)

          parsed_package_info = parse_description(full_package_info)

          Package.create(name: parsed_package_info["Package"],
                         version: parsed_package_info["Version"],
                         date_publication: parsed_package_info["Date/Publication"],
                         title: parsed_package_info["Title"],
                         description: parsed_package_info["Description"],
                         authors: parsed_package_info["Author"],
                         maintainers: parsed_package_info["Maintainer"])
        end
      end
    end
    @packages = Package.all
  end

  def package_already_exists(name, version)
    Package.where(name: name, version: version).exists?
  end

  def download_data(name, version)
    uri_package = URI.open("#{URI_CRAN}/#{name}_#{version}.tar.gz")
    description_file = "#{name}/DESCRIPTION"
    content = ""
    gzip = Zlib::GzipReader.open(uri_package)
    Gem::Package::TarReader.new gzip do |tar|
      content << tar.seek(description_file, &:read).force_encoding("UTF-8")
    end
    content
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

