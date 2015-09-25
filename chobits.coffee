{run} = require('./evaluator')
{tokenize} = require('./tokenizer')
{os} = require('./os')
source = os.readFile('./sources.scheme').toString()
console.log(source)
symbols = tokenize(source)
run(symbols)


