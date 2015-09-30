Core =
  'nil?':(x)-> x.length == 0 and x.__list__
  'trace':(x...) -> x.forEach((item)-> if item isnt undefined and item.__list__ then console.log("list: " + item.join(" ")) else console.log(item))

mixin = (base,features)->
  for own key,val of features
    base[key] = val




module.exports = {mixin,Core}
