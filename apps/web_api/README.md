# ACWebApi

## Running the app

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
existing canvas id should be supplied in the uri.

Here is an example of a valid json request:
```
{
  "coords": [3,4],
  "width": 5,
  "height": 7,
  "outline": "X",
  "fill": "@"
}
```

`coords` is a list of exactly 2 integers (x,y) and represents the coordinates of the upper left corner of the rectangle
to be drawn. Values of x and y are zero-based and limited by and validated against canvas width and height.

`width` and `height` are integers and respresent width and height of the rectangle. They are validated against `coords`
and canvas width and height, so if canvas size is 5 x 5, and `coords` are [3,3], `width` and `height` can have a
maximum value of 2 each.

`outline` and `fill` can only be an ASCII encoded byte and are optional, but at least one must be present.
