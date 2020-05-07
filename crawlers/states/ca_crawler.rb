# frozen_string_literal: true

class CaCrawler < BaseCrawler
  using ExtendedRTesseract

  protected

  def _set_up_page
    url = wait.until {
      @driver.find_element(xpath: "//a[contains(@title, 'Latest COVID-19 Facts')]")
    }.attribute('href')
    return unless url

    crawl_page url

    html_element = wait.until {
      @driver.find_element(xpath: "//div[@id='WebPartWPQ4']")
    }
    return unless html_element

    # Text from HTML
    @_page_elements = html_element.text.tr(',', '')

    # Text from image
    image_element = html_element.find_element(xpath: "//img[contains(@alt, 'CA_COVID-19')]")
    image_url     = image_element.attribute('src')
    @_image_text  = RTesseract.new(image_url).to_s.tr(',', '')

    true
  end

  def _find_positive
    @results[:positive] = /(\d+) confirmed cases/.match(@_page_elements)[1]&.to_i
  end

  def _find_deaths
    @results[:deaths] = /(\d+) deaths/.match(@_page_elements)[1]&.to_i
  end

  def _find_tested
    @results[:tested] = /(\d+) tests/.match(@_page_elements)[1]&.to_i
  end

  def _find_hospitalized
    hospitalized = /-> (\d+)\/\d+ (\d+)/.match(@_image_text)
    hospitalized_confirmed = hospitalized[1]&.to_i
    hospitalized_suspected = hospitalized[2]&.to_i

    @results[:hospitalized] = hospitalized_confirmed + hospitalized_suspected
  end
end

