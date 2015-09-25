Core =
  'nil?':(x)-> x.length == 0 and x.__list__

mixin = (base,features)->
  for own key,val of features
    base[key] = val


module.exports = {mixin,Core}
