class FrankizController < ApplicationController
  before_action do
    require_admin!(:modifier_tri)
  end

  def index
    @running = system('ps aux | grep -v grep | grep "bin/rake frankiz:"')
    @output = `tail -n1 /tmp/frankiz.log`.split("\r").last.to_s.strip
    @fkz_users = User.select(:promo, 'COUNT(*) count', 'MIN(updated_at) updated_at').group(:promo).order(promo: :desc)
    max_promo = @fkz_users.first[:promo]
    @fkz_users.unshift(promo: max_promo.to_i + 1)
    @accounts_x = Account.where(status: [0, 1]).where.not(trigramme: nil)
      .select(:promo, 'CASE WHEN frankiz_id IS NULL THEN 0 ELSE 1 END has_frankiz', 'COUNT(*) count').group(:promo, 'has_frankiz')
    @accounts_not_x = Account.where.not(status: [0, 1]).where.not(trigramme: nil)
      .select(:promo, 'CASE WHEN frankiz_id IS NULL THEN 0 ELSE 1 END has_frankiz', 'COUNT(*) count').group(:promo, 'has_frankiz')
  end

  def unassociated_accounts
    @accounts = Account.where.not(balance: 0, trigramme: nil, status: Account.statuses.slice(:binet, :personnel).values)
      .where(frankiz_id: nil)
      .order(promo: :desc)
  end

  def associate
    account = Account.find_by(frankiz_id: params[:frankiz_id].to_i)
    fail TdbException, I18n.t(:fkz_id_used, trigramme: "#{account.full_name} (#{account.trigramme})", link: "/account/#{account.id}") if account
    Account.find(params[:account_id]).update(frankiz_id: params[:frankiz_id].to_i)
    redirect_to_url('/frankiz/unassociated_accounts')
  end

  def refresh_promo
    command = if Rails.env.production?
                "mkdir -p ~/.ssh &&
                  echo \"#{ENV['DEIZ_SSH']}\" | sed 's/\\\\n/\\n/g' > ~/.ssh/id_rsa;
                  LDAP_PROXY=http://localhost:1080 bin/rake frankiz:refresh_promo[#{params[:promo]}] |
                    ssh -i ~/.ssh/id_rsa -oStrictHostKeyChecking=no manou@deiz.polytechnique.fr -p 2222 -D1080 cat"
              else
                _check_fkz_ldap!
                "bin/rake frankiz:refresh_promo[#{params[:promo]}]"
              end
    pid = spawn(ENV, command, out: '/tmp/frankiz.log', err: '/tmp/frankiz.log')
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
