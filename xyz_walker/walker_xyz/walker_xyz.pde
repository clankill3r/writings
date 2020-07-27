import peasy.*;

/*

Sunday codings

This originated from the problem that noise was repeating itself.
I was wondering what a way could be to avoid repeating.

This was more tricky then I thought.

Eventualy I thought of stepping threw a noise field in such a way that you can take a lot of steps before going out of the "bounding".

I avoided the hilbert curve, cause it seemed to expensive.


The firts one I did was:

 walk(int n, Walk_Action action)

 Which is using a lambda. Downside is that I can not watch values in the debugger when using the lambda. While I could redirect the method call, I thought of trying to do another implementation as well:


walk(XYZ_Walker w)

Which worked great.

Then I wondered if I could do it like how you convert a pixel to a xy position and the other way around:

walker_index_to_xyz(int i, int x_steps, int y_steps)


TODO 

walker_xyz_to_index
 
 
 */



XYZ_Walker w = new XYZ_Walker(4, 4);

PeasyCam cam;


void settings() {
  size(800, 800, P3D);
}


void setup() {
  cam = new PeasyCam(this, 100);

  for (int i = 0; i < 64; i++) {
    var v = new PVector(w.x, w.y, w.z);
    v.mult(10);
    points.add(v);

    int[] xyz = walker_index_to_xyz(i, 4, 4);
    println(xyz[0], xyz[1], xyz[2]+"     ", w.x, w.y, w.z);

    if ((i+1) % 4 == 0) println();
    walk(w);
  }
  
  
  walk(64, (x, y, z, i)-> {
    println(x, y, z);
  });
  
}

// ..................................


int[] walker_index_to_xyz(int i, int x_steps, int y_steps) {

  int plane_points = x_steps * y_steps;

  int z = i / plane_points;
  i = i - (z * plane_points); // make it 2d
  int x = i % x_steps;
  int y = (i - x) / x_steps;

  if (y % 2 == 1) {
    x = x_steps - x - 1;
  }

  if (z % 2 == 1) {
    y = y_steps-y-1;
  }
  return new int[] {x, y, z};
}



ArrayList<PVector> points = new ArrayList<>();

void draw() {
  background(0);
  lights();

  //if (frameCount % 60 == 0) {
  //  walk(w);
  //}

  noStroke();
  fill(255, 255, 0);
  for (PVector v : points) {
    pushMatrix();
    translate(v.x, v.y, v.z);
    sphere(2);
    popMatrix();
  }

  stroke(255, 255, 0);
  beginShape();
  for (PVector v : points) {
    vertex(v.x, v.y, v.z);
  }
  endShape();
}



static public class XYZ_Walker {
  public int x_steps;
  public int y_steps;
  public int x;
  public int y;
  public int z;
  public int x_dir = 1;
  public int y_dir = 1;
  // public int remaining_steps_in_x;
  public int current_step_dir = 0; // x(0) or y(1)
  public XYZ_Walker(int x_steps, int y_steps) {
    this.x_steps = x_steps;
    this.y_steps = y_steps;
  }//remaining_steps_in_x=x_steps;}
}

static public void walk(XYZ_Walker w) {

  int X = 0;
  int Y = 1;

  if (w.current_step_dir == X) {
    w.x += w.x_dir;
    // prepare for next call
    if (w.x == 0 || w.x == w.x_steps-1) {
      w.current_step_dir = Y;
    }
    return;
  }
  if (w.current_step_dir == Y) {
    // test if can we move in the current y direction?
    if (w.y + w.y_dir < 0 || w.y + w.y_dir > w.y_steps-1) {
      w.z++;
      w.y_dir = -w.y_dir;
      // System.out.println();
    } else {
      w.y += w.y_dir;
      // System.out.println();
    }
    // prepare for next call
    w.current_step_dir = X;
    w.x_dir = -w.x_dir;
    return;
  }
}




interface Walk_Action {
  void perform(int x, int y, int z, int i);
}


static public void walk(int n, Walk_Action action) {

  int[] w = new int[3];

  int dim = (int) Math.ceil(Math.cbrt(n));

  int x_dir = 1;
  int y_dir = 1;

  int i = 0;
  while (i < n) {

    for (int x = 0; x < dim; x++) {
      action.perform(w[0], w[1], w[2], i);
      i++;
      w[0] += x_dir;
    }
    x_dir = -x_dir;
    w[0] += x_dir; // correct one step
    w[1] += y_dir;

    System.out.println(); // <- I recommend using this println when using a debugger to understand what is going on

    if (w[1] == dim || w[1] == -1) {
      w[1] -= y_dir; // correct one step
      y_dir = -y_dir;
      w[2]++;
    }
  }
}
