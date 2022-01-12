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
content-length: 2
content-type: application/json; charset=utf-8
date: Wed, 12 Jan 2022 15:42:44 GMT
server: Cowboy
x-request-id: FsmQRMTPLICUU3oAAANE

[]
```

## Creating a canvas

By sending a json payload with width and height using `POST /canvases` you will create a new canvas.
`width` and `height` must be integer values between 1 and 50 (for this example).

Returns HTTP 201 with a json containing the canvas id.

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

{"id":"79d70753-052a-4239-9b32-fdbba09af1d1"}
```
