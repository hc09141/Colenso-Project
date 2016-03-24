class FolderParser

  def initialize(originalPath, list)
    @path = originalPath
    @list = list
  end

  def parse
    results = Hash.new(0)
    @list.each do |item|
      newDir = getDir(item)
      results[newDir] += 1
    end
    results
  end

  def getDir(item)
    if !@path.empty?
      start = @path.length
    else
      start = 0
    end
    final = @path.length + 1
    final += 1 until item[final + 1] == '/' || final == item.length - 1
    newDir = item[start .. final]
  end

end
