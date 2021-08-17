require 'zlib'
require 'rubygems/package'
require 'open-uri'


class PackagesController < ApplicationController
  def index

    uri = "https://cran.r-project.org/src/contrib/PACKAGES"
    logger.debug "URI Packages: #{uri}"
    # Get all the packages
    #result = Net::HTTP.get(URI.parse(uri))
    result = File.open("packages_local.txt").read
    parsed = parse(result)
    logger.debug "Parsed: #{parsed}"

    # For each package/version, download the tar.gz to get all the data.
    parsed.map do |package|
      name = package["Package"]
      version = package["Version"]

      unless Package.where(name: name, version: version).exists?
        #uri_package = "http://cran.rproject.org/src/contrib/#{name}_#{version}.tar.gz"
        #source = open(uri_package)

        #
        # It stills need to download and decompress the file .
        # Now the file is already downloaded locally.
        #
        #puts uri_package


        compressed_file = ("A3_1.0.0.tar.gz")

        tar_extract = Gem::Package::TarReader.new(Zlib::GzipReader.open(compressed_file))
        tar_extract.rewind # The extract has to be rewinded after every iteration
        description_file = "#{name}/DESCRIPTION"

        tar_extract.each do |entry|
          if entry.full_name == description_file
            package_info = parse_description(entry.read)
            package_name = package_info["Package"]
            version = package_info["Version"]
            date_publication = package_info["Date/Publication"]
            title = package_info["Title"]
            description = package_info["Description"]
            authors = package_info["Author"]
            maintainers = package_info["Maintainer"]

            # name / email of authors / maintainers was not provided by the api



            Package.create(name: package_name,
                           version: version,
                           date_publication: date_publication,
                           title: title,
                           description: description,
                           authors: authors,
                           maintainers: maintainers)

          end
        end
        tar_extract.close
      end
    end

    Package.all.map { |p| puts p.inspect}
  end


  def parse_description(data)
    parse(data)[0]
  end

  def parse (data)
    # This takes the packages info raw as a string and convert it into an array of packages (as hash).
    result_array = Array.new

    array = data.split("\n\n") # get array of packages as strings

    array.map do |package|
      h = Hash.new # create a hash for each package
      package.split("\n").map do |info| # for each package get the key value info as string and put it in the hash.
        key, value = info.split(': ')
        h[key] = value
      end
      result_array << h # put the hash in the array of packages
    end

    result_array

  end

end

