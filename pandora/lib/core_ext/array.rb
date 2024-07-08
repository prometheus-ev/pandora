class Array
  def sort_by_first
    sort_by{|first, *| block_given? ? yield(first) : first}
  end

  alias_method :sort_by_key, :sort_by_first
end
