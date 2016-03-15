require_relative('folder_parser.rb')

class QueryBasex
  def initialize(input, searchType, directory)
    @session = BaseXClient::Session.new('localhost', 1984, 'admin', 'admin')
    @input = input
    @searchType = searchType
    @directory = directory
  end

  def list()
    # Creates query with directory
    if @directory && !@directory.empty?
      listCommand = "XQUERY db:list('Colenso_TEIs', '#{@directory}')"
    else
      listCommand = "XQUERY db:list('Colenso_TEIs')"
    end

    # Gets results
    list = @session.execute(listCommand).split("\n");
    @session.close

    parser = FolderParser.new(@directory, list).parse
  end

  def call
    begin
      textSearch = formTextQuery if @searchType == "Text"
      textSearch = formXQuery if @searchType == "xQuery"

      puts textSearch

      results = []

      query = @session.query(textSearch)
      results.push(query.next) while query.more

      query.close
      @session.close

      return results
      rescue Exception => e
        # print exception
        puts e
      end
  end

  def formTextQuery
    puts "Doing a text query"
    words = @input.split(" ")
    phrase = ""
    phrases = []

    # Splits up phrases and operators
    words.each do |word|
      if word == "ADD" || word == "OR" || word == "NOT"
        phrases.push("'#{phrase}' ") if !phrase.empty?
        phrases.push("#{word} ")
        phrase = ""
      else
        phrase << "#{word} "
      end
    end

    phrases.push("'#{phrase}' ") if !phrase.empty?

    # Forms xQuerySearch

    textSearch = "declare namespace tei = 'http://www.tei-c.org/ns/1.0';
    for $file score $score in collection('Colenso_TEIs')
    [.contains text "

    phrases.each do |p|
      case p
      when "AND "
        textSearch << "ftand"
      when "OR "
        textSearch << "ftor"
      when "NOT "
        textSearch << "ftnot"
      else
        textSearch << p
      end
    end

    textSearch << "using wildcards]
    order by $score descending
    return string($file//tei:title)"
  end

  def formXQuery
    xQuerySearch = 'declare namespace tei = "http://www.tei-c.org/ns/1.0"; '
    xQuerySearch << "#{@input}"
  end

end
