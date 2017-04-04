class FrankizController < ApplicationController
  def index
    @running = system('ps aux | grep -v grep | grep "bin/rake frankiz:"')
    @output = `cat /tmp/frankiz.log`.split("\r").last.to_s.strip
    @fkz_polytechniciens = User
      .where(group: 'Polytechniciens').select(:promo, 'COUNT(*) count', 'MIN(updated_at) updated_at').group(:promo).order(promo: :desc)
    @accounts_x = Account.where(status: [0, 1]).where.not(trigramme: nil)
      .select(:promo, 'CASE WHEN frankiz_id IS NULL THEN 0 ELSE 1 END has_frankiz', 'COUNT(*) count').group(:promo, 'has_frankiz')
    @accounts_not_x = Account.where.not(status: [0, 1]).where.not(trigramme: nil)
      .select(:promo, 'CASE WHEN frankiz_id IS NULL THEN 0 ELSE 1 END has_frankiz', 'COUNT(*) count').group(:promo, 'has_frankiz')
  end

  def start_crawling
    _check_fkz_auth!
    # Spawn crawling in a subprocess
    pid = spawn(
      "fkz_user=#{params[:username]} fkz_pass=#{params[:password]} bin/rake frankiz:crawl",
      out: '/tmp/frankiz.log', err: '/tmp/frankiz.log',
    )
    Process.detach(pid)
    redirect_to_url '/frankiz'
  end

  def refresh_promo
    _check_fkz_auth!
    pid = spawn(
      "fkz_user=#{params[:username]} fkz_pass=#{params[:password]} bin/rake frankiz:refresh_promo[#{params[:promo]}]",
      out: '/tmp/frankiz.log', err: '/tmp/frankiz.log',
    )
    Process.detach(pid)
    redirect_to_url '/frankiz'
  end

  def stop
    `pkill -9 -f "bin/rake frankiz:"`
    redirect_to_url '/frankiz'
  end

  private

  def _check_fkz_auth!
    # Test that username and password seems correct
    fkz = FrankizCrawler.new(params[:username], params[:password])
    html = fkz.get(Account::MANOU_FRANKIZ_ID)
    fail TdbException, 'Something looks wrong' unless html.to_s.include?('thierry.deo@polytechnique.edu')
  end
end
