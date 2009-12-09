class WelcomeController < ApplicationController
  
  caches_page :index
  caches_page :twitter
  caches_page :source
  caches_page :faq
  caches_page :how_it_works
  
  def index
    puts 
  end
  
end
