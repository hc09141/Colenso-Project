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
    search = "declare default element namespace 'http://www.tei-c.org/ns/1.0';
    for $file in collection('Colenso_TEIs') "
    @input.each_slice(2) do |q, s|
      search << formTextQuery(q) if s == 'Text'
      search << formXPathQuery(q) if s == 'xPath'
      search << formXQuery(q) if s == 'xQuery'
    end

    search << "return <result><name>{file:name(db:path($file))}</name>
    <path>{file:resolve-path(db:path($file), 'C:/Users/Hannah/My Documents/2016/SWEN303/Colenso_TEIs/')}</path></result>//text()"

  puts search

    t = Tempfile.new('search-results')
    Zip::OutputStream.open(t.path) do |zos|
      query = @session.query(search)
      while query.more
        zos.put_next_entry(query.next)
        zos.print IO.read(query.next)
      end
      query.close
      @session.close
    end
    t
  end

  def addLetter
    t = Tempfile.new(@newLetter)
    t.binmode
    t.write(@input)
    t.close

    @session.execute("XQUERY db:add('Colenso_TEIs', '#{t.path}', '#{@directory}/#{@newLetter}')")
    @session.close
  end

  def editLetter
    begin
      @session.execute("XQUERY validate:xsd(#{@newLetter}, 'http://www.tei-c.org/release/xml/tei/custom/schema/xsd/tei_all.xsd')")
      @session.execute("XQUERY db:replace('Colenso_TEIs', '#{@directory}', " + @newLetter + ')')
    rescue Exception => e
      return false
    end
    @session.close
    return true
  end

  def browse
    if @directory.include?('.xml')
      puts 'display'
      display
    else
      puts 'list'
      list
    end
  end

  def display
    letter = @session.execute("XQUERY db:open('Colenso_TEIs', '#{@directory}')")
    @session.close
    letter
  end

  def list
    puts @directory.to_s
    if @directory && !@directory.empty?
      listCommand = "XQUERY db:list('Colenso_TEIs', '#{@directory}')"
    else
      listCommand = "XQUERY db:list('Colenso_TEIs')"
    end

    # Gets results
    list = @session.execute(listCommand).split("\n")
    @session.close
    puts @directory.to_s
    puts list

    parser = FolderParser.new(@directory, list).parse
    return parser

  rescue Exception => e
    # print exception
    puts e
  end

  def call
    textSearch = "declare default element namespace 'http://www.tei-c.org/ns/1.0';
     for $file score $score in collection('Colenso_TEIs') "
    @input.each_slice(2) do |q, searchType|
      textSearch << formTextQuery(q) if searchType == 'Text'
      textSearch << formXPathQuery(q) if searchType == 'xPath'
      textSearch << formXQuery(q) if searchType == 'xQuery'
    end

    textSearch << "order by $score descending
    return (<result>
       <name>{$file//title}</name>
       <path>{db:path($file)}</path>
       <author> by {($file//author)[1]//text()}</author>
       <excerpt>{fn:substring($file//body,0,200)}...</excerpt>
       </result>)//text()"

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

  def formXPathQuery(query)
    search = " where $file#{query} "
  end

  def formTextQuery(query)
    words = query.split(' ')
    phrase = ''
    phrases = []

    # Splits up phrases and operators
    words.each do |word|
      if word == 'ADD' || word == 'OR' || word == 'NOT'
        phrases.push("'#{phrase}' ") unless phrase.empty?
        phrases.push("#{word} ")
        phrase = ''
      else
        phrase << "#{word} "
      end
    end

    phrases.push("'#{phrase}' ") unless phrase.empty?

    # Forms xQuerySearch
    textSearch = 'where $file[.contains text '
    phrases.each do |p|
      textSearch << case p
                    when 'AND '
                      'ftand'
                    when 'OR '
                      'ftor'
                    when 'NOT '
                      'ftnot'
                    else
                      p
                    end
      textSearch << 'using wildcards] '
    end
    textSearch
  end

  def formXQuery(query)
    xQuerySearch = ' where '
    xQuerySearch << "#{query} "
  end
end
