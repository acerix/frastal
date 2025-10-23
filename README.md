# MandelDance
Godot example project to display a single fragment shader in full screen so it runs on all pixels of the display.

The example fragment shader renders the Mandelbrot set, framed around the "Buddhabrot" figure at the centre, and animated using GDScript.

The zoom and position of the plane are varied over time using trigonometric functions to make the movements oscillate. The frequencies of the oscillations are harmonically related to a tempo of 140 BPM so that when music of this tempo is playing, the figure's movements appear to match the beat. The number 2 in the Mandelbrot function is also varied, morphing the Mandelbrot set into analogues, so as to mimick the creation mechananism of the Universe. 

# Demo
[Web (HTML5) Export](https://acerix.github.io/MandelDance/) (requires WebGL)

# Use in Godot Editor
Download this repo and open [project.godot](project/project.godot) in [Godot Editor](https://godotengine.org/download/).

```bash
git clone https://github.com/acerix/MandelDance.git
godot ./MandelDance/project/project.godot
```

# Screenshot
![Screenshot of the initial rendering of MandelDance](project/screenshot.png?raw=true "Initial rendering of MandelDance")
