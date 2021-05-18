class Pandora::Collection
  def initialize(items, total, page, per_page = 10)
    @items = items
    @total = total
    @page = page
    @per_page = per_page
  end

  def pager
    self
  end

  def items
    @items
  end

  def each(&block)
    @items.each(&block)
  end

  def map(&block)
    @items.map(&block)
  end

  def empty?
    @items.empty?
  end

  def item_count
    @items.count
  end

  def count
    @total
  end

  def number_of_pages
    (@total.to_f / @per_page).ceil
  end

  def offset
    @per_page * (@page - 1)
  end

  def first_item_number
    offset + 1
  end

  def last_item_number
    offset + item_count
  end

  def order!(column, direction = 'asc')
    @items.sort_by! do |i|
      m = column.to_sym
      i.respond_to?(m) ? i.send(column.to_sym).to_s : ''
    end
    if direction.present? && direction.downcase != 'asc'
      @items.reverse!
    end
  end

  def pageit!(page, per_page = 10)
    from = (page - 1) * per_page
    to = page * per_page - 1
    @items = @items[from..to] || []
  end
end
