// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

/// Configures media acquisition to use fake devices instead of actual camera
/// and microphone.
///
/// This must be called before any other function to work properly.
/// This function is async for identical function signature.
Future<void> enableFakeMedia() async {
  web.window.callMethod(
    'eval'.toJS,
    // language=JavaScript
    '''
    /** Stops the canvas stream. */
    function _stop_canvas_stream(stream, meta) {
        return () => {
            window.clearInterval(meta.interval)
            const tracks = stream.getTracks()
            tracks.forEach(track => {
                track.stop()
            })
            if (stream.stop) {
                stream.stop = undefined
            }
        }
    }

    /** Starts drawing random rectangles on the canvas. */
    function _drawer_canvas(canvas) {
        const FPS = 2
        const ms = 1000 / FPS
        const getRandom = (max) => {
            return Math.floor(Math.random() * max)
        }
        const handle = () => {
            const ctx = canvas.getContext('2d')

            const x = 0
            const y = 0
            const width = getRandom(canvas.width)
            const height = getRandom(canvas.height)

            const r = getRandom(255)
            const g = getRandom(255)
            const b = getRandom(255)

            ctx.fillStyle = `rgb(\${r},\${g},\${b})`

            ctx.fillRect(x, y, width, height)

        }
        const interval = window.setInterval(handle, ms)

        handle()

        return {
            canvas: canvas,
            interval: interval
        }
    }

    /** Returns mock media stream provided constraints. */
    function _get_mock_stream(constraints) {
        let res = new MediaStream()

        if (constraints['video']) {
            let vstream = _mock_canvas_stream(constraints);
            const tracks = vstream.getTracks()
            tracks.forEach(track => {
                res.addTrack(track)
            })
        }

        if (constraints['audio']) {

            const ac = new AudioContext();
            const oscillator = ac.createOscillator();
            oscillator.type = 'square';
            oscillator.frequency.setValueAtTime(440, ac.currentTime);
            oscillator.connect(ac.destination);
            oscillator.start();

            const dest = ac.createMediaStreamDestination();
            let astream = dest.stream;

            const tracks = astream.getTracks()
            tracks.forEach(track => {
                res.addTrack(track)
            })
        }
        return Promise.resolve(res)
    }

    /** Returns canvas video stream provided constraints. */
    function _mock_canvas_stream(constraints) {
        const canvas = document.createElement('canvas')

        let constraints_width = constraints['video']['width']
        canvas.width = constraints_width == undefined ? 640 : constraints_width

        let constraints_height = constraints['video']['height']
        canvas.height = constraints_height == undefined ? 480 : constraints_height

        const meta = _drawer_canvas(canvas)

        let constraints_fps = constraints['video']['frameRate']
        const stream = canvas.captureStream(constraints_fps == undefined ? 20 : constraints_fps)

        stream.stop = _stop_canvas_stream(stream, meta)
        return stream
    }

    /** Enables mock `getUserMedia` function. */
    function enableMock() {
        navigator.mediaDevices.getUserMedia = (constraints) => {
            return _get_mock_stream(constraints)
        }
        navigator.mediaDevices.getDisplayMedia = (constraints) => {
            return _get_mock_stream(constraints)
        }
    }
    enableMock();
  '''.toJS,
  );
}
