module PackagesHelper
  def package_already_exists(name, version)
    Package.where(name: name, version: version).exists?
  end
end
