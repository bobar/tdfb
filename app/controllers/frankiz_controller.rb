class FrankizController < ApplicationController
  def index
    @fkz_polytechniciens = User.where(group: 'Polytechniciens').select(:promo, 'COUNT(*) count').group(:promo).order(promo: :desc)
    @accounts_x = Account.where(status: [0, 1])
      .select(:promo, 'CASE WHEN frankiz_id IS NULL THEN 0 ELSE 1 END has_frankiz', 'COUNT(*) count').group(:promo, 'has_frankiz')
    @accounts_not_x = Account.where.not(status: [0, 1])
      .select(:promo, 'CASE WHEN frankiz_id IS NULL THEN 0 ELSE 1 END has_frankiz', 'COUNT(*) count').group(:promo, 'has_frankiz')
  end

  def start_crawling
    # Test that username and password seems correct
    fkz = FrankizCrawler.new(params[:username], params[:password])
    html = fkz.get(Account::MANOU_FRANKIZ_ID)
    fail TdbException, 'Something looks wrong' unless html.to_s.include?('thierry.deo@polytechnique.edu')
    # Spawn crawling in a subprocess
    pid = spawn(
      "fkz_user=#{params[:username]} fkz_pass=#{params[:password]} bin/rake frankiz:crawl",
      out: '/tmp/frankiz.log', err: '/tmp/frankiz.log',
    )
    Process.detach(pid)
    redirect_to_url '/frankiz'
  end
end
