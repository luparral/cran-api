require 'rubygems/package'
require 'open-uri'

class PackagesController < ApplicationController
  include Response
  def index
    # packages = File.open('packages_local.txt').read
    packages = Net::HTTP.get(URI.parse("#{URI_CRAN}/PACKAGES"))
    parsed_packages = ParseService.new(packages).parse
    # For each package/version, download the tar.gz to get all the data.
    parsed_packages.map do |package|
      name = package["Package"]
      version = package["Version"]
      if name[0] == "a" #simple constraint to avoid downloading all the packages
        unless helpers.package_already_exists(name, version)
          full_package_info = DownloadService.new(name, version).download_data
          parsed_package_info = ParseService.new(full_package_info).parse_description
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
    json_response(@packages)
  end

end

