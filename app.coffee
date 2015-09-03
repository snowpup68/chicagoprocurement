restify = require 'restify'
mongojs = require 'mongojs'
request = require 'request'
unzip   = require 'unzip'
split   = require 'split'

db = mongojs 'currency', ['rates']

server = restify.createServer()

count = 0
header = null

process_line = (line) ->
    row = line.split ','
    row.pop() # remove empty last element created by trailing comma
    rate_date = row.shift()

    if !header?
        header = row
    else
        bulk = db.rates.initializeUnorderedBulkOp()
        bulk.insert {rate_date: rate_date, symbol: header[i], rate: rate} for rate, i in row when isFinite(rate)
        bulk.execute (err, result) -> count += result.nInserted


currency_update = (req, res, next) -> 
        url = 'https://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist.zip?' + process.hrtime();

        db.rates.drop (err, reply) ->
            count = 0
            request(url)
                .pipe unzip.Parse()
                .on 'entry', (file) ->
                    file.pipe split()
                    .on 'data', process_line
                    .on 'end', ->
                        res.setHeader 'Content-Type', 'application/json'
                        res.send 'Count = ' + count


currency_rate = (req, res, next) ->
    db.rates.find({symbol: req.params.symbol}, {_id: 0, rate_date: 1, rate: 1}, (err, result) ->
        res.setHeader 'Content-Type', 'application/json'
        res.send result
    )


currency_list = (req, res, next) ->
    db.rates.distinct("symbol", {}, (err, result) ->
        res.setHeader 'Content-Type', 'application/json'

        res.send result
    )



server.get '/currency', currency_list
server.get '/currency/list', currency_list
server.get '/currency/update', currency_update
server.get '/currency/rate/:symbol', currency_rate

server.listen 8081, ->
    console.log '%s listening at %s', server.name, server.url

