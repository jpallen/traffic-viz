Use d3.js to visualize traffic through haproxy

Usage:

```
npm install
grunt build
cat haproxy_sample.log | grep -v 127.0.0.1 | grep doc | coffee filters/haproxy.coffee | coffee app/server/index.coffee
```

Make sure to add in some greps to filter the raw haproxy log, otherwise you're going to get a LOT of data.

Change the visualization format with the query string. For example:

```
http://localhost:8000/?layout=columns&group1=/
```

Will group nodes into columns, with the second group (indexed from 0, so specified by `group1`)
made up of all nodes which match the regex '/'. Any regexs can be passed as options to `groupX`.

Available layout options: `row`, `column`, `circular` (default if nothing else specified).
