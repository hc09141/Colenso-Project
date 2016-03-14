class QueryBasex
  def initialize(input)
    puts "Making a new query"
    @session = BaseXClient::Session.new("localhost", 1984, "admin", "admin")
    @input = input
  end

  def call
    begin
      puts "Calling query"

      textSearch = "declare namespace tei = 'http://www.tei-c.org/ns/1.0/';
      for $file score $score in collection('Colenso_TEIs')
    [.contains text {'#{@input}'}  phrase]
      order by $score descending
    return string($file)" #//text() for display

      results = []

      query = @session.query(textSearch)
      while query.more do
        results.push(query.next)
      end

      query.close()
      @session.close()

      return results
      rescue Exception => e
        # print exception
        puts e
    end
  end
end
