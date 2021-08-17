require 'nokogiri'
require 'open-uri'

class Scraper

  def scrape_city_urls
    idaho_url = 'http://www.museumsusa.org/museums/?k=1271400%2cState%3aID%3bDirectoryID%3a200454'
    html = URI.open(idaho_url)
    doc = Nokogiri::HTML(html)

    cities = doc.css('#ctl08_ctl00_rptChildNodes_dlItems_1').css('.text').css('a')

    city_urls = []

    cities.each do |city|
      url = city.attribute('href').value
      city_urls << url
    end

    scrate_city_pages(city_urls)
  end

  def scrate_city_pages(city_urls)
    museums_list = []
    city_urls.each do |city_url|
      url = "http://www.museumsusa.org#{city_url}"
      html = URI.open(url)
      doc = Nokogiri::HTML(html)

      museums_list << doc.css('.itemGroup').css('.item').css('.basic')
    end

    create_museums(museums_list)
  end

  def create_museums(museums_list)
    museums = []
    museums_list.each do |museum|
      name = museum.css('.party').css('a').text.strip
      location = museum.css('.location').text.strip.split(', ')
      type = museum.css('.type').text.strip
      desc = museum.css('.abstract').text.strip

      museum_info = {
        name: name,
        city: location[0],
        state: location[1],
        categories: type,
        description: desc
      }

      museums << museum_info
    end

    museums
  end
end

scrape = Scraper.new
scrape.scrape_city_urls