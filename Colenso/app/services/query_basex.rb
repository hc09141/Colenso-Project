require_relative('folder_parser.rb')
require 'zip'

class QueryBasex
  def initialize(input, searchType, directory, newLetter)
    @session = BaseXClient::Session.new('localhost', 1984, 'admin', 'admin')
    @input = input
    @searchType = searchType
    @directory = directory
    @newLetter = newLetter
  end

  def bulkDownload
    puts "BULK"
    search = "declare default element namespace 'http://www.tei-c.org/ns/1.0';
    let $files:= #{formTextQuery(true)}"

    puts search

    zipfile_name = "/Users/Hannah/Desktop/archive.zip"

    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
      query = @session.query(search)
      zipfile.add(query.next, query.next) while query.more
      query.close
      zipfile.get_output_stream("myFile") { |os| os.write "myFile contains just this" }
    end
    @session.close
  end

  def addLetter
    @session.execute("XQUERY db:add('Colenso_TEIs', '#{@newLetter}', '#{@directory}')")
    @session.close
  end

  def editLetter
    begin
      puts "EDITTED"
      puts @directory
      puts @newLetter
      @session.execute("XQUERY db:replace('Colenso_TEIs', '#{@directory}', " +  @newLetter + ')')
      @session.close
    rescue Exception => e
      # print exception
      puts e
    end
  end

  def browse
    if @directory.include?(".xml")
      puts "display"
      display
    else
      puts "list"
      list
    end
  end

  def display
    letter = @session.execute("XQUERY db:open('Colenso_TEIs', '#{@directory}')")
    @session.close
    letter
  end

  def list
    begin
      # Creates query with directory
      puts "#{@directory}"
      if @directory && !@directory.empty?
        listCommand = "XQUERY db:list('Colenso_TEIs', '#{@directory}')"
      else
        listCommand = "XQUERY db:list('Colenso_TEIs')"
      end

      # Gets results
      list = @session.execute(listCommand).split("\n");
      @session.close
      puts "#{@directory}"
      puts list

      parser = FolderParser.new(@directory, list).parse
      return parser

    rescue Exception => e
      # print exception
      puts e
    end
  end

  def call
    begin
      textSearch = "declare default element namespace 'http://www.tei-c.org/ns/1.0'; "
      textSearch << formTextQuery(false) if @searchType == "Text"
      textSearch << formXQuery if @searchType == "xQuery"
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

  def formTextQuery(returnFile)
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

    textSearch = "for $file score $score in collection('Colenso_TEIs')
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

    if !returnFile
      textSearch << "using wildcards]
      order by $score descending
      return (<result>
      {$file//title}
      <path>{db:path($file)}</path></result>)//text()"
    else
      textSearch << "using wildcards]
        order by $score descending
        return <result><name>{file:name(db:path($file))}</name>
        <path>{file:resolve-path(db:path($file), 'C:/Users/Hannah/My Documents/2016/SWEN303/Colenso_TEIs/')}</path></result>//text()
      return $files"
    end

  end

  def formXQuery
    xQuerySearch = "#{@input}"
  end

end
