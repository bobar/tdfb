module Chart
  def self.transactions_volume(days, bank)
    debits = Transaction.select('DATE(date) as day, SUM(ABS(price)) as sum')
      .where.not(id: bank.id)
      .where(id2: bank.id)
      .where('price < 0')
      .where('date > ?', Time.current - days.days)
      .group('day')
    credits = Transaction.select('DATE(date) as day, SUM(price) as sum')
      .where.not(id: bank.id)
      .where(id2: bank.id)
      .where('price > 0')
      .where('date > ?', Time.current - days.days)
      .group('day')
    LazyHighCharts::HighChart.new('graph') do |f|
      f.title(text: "Transactions des #{days} derniers jours")
      f.xAxis(categories: debits.map { |t| t.day.strftime('%a %e') })
      f.series(name: 'Débits', yAxis: 0, data: debits.map { |t| t.sum / 100 })
      f.series(name: 'Crédits', yAxis: 0, data: credits.map { |t| t.sum / 100 })
      f.yAxis [{ title: { text: 'Euros' } }]
      f.chart(defaultSeriesType: 'column')
    end
  end

  def self.best_consumers(days, bank)
    consumers = Transaction.select('trigramme, SUM(ABS(price)) as sum')
      .joins(:payer)
      .where.not(accounts: { status: 2 })
      .where.not(id: bank.id)
      .where(id2: bank.id)
      .where('price < 0')
      .where('date > ?', Time.current - days.days)
      .group(:id)
      .order('sum DESC')
      .limit(20)
    LazyHighCharts::HighChart.new('graph') do |f|
      f.title(text: "Meilleurs consommateurs des #{days} derniers jours")
      f.xAxis(categories: consumers.map(&:trigramme))
      f.series(name: 'Consommation', yAxis: 0, data: consumers.map { |t| t.sum / 100 })
      f.yAxis [{ title: { text: 'Euros' } }]
      f.chart(defaultSeriesType: 'column')
    end
  end
end
