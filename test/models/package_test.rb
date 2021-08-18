require "test_helper"

class PackageTest < ActiveSupport::TestCase
  test "should not save package without package name" do
    package = Package.new
    assert_not package.save, "Saved the package without a name"
  end

  test "should not save package without package version" do
    package = Package.new
    package.name = "Abc"
    assert_not package.save, "Saved the package without a version"
  end
end
