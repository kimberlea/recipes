Dishfave.utils.getRatingExpression = (val, opts)->
  return null if !val?
  ret = {}
  if val > 87.5
    icon = "kai kai-face-happy"
    textSelf = "I loved it!"
    textAll = "Most people love it!"
  else if val > 62.5
    icon = "kai kai-face-smile"
    textSelf = "I liked it!"
    textAll = "Most people like it."
  else if val > 37.5
    icon = "kai kai-face-neutral"
    textSelf = "It was ok."
    textAll = "Most people think it's ok."
  else if val > 12.5
    icon = "kai kai-face-mad"
    textSelf = "I didn't like it."
    textAll = "Most people don't like it."

  return {icon: icon, textSelf: textSelf, textAll: textAll}
