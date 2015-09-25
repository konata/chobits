String.prototype.extract = (pattern)->
  token = @.match(pattern)[0]
  ary = [token, @.minus(token)]
  if ary[1].length is @.length then throw new Error(@, pattern,)
  ary

String.prototype.minus = (sub) ->
  if sub is null or sub.length is 0 then return @
  len = sub.length
  if @[0...len] is sub then @[len...] else throw new Error(" NOT MATCH " + sub + "  :  " + @)

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

module.exports = {tokenize}
