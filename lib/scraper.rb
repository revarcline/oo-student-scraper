require 'open-uri'
require 'pry'

# using nokogiri!
class Scraper
  def self.scrape_index_page(index_url)
    page = Nokogiri::HTML(open(index_url))
    scraped_students = []

    # gotta do some digging, find students
    # each: div.student-card a - get href
    # get array of links this way
    # looking for:
    #   - link is href
    #   - name .student-name text
    #   - location .profile-location text

    page.css('div.roster-cards-container').each do |entry|
      entry.css('.student-card').each do |student|
        link = student.css('a').attr('href').to_s
        name = student.css('.student-name').text
        location = student.css('.student-location').text
        student_hash = { profile_url: link,
                         name: name,
                         location: location }
        scraped_students << student_hash
      end
    end
    scraped_students
  end

  def self.scrape_profile_page(profile_url)
    # dig for each profile after getting url from previous
    # generate hash
    # look for
    #   - profile_quote .profile-quote
    #   - bio div.bio-content.content-holder div.description-holder p -text
    # ok so inside of .social-icon-container, collect each href element
    # use regex to attach each element to correct key?
    #   - twitter
    #   - linkedin
    #   - github
    #   - blog

    student_info = {}
    profile = Nokogiri::HTML(open(profile_url))

    bio_dom = profile.css('div.bio-content.content-holder div.description-holder p')
    quote_dom = profile.css('.profile-quote')
    student_info[:bio] = bio_dom.text if bio_dom
    student_info[:profile_quote] = quote_dom.text if quote_dom

    socials = profile.css('.social-icon-container').children.css('a').map do |button|
      button.attribute('href').value
    end
    socials.each do |url|
      case url
      when /twitter/
        student_info[:twitter] = url
      when /github/
        student_info[:github] = url
      when /linkedin/
        student_info[:linkedin] = url
      else
        student_info[:blog] = url
      end
    end
    student_info
  end
end
