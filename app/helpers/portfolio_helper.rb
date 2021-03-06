module PortfolioHelper
  def portfolio_value_for(category, name)
    if @portfolio_value.present?
      value = [0, 0] if (value = @portfolio_value[category][name]).blank?
      return value
    end
    @portfolio_value = { book: {}, asset: {}, total: { total: [0, 0] } }
    @holdings.each do |h|
      h.books.each do |book_id, quantity|
        @portfolio_value[:book][book_id] ||= [0, 0]
        @portfolio_value[:book][book_id][0] += h.initial_value * quantity / h.quantity
        @portfolio_value[:book][book_id][1] += h.current_value * quantity / h.quantity
      end
      @portfolio_value[:asset][h.asset_identifier] = [h.initial_value, h.current_value]
      @portfolio_value[:total][:total][0] += h.initial_value
      @portfolio_value[:total][:total][1] += h.current_value
    end
    @books.each do |book|
      book.children.each do |book_child|
        @portfolio_value[:book][book.id] ||= [0, 0]
        @portfolio_value[:book][book_child.id] ||= [0, 0]
        @portfolio_value[:book][book.id][0] += @portfolio_value[:book][book_child.id][0]
        @portfolio_value[:book][book.id][1] += @portfolio_value[:book][book_child.id][1]
      end
    end
    portfolio_value_for(category, name)
  end

  def holdings_for_book(book_id)
    return [] if @holdings.blank?
    return (@holdings_for_book[book_id] || []) if @holdings_for_book.present?
    @holdings_for_book = {}
    @holdings.each do |h|
      h.books.keys.each do |bid|
        @holdings_for_book[bid] ||= []
        @holdings_for_book[bid] << h
      end
    end
    holdings_for_book(book_id)
  end
end
