class FrankizController < ApplicationController
  before_action do
    require_admin!(:modifier_tri)
  end

  def index
    @running = system('ps aux | grep -v grep | grep "bin/rake frankiz:"')
    @output = `tail -n1 /tmp/frankiz.log`.split("\r").last.to_s.strip
    @fkz_users = User.select(:promo, 'COUNT(*) count', 'MIN(updated_at) updated_at').group(:promo).order(promo: :desc)
    min_promo = @fkz_users.first[:promo]
    @fkz_users.unshift(promo: min_promo.to_i + 1)
    @accounts_x = Account.where(status: [0, 1]).where.not(trigramme: nil)
      .select(:promo, 'CASE WHEN frankiz_id IS NULL THEN 0 ELSE 1 END has_frankiz', 'COUNT(*) count').group(:promo, 'has_frankiz')
    @accounts_not_x = Account.where.not(status: [0, 1]).where.not(trigramme: nil)
      .select(:promo, 'CASE WHEN frankiz_id IS NULL THEN 0 ELSE 1 END has_frankiz', 'COUNT(*) count').group(:promo, 'has_frankiz')
  end

  def refresh_promo
    _check_fkz_ldap!
    pid = spawn("bin/rake frankiz:refresh_promo[#{params[:promo]}]", out: '/tmp/frankiz.log', err: '/tmp/frankiz.log')
    Process.detach(pid)
    redirect_to_url '/frankiz'
  end

  def stop
    `pkill -9 -f "bin/rake frankiz:"`
    redirect_to_url '/frankiz'
  end

  private

  def _check_fkz_ldap!
    # Test that LDAP connection works
    fkz = FrankizLdap.new
    manou = fkz.get(Account::MANOU_FRANKIZ_ID)
    fail TdbException, 'Frankiz LDAP not reachable' unless manou
  end
end
