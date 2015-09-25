String.prototype.extract = (pattern)->
	token = @.match(pattern)[0]
	ary = [token,@.minus(token)]
	if ary[1].length is @.length then throw new Error(@,pattern,)
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
  typeof num  is 'number'

isBoolean = (bool)->
  typeof bool is 'boolean'

isQuoted = (str) ->
  typeof str is 'string' and str[0] is '"' and str[str.length - 1] is '"'

extend = (name) ->
  Object.create(name)

sp = (fn) ->
  (fn.__sp__ = true) and fn

Native = 
  #trace:console.log.bind(console)
  trace:(names...)-> console.log(names)
  concat:(str,str2)-> str + str2
  '>' : (a,b)-> a > b
  '<' : (a,b)-> a < b
  '+' : (a,b)-> a + b
  '-' : (a,b)-> a - b
  'def' : sp((name,value) -> @[name] = apply(value,@))
  'do' : sp((args...) -> args.map(((piece)-> apply(piece,@)).bind(@)))
  'if' : sp((cond,succ,fail) -> apply((if apply(cond,@) then succ else fail),@))
  'lambda' : sp((defArgs,body) -> 
    (actArgs...)-> 
      _scope = Object.create(@)
      defArgs.forEach((name,idx)-> _scope[name] = apply(actArgs[idx],_scope))
      apply(body,_scope))

TOKENS = 
	SPACE:/^[\s\n\r]+/
	LEFT_BRACKET:/^\(/
	RIGHT_BRACKET:/^\)/
	STRING:/^".*?"/
	NUMBER:/^\d+(\.\d+)?/
	SYMBOL:/^[a-zA-z_><=\+\-][a-zA-Z_\d\?-]*/

parse = (source,parent,ast)->	
	until	source.length is 0
		switch 
			when source.match(TOKENS.SPACE)
				[_,source] = source.extract(TOKENS.SPACE)
			when source.match(TOKENS.LEFT_BRACKET)
				[_,source] = source.extract(TOKENS.LEFT_BRACKET)
				scope = []
				[source , _] = parse(source,ast,scope)
			when source.match(TOKENS.RIGHT_BRACKET)
				[_,source] = source.extract(TOKENS.RIGHT_BRACKET)
				parent.push(ast)
				return [source,parent]
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
	['',parent]

tokenize = (source)->
	[_,[[symbols]]] = parse(source,[],[])
	symbols


apply = (expression,scope)->
  # resolve string number boolean and variables 
  switch 
    when isNumber(expression) then expression
    when isQuoted(expression) then expression.replace(/^.\|.$/g,'')
    when isBoolean(expression) then expression
    when isString(expression) then scope[expression]
    when isArray(expression)
      [fn,args...] = expression
      fn = if isString(fn) then scope[fn] else fn
      args = if fn.__sp__ then args else args.map((piece)->apply(piece,scope))
      fn.apply(scope,args)
    else throw "unexpected token #{expression}"

# helper to run within Native scope
run = (code) ->
	apply(code,Native)

source = """
(do
	(def max 
		(lambda (x y) 
			(if (> x y) x y)
			)
	)
	(trace 
		(max 100 200)
		)
)
"""

symbols = tokenize(source)
run(symbols)

