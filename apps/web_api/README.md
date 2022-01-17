# AC.WebApi

## Running the app

There is a `run.sh` script that starts up the app and makes the api available on http://localhost:4000/

There is also a `bless` alias that should be used before every commit which checks for warnings in source code,
checks formatting, runs all tests and calculates coverage and runs dialyzer to verify all type specs.

## Listing all canvases

By invoking `GET /canvases` you will receive a list of all canvas entities.
Returns HTTP 200 and a list of canvases.

Example using `curl`:

```
curl -X GET -i http://localhost:4000/canvases

HTTP/1.1 200 OK
cache-control: max-age=0, private, must-revalidate
content-length: 1542
content-type: application/json; charset=utf-8
date: Fri, 14 Jan 2022 00:06:40 GMT
server: Cowboy
x-request-id: Fsn6WTbPkfiyfGAAAANB

[{"content":{"0":{"0":null,"1":null,"2":null,"3":null,"4":null,"5":null,"6":null,"7":null,"8":null,"9":null,"10":null,"11":null,"12":null,"13":null,"14":null},"1":{"0":null,"1":null,"2":null,"3":null,"4":null,"5":null,"6":null,"7":null,"8":null,"9":null,"10":null,"11":null,"12":null,"13":null,"14":null},"2":{"0":null,"1":null,"2":null,"3":null,"4":null,"5":null,"6":null,"7":null,"8":null,"9":null,"10":null,"11":null,"12":null,"13":null,"14":null},"3":{"0":null,"1":null,"2":null,"3":null,"4":null,"5":null,"6":null,"7":null,"8":null,"9":null,"10":null,"11":null,"12":null,"13":null,"14":null},"4":{"0":null,"1":null,"2":null,"3":null,"4":null,"5":null,"6":null,"7":null,"8":null,"9":null,"10":null,"11":null,"12":null,"13":null,"14":null},"5":{"0":null,"1":null,"2":null,"3":null,"4":null,"5":null,"6":null,"7":null,"8":null,"9":null,"10":null,"11":null,"12":null,"13":null,"14":null},"6":{"0":null,"1":null,"2":null,"3":null,"4":null,"5":null,"6":null,"7":null,"8":null,"9":null,"10":null,"11":null,"12":null,"13":null,"14":null},"7":{"0":null,"1":null,"2":null,"3":null,"4":null,"5":null,"6":null,"7":null,"8":null,"9":null,"10":null,"11":null,"12":null,"13":null,"14":null},"8":{"0":null,"1":null,"2":null,"3":null,"4":null,"5":null,"6":null,"7":null,"8":null,"9":null,"10":null,"11":null,"12":null,"13":null,"14":null},"9":{"0":null,"1":null,"2":null,"3":null,"4":null,"5":null,"6":null,"7":null,"8":null,"9":null,"10":null,"11":null,"12":null,"13":null,"14":null}},"height":15,"id":"b3014e9c-415d-4b29-b532-ea00160c230b","width":10}]
```

## Showing a canvas

By invoking `GET /canvases/:id` you will receive a json of a single canvas
with its content.
Returns HTTP 200 and a canvas json.

Example using `curl`:

