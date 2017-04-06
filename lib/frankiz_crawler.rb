class FrankizCrawler
  def initialize(username, password)
    @username = username
    @password = password
    @cookies = {
      fkz_domain: 'polytechnique.edu',
      fkz_skin: 'default',
      PHPSESSID: 'objj451of350130132rt2elip7',
    }
    @token = 'zou'
    login
  end

  def get(id, write = false)
    html = Nokogiri::HTML(JSON.parse(
      RestClient.post("https://www.frankiz.net/tol/ajax/sheet/#{id}",
                      {
                        params: {
                          token: @token,
                          json: {},
                        },
                      },
                      cookies: @cookies),
    )['sheet'])
    insert(html, id) if write
    html
  rescue RestClient::InternalServerError
    WrongFrankizId.find_or_create_by(frankiz_id: id)
  rescue Errno::ETIMEDOUT
    Rails.logger.warn 'Timeout sleeping'
    sleep 5
  rescue Errno::ENETDOWN
    Rails.logger.warn 'Wifi disconnected'
    sleep 10
  rescue Errno::EHOSTUNREACH
    Rails.logger.warn 'No more internet'
    sleep 10
  end

  def insert(html, id)
    User.find_or_initialize_by(frankiz_id: id).update(
      name: html.css('.name').text.strip,
      email: html.css('.email').text.strip.split(' ').last,
      promo: html.css('.studies li span').first ? html.css('.studies li span').first.text : nil,
      group: html.css('.studies li img').first ? html.css('.studies li img').first.attributes['title'].value : nil,
      casert: html.css('.caserts span').first ? html.css('.caserts span').first.text.split.last : nil,
      birthdate: html.css('.birthdate span').first ? Date.strptime(html.css('.birthdate span').first.text, '%d/%m/%Y') : nil,
      picture: html.css('div.img').first ? html.css('div.img').first.attributes['photo'].value : nil,
      sport: html.css('div.sports img').first ? html.css('div.sports img').first.attributes['title'].value : nil,
    )
  end

  private

  def login_token
    RestClient.get 'https://www.frankiz.net/login'
  rescue RestClient::Forbidden => e
    index_1 = e.response.headers[:set_cookie][0].to_s.index('PHPSESSID=')
    index_2 = e.response.headers[:set_cookie][0].to_s.index(';', index_1)
    @phpsessid = e.response.headers[:set_cookie][0][index_1 + 10..index_2 - 1]
    @cookies[:PHPSESSID] = @phpsessid
    index_1 = e.response.body.index('var xsrf_token = "')
    index_2 = e.response.body.index('"', index_1 + 18)
    @token = e.response.body[index_1 + 18..index_2 - 1]
    return @token
  end

  def login
    login_token
    post_data = {
      'username' => @username,
      'password' => @password,
      'domain' => 'polytechnique.edu',
      'start_connexion' => 'Connexion',
      'remember' => 'on',
      'token' => @token,
    }
    Rails.logger.info "Logging in to Frankiz as #{@username}"
    RestClient.post(
      'https://www.frankiz.net/login',
      post_data,
      cookies: @cookies,
    ) do |response, request, result, &block|
      if [301, 302, 307].include? response.code
        new_page = response.follow_redirection(request, result, &block)
        index_1 = new_page.index('var xsrf_token = "')
        index_2 = new_page.index('"', index_1 + 18)
        @token = new_page[index_1 + 18..index_2 - 1]
      else
        response.return!(request, result, &block)
      end
    end
  end
end
