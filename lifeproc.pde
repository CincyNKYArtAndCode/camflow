
// How likely for a cell to be alive at start (in percentage)
float probabilityOfAliveAtStart = 15;

// Variables for timer
int interval = 100;
int lastRecordedTime = 0;

// Colors for active/inactive cells
color alive = color(0, 200, 0);
color dead = color(0);

// Array of cells
int[][] cells; 
// Buffer to record the state of the cells and use this while changing the others in the interations
int[][] cellsBuffer; 

PImage disp;

// Pause
boolean pause = false;

color armstrongColors[] = {
  color(0, 0, 0, 0),
  color(37, 30, 48, 255),
  color(2, 48, 123, 255),
  color(86, 37, 56, 255),
  color(0, 107, 117, 255),
  color(118, 41, 51, 255),
  color(0, 54, 135, 255),
  color(104, 51, 139, 255),
  color(23, 238, 126, 255),
  color(232, 38, 35, 255),
  color(108, 63, 123, 255),
  color(247, 213, 159, 255),
  color(4, 175, 211, 255),
  color(250, 90, 6, 255),
  color(101, 213, 85, 255),
  color(247, 193, 218, 255),
  color(255, 214, 5, 255),
  color(150, 62, 112, 255)
};

void setupLife() {

  // Instantiate arrays 
  cells = new int[imgWidth][imgHeight];
  cellsBuffer = new int[imgWidth][imgHeight];

  // This stroke will draw the background grid
  stroke(48);

  // Initialization of cells
  for (int x=0; x<imgWidth; x++) {
    for (int y=0; y<imgHeight; y++) {
      cells[x][y] = 0; // Save state of each cell
    }
  }
  
  disp = createImage(imgWidth, imgHeight, ARGB);
  background(0); // Fill in black in case cells don't cover all the windows
}



void drawLife() {
  disp.loadPixels();
  for (int x = 0; x < imgWidth; x++) {
    for (int y = 0; y < imgHeight; y++) {
      int pos = y * imgWidth + x;
      disp.pixels[pos] = armstrongColors[cells[x][y]];
    }
  }
  disp.updatePixels();
  blurImage(disp);
  //image(disp, 0, 0, width, height);
  // Iterate if timer ticks
  if (millis()-lastRecordedTime>interval) {
    if (!pause) {
      iteration();
      lastRecordedTime = millis();
    }
  }
}

void fillFromImage(PImage img) {
  //img.loadPixels();
  for (int x=0; x<imgWidth; x++) {
    for (int y=0; y<imgHeight; y++) {
      int pos = y * img.width + x;
      color c = img.pixels[pos];
      if(red(c) > 48)
        cells[x][y] = 17; //<>//
    }
  }
  //img.updatePixels();
  
}

void iteration() { // When the clock ticks
  // Save cells to buffer (so we opeate with one array keeping the other intact)
  for (int x=0; x<imgWidth; x++) {
    for (int y=0; y<imgHeight; y++) {
      cellsBuffer[x][y] = max(0, cells[x][y] - 1);
    }
  }

  // Visit each cell:
  for (int x=0; x<imgWidth; x++) {
    for (int y=0; y<imgHeight; y++) {
      if(cellsBuffer[x][y] == 0) {
        // And visit all the neighbours of each cell
        int maxNeighbour = 0; // We'll count the neighbours
        for (int xx=x-1; xx<=x+1;xx++) {
          for (int yy=y-1; yy<=y+1;yy++) {  
            if (((xx>=0)&&(xx<imgWidth))&&((yy>=0)&&(yy<imgHeight))) { // Make sure you are not out of bounds
              if (!((xx==x)&&(yy==y))) { // Make sure to to check against self
                maxNeighbour = max(maxNeighbour, cellsBuffer[xx][yy]);
              } // End of if
            } // End of if
          } // End of yy loop
        } //End of xx loop
        cells[x][y] = max(0, maxNeighbour - 1);
      }
      else {
        cells[x][y] = cellsBuffer[x][y];
      }
    } // End of y loop
  } // End of x loop
} // End of function