```
curl -X GET -i http://localhost:4000/canvases/b3014e9c-415d-4b29-b532-ea00160c230b

HTTP/1.1 200 OK
cache-control: max-age=0, private, must-revalidate
content-length: 1540
content-type: application/json; charset=utf-8
date: Fri, 14 Jan 2022 00:05:59 GMT
server: Cowboy
x-request-id: Fsn6UAuWfmhVSOMAAAOj

{"content":{"0":{"0":null,"1":null,"2":null,"3":null,"4":null,"5":null,"6":null,"7":null,"8":null,"9":null,"10":null,"11":null,"12":null,"13":null,"14":null},"1":{"0":null,"1":null,"2":null,"3":null,"4":null,"5":null,"6":null,"7":null,"8":null,"9":null,"10":null,"11":null,"12":null,"13":null,"14":null},"2":{"0":null,"1":null,"2":null,"3":null,"4":null,"5":null,"6":null,"7":null,"8":null,"9":null,"10":null,"11":null,"12":null,"13":null,"14":null},"3":{"0":null,"1":null,"2":null,"3":null,"4":null,"5":null,"6":null,"7":null,"8":null,"9":null,"10":null,"11":null,"12":null,"13":null,"14":null},"4":{"0":null,"1":null,"2":null,"3":null,"4":null,"5":null,"6":null,"7":null,"8":null,"9":null,"10":null,"11":null,"12":null,"13":null,"14":null},"5":{"0":null,"1":null,"2":null,"3":null,"4":null,"5":null,"6":null,"7":null,"8":null,"9":null,"10":null,"11":null,"12":null,"13":null,"14":null},"6":{"0":null,"1":null,"2":null,"3":null,"4":null,"5":null,"6":null,"7":null,"8":null,"9":null,"10":null,"11":null,"12":null,"13":null,"14":null},"7":{"0":null,"1":null,"2":null,"3":null,"4":null,"5":null,"6":null,"7":null,"8":null,"9":null,"10":null,"11":null,"12":null,"13":null,"14":null},"8":{"0":null,"1":null,"2":null,"3":null,"4":null,"5":null,"6":null,"7":null,"8":null,"9":null,"10":null,"11":null,"12":null,"13":null,"14":null},"9":{"0":null,"1":null,"2":null,"3":null,"4":null,"5":null,"6":null,"7":null,"8":null,"9":null,"10":null,"11":null,"12":null,"13":null,"14":null}},"height":15,"id":"b3014e9c-415d-4b29-b532-ea00160c230b","width":10}
```

## Creating a canvas

By sending a json payload with width and height using `POST /canvases` you will create a new canvas.
`width` and `height` must be integer values between 1 and 50 (for this example).

Example of a valid json:
```
{
  "width": 10,
  "height": 15
}
```

Returns HTTP 201 with a json containing the canvas id if the canvas has been created successfully.

Example using `curl`:
```
curl -X POST -i -H "Content-Type: application/json" -d "{\"width\": 10, \"height\": 15}" http://localhost:4000/canvases

HTTP/1.1 201 Created
cache-control: max-age=0, private, must-revalidate
content-length: 45
content-type: application/json; charset=utf-8
date: Wed, 12 Jan 2022 16:04:37 GMT
server: Cowboy
x-request-id: FsmRdpD8MoBfdxMAAASh

{"id":"52617b12-3cfc-48b8-98de-994267f2e5f4"}
```

If there were validation errors while validating the request HTTP 422 with a json containing validation
errors is returned.

Example using `curl`:
```
curl -X POST -i -H "Content-Type: application/json" -d "{\"width\": 0, \"height\": 53}" http://localhost:4000/canvases

HTTP/1.1 422 Unprocessable Entity
cache-control: max-age=0, private, must-revalidate
content-length: 82
content-type: application/json; charset=utf-8
date: Thu, 13 Jan 2022 22:19:05 GMT
server: Cowboy
x-request-id: Fsn0elzTM0jlOcoAAAQD

{"height":["must be less than or equal to 50"],"width":["must be greater than 0"]}
```

## Deleting a canvas

You can delete a canvas by calling `DELETE /canvases/:id` where `:id` is the identifier
of the canvas received on a successful create request.

Returns HTTP 204 with no content if a canvas exists for the given id.

Example using `curl`:
```
curl -X DELETE -i http://localhost:4000/canvases/52617b12-3cfc-48b8-98de-994267f2e5f4

HTTP/1.1 204 No Content
cache-control: max-age=0, private, must-revalidate
date: Thu, 13 Jan 2022 22:22:10 GMT
server: Cowboy
x-request-id: Fsn0pZYu91CQVRwAAAXC
```

If the canvas for the given id doesn't exist, returns HTTP 404 with no content.

