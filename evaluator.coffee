{mixin,Core} = require('./core')

isArray = (ary) ->
  ary instanceof Array

isString = (str) ->
  typeof str is 'string'

isNumber = (num) ->
  typeof num is 'number'

isBoolean = (bool)->
  typeof bool is 'boolean'

isQuoted = (str) ->
  typeof str is 'string' and str[0] is '"' and str[str.length - 1] is '"'

isList = (lst)->
  isArray(lst) and lst.__list__

isUndefined = (x) ->
  x is undefined

isFunction =(fn)->
  typeof fn is "function"

sp = (fn) ->
  (fn.__sp__ = true) and fn

list = (list) ->
  (list.__list__ = true) and list

Native =
  trace: (names...)-> console.log(names)
  concat: (str, str2)-> str + str2
  '>': (a, b)-> a > b
  '<': (a, b)-> a < b
  '+': (a, b)-> a + b
  '-': (a, b)-> a - b
  '*': (a, b)-> a * b
  '/': (a, b)-> a / b
  'eq': (a, b) -> a is b
  'def': sp((name, value) -> @[name] = apply(value, @))
  'do': sp((args...) ->
    args.map(((piece)-> apply(piece, @)).bind(@)))
  'if': sp((cond, succ, fail) -> apply((if apply(cond, @) then succ else fail), @))
  'cond':sp((seq...) ->
    until seq.length == 0
      [cond,expression] = seq.shift()
      if apply(cond,@) then return apply(expression,@))
  'lambda': sp((defArgs, bodies...) ->
    (actArgs...)->
      _scope = Object.create(@)
      defArgs.forEach((name, idx)-> _scope[name] = apply(actArgs[idx], _scope))
      bodies.reduce(((prev,body) -> apply(body,_scope)),null))
  'cons': (head, ary) -> list([head, ary])
  'car': (list)->
    [head,_] = list
    head
  'cdr': (list)->
    [_,tail] = list
    tail

mixin(Native,Core)

apply = (expression, scope)->
# resolve string number boolean and variables
  switch
    when expression is 'nil' then list([])
    when isNumber(expression) then expression
    when isList(expression) then expression
    when isBoolean(expression) then expression
    when isFunction(expression) then expression
    when isQuoted(expression) then expression.replace(/^.\|.$/g, '')
    when isString(expression) then scope[expression]
    when isArray(expression)
      [fn,args...] = expression
      fn = if isString(fn) then scope[fn] else (if isArray(fn) then apply(fn,scope) else fn)
      args = if fn.__sp__ then args else args.map((piece)-> apply(piece, scope))
      fn.apply(scope, args)
    when isUndefined(expression) then undefined
    else
      throw "unexpected expression #{expression}"


# helper to run within Native scope
run = (code) ->
  apply(code, Native)


module.exports = {run}
