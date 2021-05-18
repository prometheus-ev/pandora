class Float

  # Like Float#round, except that .5 rounds down.
  def round_hd
    self % 1 == 0.5 ? round + (self < 0 ? 1 : -1) : round
  end

end
