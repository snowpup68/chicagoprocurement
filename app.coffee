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
        header[0] = 'EUR'
    else
        bulk = db.rates.initializeOrderedBulkOp()
        base = row[0]
        row[0] = 1
        for rate, i in row when isFinite(rate)
            symbol = header[i]
            rate = rate / base
            bulk.insert {rate_date, symbol, rate}
            count++

        bulk.execute (err, res) ->


currency_update = (req, res, next) -> 
        url = 'https://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist.zip?' + process.hrtime();

        db.rates.drop (err, reply) ->
            count = 0
            #fs = require 'fs'
            #fs.createReadStream('./data/eurofxref-hist.zip')
            request(url)
                .pipe unzip.Parse()
                .on 'entry', (file) ->
                    file.pipe split()
                    .on 'data', process_line
                    .on 'end', ->
                        res.setHeader 'Content-Type', 'application/json'
                        res.send 'Count = ' + count

        next()

server.get '/currency/update', currency_update

server.listen 8081, ->
    console.log '%s listening at %s', server.name, server.url

