# Frastal - A Fractal Explorer

This project is a simple fractal explorer created in Godot. It displays a Mandelbrot set fractal and allows the user to explore it by panning and zooming.

## Controls

The application has the following controls:

### UI Sliders

- **Max Iterations**: Controls the `iteration_limit` shader parameter, which affects the level of detail.
- **Two**: Controls the `two_in_quotes` shader parameter, which corresponds to the power in the fractal formula (e.g., `z = z^2 + c`).
- **Zoom**: Controls the `zoom` shader parameter. The step of this slider is dynamically adjusted based on the current zoom level to allow for fine-grained control when zoomed in.
- **X**: Controls the x-component of the `position` shader parameter. The step of this slider is dynamically adjusted based on the current zoom level for finer panning control.
- **Y**: Controls the y-component of the `position` shader parameter. The step of this slider is also dynamically adjusted.

### Mouse Controls

- **Right-Click and Drag**: Pans the view.
- **Left-Click and Hold**: Continuously zooms in, centered on the cursor.
- **Mouse Wheel Up/Down**: Zooms in and out, centered on the cursor. The zoom rate is scaled with the current zoom level for a natural, exponential feel.
- **Pinch Gesture**: Zooms in and out on touch devices.

## Coordinate System

The core of the fractal rendering is in the shader, which uses a specific coordinate system to map screen pixels to the complex plane.

The key calculation is for the `uv` coordinate, which represents a point in the fractal's space. The formula is:

```glsl
vec2 uv = ((UV - vec2(0.5)) * vec2(viewport_aspect_ratio, 1)) / zoom + position;
```

Let's break down this formula:

- `UV`: These are the screen texture coordinates, which range from `(0,0)` at the top-left corner to `(1,1)` at the bottom-right.
- `UV - vec2(0.5)`: This centers the coordinates, so they range from `(-0.5, -0.5)` to `(0.5, 0.5)`.
- `* vec2(viewport_aspect_ratio, 1)`: This corrects for the aspect ratio of the viewport. `viewport_aspect_ratio` is calculated as `viewport_width / viewport_height`. This prevents the fractal from appearing stretched.
- `/ zoom`: This is the zoom factor. The `zoom` value is controlled by the UI and input events in `canvas.gd`. The script ensures that the zoom value changes exponentially, which creates a more natural-feeling zoom.
- `+ position`: This adds the `position` vector (`p` in the script), which is controlled by the "X" and "Y" sliders and by panning. This effectively moves the center of the view.

The panning and zooming logic in `canvas.gd` is designed to manipulate the `position` and `zoom` parameters in a way that provides a seamless and intuitive user experience, by ensuring that the `uv` coordinate under the cursor remains constant during these operations.

## Scripts

- **`canvas.gd`**: This is the main script attached to the `Canvas` node. It handles user input (mouse and gestures), updates the shader parameters, and manages the overall state of the application. It implements the logic for exponential zoom and dynamically adjusts the step of the control sliders for a better user experience at different zoom levels.
- **`slider_input.gd`**: This script is attached to the `slider_input.tscn` scene. It provides a reusable slider control with a label and a text input, and it encapsulates the logic for updating the slider's value. It now includes a `set_step` function to allow the main script to dynamically adjust the slider's sensitivity.