Example using `curl`, with the id already deleted:
```
curl -X DELETE -i http://localhost:4000/canvases/52617b12-3cfc-48b8-98de-994267f2e5f4

HTTP/1.1 404 Not Found
cache-control: max-age=0, private, must-revalidate
content-length: 0
date: Thu, 13 Jan 2022 22:25:11 GMT
server: Cowboy
x-request-id: Fsn0z8Obg8gHjRUAAAXi
```

If the given canvas id is not a valid unique identifier, HTTP 422 is received with
a json containing validation errors.

Example with `curl`:
```
curl -X DELETE -i http://localhost:4000/canvases/non-unique-identifier

HTTP/1.1 422 Unprocessable Entity
cache-control: max-age=0, private, must-revalidate
content-length: 21
content-type: application/json; charset=utf-8
date: Thu, 13 Jan 2022 22:27:07 GMT
server: Cowboy
x-request-id: Fsn06unZcng_essAAAYC

{"id":["is invalid"]}
```

## Drawing a rectangle

The request to draw a rectangle must be performed on a valid canvas, meaning an
existing canvas id should be supplied in the path of the request.

Here is an example of a valid json request:
```
{
  "upper_left_corner": [3,4],
  "width": 5,
  "height": 7,
  "outline": "X",
  "fill": "@"
}
```

`upper_left_corner` is a list of exactly 2 integers (x,y) and represents the coordinates of the upper left corner of the rectangle
to be drawn. Values of x and y are zero-based and limited by and validated against canvas width and height.

`width` and `height` are integers and respresent width and height of the rectangle. They are validated against `upper_left_corner`
and canvas width and height, so if canvas size is 5 x 5, and `upper_left_corner` are [3,3], `width` and `height` can have a
maximum value of 2 each.

`outline` and `fill` can only be an ASCII encoded byte and are optional, but at least one must be present.

Example with `curl`:
```
curl -X PUT -i -H "Content-Type: application/json" \
  -d "{\"upper_left_corner\":[3,2],\"fill\":\"X\",\"height\":3,\"outline\":\"@\",\"width\":5}" \
  http://localhost:4000/canvases/ee4b507d-1fc0-4717-829c-f98af852201b/draw_rectangle

HTTP/1.1 204 No Content
cache-control: max-age=0, private, must-revalidate
date: Sat, 15 Jan 2022 15:29:34 GMT
server: Cowboy
x-request-id: Fsp7SrVydohuULoAAAAC
```

## Flood filling a rectangle

To flood fill a canvas with a fill character you need to supply the `start_coordinates` which must not be inside a rectangle,
and a `fill` character which must be a valid ASCII encoded byte.
Existing canvas id must be supplied in the path of the request.

Example with `curl`:
```
curl -X PUT -i -H "Content-Type: application/json" \
  -d "{\"start_coordinates\":[0, 0],\"fill\":\"-\"}" \
  http://localhost:4000/canvases/ec31652b-afd1-45ea-9883-af9fe20f1bae/flood_fill

HTTP/1.1 204 No Content
cache-control: max-age=0, private, must-revalidate
date: Mon, 17 Jan 2022 19:18:33 GMT
server: Cowboy
x-request-id: Fssk8q0zcrxVSOMAAATD
```

As with previous requests, if any of required parameters are invalid or not supplied, an HTTP 422 response will be returned
with a json containing the validation errors.


## Complete example per requirements

### Test fixture 3

- Rectangle at `[14, 0]` with width `7`, height `6`, outline character: none, fill: `.`
- Rectangle at `[0, 3]` with width `8`, height `4`, outline character: `O`, fill: `none`
- Rectangle at `[5, 5]` with width `5`, height `3`, outline character: `X`, fill: `X`
- Flood fill at `[0, 0]` with fill character `-` (canvas presented in 21x8 size)

```
--------------.......
--------------.......
--------------.......
OOOOOOOO------.......
O      O------.......
O    XXXXX----.......
OOOOOXXXXX-----------
     XXXXX-----------
```

### How to reproduce

