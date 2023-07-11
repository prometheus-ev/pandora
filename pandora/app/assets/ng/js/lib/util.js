const sortBy = (array, f) => {
  return [...array].sort((a, b) => {
    const af = f(a)
    const bf = f(b)

    if (af > bf) return 1
    if (af < bf) return -1

    return 0
  })
}

export {
  sortBy
}
