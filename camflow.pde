import ch.bildspur.realsense.*;
import gab.opencv.*;
import java.awt.*;
import org.librealsense.*;

int minDepth = 200;
int maxDepth = 2000;

int imgWidth = 848;
int imgHeight = 480;

RealSenseCamera camera = new RealSenseCamera(this);
OpenCV opencv;

PGraphics outMask;
PShader   blur; 
PGraphics pass1, pass2;

int depthMask[];
int calbrationCount = 0;
int minFound = maxDepth;

void setup() {
  fullScreen(P2D);  
  
  blur = loadShader("blur.glsl");
  blur.set("blurSize", 9);
  blur.set("sigma", 5.0f); 
   
  pass1 = createGraphics(width ,height, P2D);
  pass2 = createGraphics(width ,height, P2D);

  //size(640, 480);

  //noSmooth();
  //DeviceList deviceList = this.context.queryDevices();
  
  // width, height, fps, depth-stream, color-stream
  camera.start(imgWidth, imgHeight, 30, true, true);
  opencv = new OpenCV(this, imgWidth, imgHeight); 
  outMask = createGraphics(imgWidth, imgHeight, P2D);

  depthMask = new int[imgWidth * imgHeight];
  for(int i = 0; i < depthMask.length; ++i) {
    depthMask[i] = maxDepth;
  }
  
  setupLife();
}

boolean calibrateDepth() {
  boolean okay = true;
  for (int y=0; y < imgHeight; y++) {
    for (int x=0; x < imgWidth; x++) {
      int depth = camera.getDepth(x, y);
      int pos = y * imgWidth + x;
      if(depth < depthMask[pos]) {
        depthMask[pos] = depth - 1;
        okay = false;
        minFound = min(minFound, depth);
      }
    }
  }
  return okay;
}

void draw() {
  
  background(0);
  
  camera.readFrames();
  if(calbrationCount > 0) {
    calibrateDepth();
    --calbrationCount;
  }
  PImage colorImg = camera.getColorImage();
  camera.createDepthImage(minDepth, maxDepth);
  PImage dp = camera.getDepthImage();
  opencv.loadImage(dp);
  opencv.threshold(2);
  opencv.erode();
  opencv.erode();
  opencv.findSobelEdges(1,1);
  opencv.flip(OpenCV.HORIZONTAL);
  fillFromImage(opencv.getOutput());
  drawLife();
  
  if(frameCount % 60 == 0)
    println(frameRate);
}

void blurImage(PImage src) {
  // Applying the blur shader along the vertical direction   
  blur.set("horizontalPass", 0);
  pass1.beginDraw();            
  pass1.shader(blur);  
  pass1.image(src, 0, 0, width, height);
  pass1.endDraw();
  
  // Applying the blur shader along the horizontal direction      
  blur.set("horizontalPass", 1);
  pass2.beginDraw();            
  pass2.shader(blur);  
  pass2.image(pass1, 0, 0);
  pass2.endDraw();    
        
  image(pass2, 0, 0, width, height);   
}


// Handle keyboard input

void keyPressed() {
  
  if (key==' ') { // On/off of pause
    pause = !pause;
  }
  if(key == 'c' || key == 'C') {
    calbrationCount = 5;
  }
}
