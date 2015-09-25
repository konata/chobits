String.prototype.extract = (pattern)->
  token = @.match(pattern)[0]
  ary = [token, @.minus(token)]
  if ary[1].length is @.length then throw new Error(@, pattern,)
  ary

String.prototype.minus = (sub) ->
  if sub is null or sub.length is 0 then return @
  len = sub.length
  if @[0...len] is sub then @[len...] else throw new Error(" NOT MATCH " + sub + "  :  " + @)

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


extend = (name) ->
  Object.create(name)

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
  'do': sp((args...) -> args.map(((piece)-> apply(piece, @)).bind(@)))
  'if': sp((cond, succ, fail) -> apply((if apply(cond, @) then succ else fail), @))
  'lambda': sp((defArgs, body) ->
    (actArgs...)->
      _scope = Object.create(@)
      defArgs.forEach((name, idx)-> _scope[name] = apply(actArgs[idx], _scope))
      apply(body, _scope))
  'cons': (head, ary) -> list([head, ary])
  'car': (list)->
    [head,_] = list
    head
  'cdr': (list)->
    [_,tail] = list
    tail

TOKENS =
  SPACE: /^[\s\n\r]+/
  LEFT_BRACKET: /^\(/
  RIGHT_BRACKET: /^\)/
  STRING: /^".*?"/
  COMMENT: /^;.*\D/
  NUMBER: /^\d+(\.\d+)?/
  SYMBOL: /^[a-zA-z_><=\+\-\*\/][a-zA-Z_\d\?-]*/

parse = (source, parent, ast)->
  until  source.length is 0
    switch
      when source.match(TOKENS.SPACE)
        [_,source] = source.extract(TOKENS.SPACE)
      when source.match(TOKENS.COMMENT)
        [_,source] = source.extract(TOKENS.COMMENT)
      when source.match(TOKENS.LEFT_BRACKET)
        [_,source] = source.extract(TOKENS.LEFT_BRACKET)
        scope = []
        [source , _] = parse(source, ast, scope)
      when source.match(TOKENS.RIGHT_BRACKET)
        [_,source] = source.extract(TOKENS.RIGHT_BRACKET)
        parent.push(ast)
        return [source, parent]
      when source.match(TOKENS.STRING)
        [str,source] = source.extract(TOKENS.STRING)
        ast.push('"' + str + '"')
      when source.match(TOKENS.NUMBER)
        [digital,source] = source.extract(TOKENS.NUMBER)
        ast.push(Number(digital))
      when source.match(TOKENS.SYMBOL)
        [sym,source] = source.extract(TOKENS.SYMBOL)
        ast.push(sym)
      else
        throw new Error("INVALID TOKEN" + source)
  parent.push(ast)
  ['', parent]

tokenize = (source)->
  [_,[[symbols]]] = parse(source, [], [])
  symbols


apply = (expression, scope)->
# resolve string number boolean and variables
  switch
    when expression is 'nil' then list([])
    when isNumber(expression) then expression
    when isList(expression) then expression
    when isBoolean(expression) then expression
    when isQuoted(expression) then expression.replace(/^.\|.$/g, '')
    when isString(expression) then scope[expression]
    when isArray(expression)
      [fn,args...] = expression
      fn = if isString(fn) then scope[fn] else fn
      args = if fn.__sp__ then args else args.map((piece)-> apply(piece, scope))
      fn.apply(scope, args)
    else
      throw "unexpected token #{expression}"

# helper to run within Native scope
run = (code) ->
  apply(code, Native)


# below test cases

source = """
(do
  ;; normal function defination
  (def max
		(lambda (x y) 
			(if (> x y) x y)
			))
  (trace
		(max 100 200)
		)

  ;; list operations
  (def cddr
    (lambda (list)
      (cdr (cdr list))
    )
  )

  (def cdddr
    (lambda (list)
      (cdr (cddr list))))

  (def cddddr
    (lambda (list)
      (cdr (cdddr list))))

  (def cdar
    (lambda (list)
      (car (cdr list))))

  (def names (cons 100 (cons 200 (cons 300 (cons 400 nil)))))
  (trace names)
  (trace (cddddr names))
  (trace (cdar names))

  ;; recursive function defination
  (def fact (lambda (x)
    (if (< x 1) 1 (* x (fact (- x 1))))))
  (trace (fact 10))

  ;; hanoi
  (def hanoi (lambda (remain left middle right)
    (if (eq remain 1)
      (trace left "->" right)
      (do
        (hanoi (- remain 1) left right middle)
        (trace left "->" right)
        (hanoi (- remain 1) middle left right)
      ))))
  (hanoi 3 "left" "middle" "right")
)
"""

symbols = tokenize(source)
run(symbols)



