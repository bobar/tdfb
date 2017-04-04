require 'levenshtein'

class FileImportController < ApplicationController
  before_action do
    require_admin!(:debit_fichier)
  end

  def index
  end

  def read_file
    file = params[:file]
    rows = case File.extname(file.path).downcase
           when '.csv'
             require 'csv'
             CSV.read(file.path)
           end
    @entries = to_hashes(rows)
    accounts = Account.where(trigramme: @entries.map { |e| e[:trigramme] }).index_by(&:trigramme)
    @entries.each do |e|
      acc = accounts[e[:trigramme]]
      e[:comments] = []
      if acc.nil?
        e[:comments] << I18n.t(:no_account_for_trigramme, trigramme: e[:trigramme])
        e[:level] ||= :fatal
        e[:int_level] ||= 3
        next
      end
      if e[:price] < 0
        e[:comments] << I18n.t(:negative_amount)
        e[:level] ||= :danger
      end
      if acc.budget < e[:price] && !acc.x_platal?
        e[:comments] << I18n.t(:not_x_goes_negative)
        e[:level] ||= :danger
      end
      if string_array_matching(e[:name], acc.full_name) > 2
        e[:comments] << I18n.t(:name_mismatch, name: acc.full_name)
        e[:level] ||= :danger
      end
      if e[:price] > 20
        e[:comments] << I18n.t(:high_price)
        e[:level] ||= :warning
      end
      if acc.budget < e[:price] && acc.x_platal?
        e[:comments] << I18n.t(:account_goes_negative)
        e[:level] ||= :warning
      end
      e[:int_level] = 2 if e[:level] == :danger
      e[:int_level] = 1 if e[:level] == :warning
    end
    @entries.sort_by! { |e| [-e[:int_level].to_i, e[:trigramme]] }
  end

  private

  def to_hashes(rows)
    trigramme_like = -> (x) { x && x.to_s.strip =~ /^[a-zA-Z0-9]{3}$/ }
    amount_like = -> (x) { x && x.to_s.strip =~ /^[-+]?\d*(.\d*)?$/ }
    cols = (0..rows.first.size).to_a
    trigramme_col = cols.max_by { |c| rows.count { |r| trigramme_like.call(r[c]) } }
    cols -= [trigramme_col]
    amount_col = cols.max_by { |c| rows.count { |r| amount_like.call(r[c]) } }
    cols -= [amount_col]
    rows.each_with_index.map do |r, i|
      {
        idx: i + 1,
        trigramme: r[trigramme_col].strip.upcase,
        price: r[amount_col].strip.tr(',', '.').to_f,
        name: r.values_at(*cols).map(&:to_s).map(&:strip).map(&:capitalize).join(' ').strip,
      }
    end
  end

  def string_array_matching(a, b)
    return 100 if a.nil? || b.nil? || a.blank? || b.blank?
    a, b = [a, b].map { |s| I18n.transliterate(s).downcase.gsub(/[^a-z]/, ' ').split(' ') }
    a.map { |a1| b.map { |b1| Levenshtein.distance(a1, b1) }.min }.max
  end
end