Create canvas 21x8
```
curl -X POST -i -H "Content-Type: application/json" -d "{\"width\": 21, \"height\": 8}" http://localhost:4000/canvases

HTTP/1.1 201 Created
cache-control: max-age=0, private, must-revalidate
content-length: 45
content-type: application/json; charset=utf-8
date: Mon, 17 Jan 2022 19:12:39 GMT
server: Cowboy
x-request-id: FsskoFV_DbgpobAAAAQD

{"id":"ec31652b-afd1-45ea-9883-af9fe20f1bae"}
```

Draw first rectangle:
```
curl -X PUT -i -H "Content-Type: application/json" \
  -d "{\"upper_left_corner\":[14,0],\"fill\":\".\",\"height\":6,\"outline\":null,\"width\":7}" \
  http://localhost:4000/canvases/ec31652b-afd1-45ea-9883-af9fe20f1bae/draw_rectangle

HTTP/1.1 204 No Content
cache-control: max-age=0, private, must-revalidate
date: Mon, 17 Jan 2022 19:17:03 GMT
server: Cowboy
x-request-id: Fssk3cbWQQ2fDvIAAAQj
```

Draw second rectangle:
```
curl -X PUT -i -H "Content-Type: application/json" \
  -d "{\"upper_left_corner\":[0, 3],\"fill\":null,\"height\":4,\"outline\":\"O\",\"width\":8}" \
  http://localhost:4000/canvases/ec31652b-afd1-45ea-9883-af9fe20f1bae/draw_rectangle

HTTP/1.1 204 No Content
cache-control: max-age=0, private, must-revalidate
date: Mon, 17 Jan 2022 19:17:11 GMT
server: Cowboy
x-request-id: Fssk34drTpcCGywAAARD
```

Draw third rectangle:
```
curl -X PUT -i -H "Content-Type: application/json" \
  -d "{\"upper_left_corner\":[5, 5],\"fill\":\"X\",\"height\":3,\"outline\":\"X\",\"width\":5}" \
  http://localhost:4000/canvases/ec31652b-afd1-45ea-9883-af9fe20f1bae/draw_rectangle

HTTP/1.1 204 No Content
cache-control: max-age=0, private, must-revalidate
date: Mon, 17 Jan 2022 19:17:18 GMT
server: Cowboy
x-request-id: Fssk4UtXkblXXg0AAARj
```

Flood fill starting from [0, 0]:
```
curl -X PUT -i -H "Content-Type: application/json" \
  -d "{\"start_coordinates\":[0, 0],\"fill\":\"-\"}" \
  http://localhost:4000/canvases/ec31652b-afd1-45ea-9883-af9fe20f1bae/flood_fill

HTTP/1.1 204 No Content
cache-control: max-age=0, private, must-revalidate
date: Mon, 17 Jan 2022 19:18:33 GMT
server: Cowboy
x-request-id: Fssk8q0zcrxVSOMAAATD
```

Get the content of the canvas:
```
curl -X GET -i http://localhost:4000/canvases/ec31652b-afd1-45ea-9883-af9fe20f1bae

HTTP/1.1 200 OK
cache-control: max-age=0, private, must-revalidate
content-length: 262
content-type: application/json; charset=utf-8
date: Mon, 17 Jan 2022 19:30:11 GMT
server: Cowboy
x-request-id: FssllTKjDpbQsxgAAAUD

{"content":"--------------.......\n--------------.......\n--------------.......\nOOOOOOOO------.......\nO      O------.......\nO    XXXXX----.......\nOOOOOXXXXX-----------\n     XXXXX-----------","height":8,"id":"ec31652b-afd1-45ea-9883-af9fe20f1bae","width":21}
```

Then you can copy the string from "content", save it to a file (without initial and trailing quotes) and in the terminal (macOS) run `echo -e "$(cat <file_name>)"`,
or you could just paste the content directly into an `echo` command:
`echo -e "--------------.......\n--------------.......\n--------------.......\nOOOOOOOO------.......\nO      O------.......\nO    XXXXX----.......\nOOOOOXXXXX-----------\n     XXXXX-----------"`
