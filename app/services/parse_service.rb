class ParseService
  def initialize(data)
    @data = data
  end

  def parse
    # This takes the packages info raw as a string and convert it into an array of packages (as hash).
    result_array = Array.new
    array = @data.encode("UTF-8", invalid: :replace, replace: "").split("\n\n") # get array of packages as strings
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

  def parse_description
    parse[0]
  end
end
