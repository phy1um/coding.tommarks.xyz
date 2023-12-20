
class GFXManager {
  constructor(canvas) {
    this._resources = {};
    this._next_resource_id = 9990;
    this._canvas = canvas;
    this._ctx = canvas.getContext("2d");
    this._bound = -1;
  }

  load_image(path) {
    const out = this._next_resource_id++;
    fetch(path)
    .then(r => r.blob())
    .then(data => {
      createImageBitmap(data).then(b => this._resources[out] = b).catch(console.error);
    })
    .catch(e => console.error(e));
    return out;
  }

  bind_resource(idx) {
    this._bound = idx;
  }

  fill_colour(r, g, b, a)  {
    this._ctx.fillStyle = `rgba(${r}, ${g}, ${b}, ${a})`;
  }

  stroke_colour(r,g,b,a) {
    throw Error("unimplemented");
  }

  fill_rect(x,y,w,h) {
    this._ctx.fillRect(x,y,w,h);
  }

  stroke_rect(x,y,w,h) {
    throw Error("unimplemented");
  }

  sprite(x,y,w,h,sx,sy,sw,sh) {
    const img = this._resources[this._bound];
    if (!img) {
      console.error(`attempting to draw invalid image: ${this._bound}`);
      return;
    }
    this._ctx.drawImage(img,
      sx,sy,sw,sh,
      x,y,w,h);

  }

  draw_text(x, y, size, msg) {
    this._ctx.font = `bold ${size}px sans`;
    this._ctx.fillText(msg, x, y);
  }

  clear() {
    this._ctx.fillStyle = "#000";
    this._ctx.fillRect(0,0,this._canvas.width,this._canvas.height);
  }

};


