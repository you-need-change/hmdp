export function formatDistance(distance) {
  if (distance === null || distance === undefined || distance === '') {
    return ''
  }

  const value = Number(distance)
  if (Number.isNaN(value)) {
    return ''
  }

  if (value < 1000) {
    return `${value.toFixed(1)}m`
  }

  return `${(value / 1000).toFixed(1)}km`
}
