{run} = require('./evaluator')
{tokenize} = require('./tokenizer')
{os} = require('./os')
source = os.readFile('./sources.scheme').toString()
symbols = tokenize(source)
run(symbols)


