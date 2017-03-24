module Chart
  def self.transactions_volume(days)
    debits = Transaction.select('DATE(date) as day, SUM(ABS(price)) as sum')
      .where("id != 1 AND price < 0 AND `date` > '#{Time.now - days.days}'")
      .group('DATE(date)')
    credits = Transaction.select('DATE(date) as day, SUM(price) as sum')
      .where("id != 1 AND price > 0 AND `date` > '#{Time.now - days.days}'")
      .group('DATE(date)')
    return LazyHighCharts::HighChart.new('graph') do |f|
      f.title(text: "Transactions des #{days} derniers jours")
      f.xAxis(categories: debits.map { |t| t.day.strftime('%a %e') })
      f.series(name: 'Débits', yAxis: 0, data: debits.map { |t| t.sum / 100 })
      f.series(name: 'Crédits', yAxis: 0, data: credits.map { |t| t.sum / 100 })
      f.yAxis [
        { title: { text: 'Volume' } }
      ]
      f.chart(defaultSeriesType: 'column')
    end
  end

  def self.best_consumers(days)
    consumers = Transaction.select('transactions.id, accounts.trigramme as trigramme, accounts.status, SUM(ABS(price)) as sum')
      .joins(:payer)
      .where('accounts.status != 2')
      .where("transactions.id != 1 AND id2 = 1 AND price < 0 AND `date` > '#{Time.now - days.days}'")
      .group('transactions.id')
      .order('sum DESC')
      .limit(20)
    return LazyHighCharts::HighChart.new('graph') do |f|
      f.title(text: "Meilleurs consommateurs des #{days} derniers jours")
      f.xAxis(categories: consumers.map(&:trigramme))
      f.series(name: 'Consommation', yAxis: 0, data: consumers.map { |t| t.sum / 100 })
      f.yAxis [
        { title: { text: 'Volume' } }
      ]
      f.chart(defaultSeriesType: 'column')
    end
  end
end
