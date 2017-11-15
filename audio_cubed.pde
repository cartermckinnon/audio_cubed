import codeanticode.syphon.*;

import processing.sound.*;
import ddf.minim.*;

ArrayList<Tile> tiles; //This code is creating an array list of type circle List and is using the AudCirc class to eventually hold values for the circles
Amplitude amplitude;
// FFT frequency;
// int bands = 512;
// float spectrum[] = new float[bands];
ArrayList<SoundFile> soundfiles;
SoundFile activeSoundFile;
AudioInput in;
Minim minim;
char activeKey;
PGraphics canvas;
SyphonServer server;

void setup()
{
  amplitude = new Amplitude(this);
  // frequency = new FFT(this, bands);
  //background(255);
  size(600, 400, P3D);
  server = new SyphonServer( this, "Processing Syphon");
  canvas = createGraphics(600, 400, P3D);
  frameRate(25);
  createTiles();
  activeKey = ' ';
  stroke(0, 0);
  minim = new Minim(this);
  in = minim.getLineIn();
  // in.play();
  // frequency.input(in);
  
}

void draw() {
  canvas.beginDraw();
  canvas.smooth();
  canvas.clear();
  canvas.background(0);
  for (Tile tile : tiles)
  {
    tile.display();
  }
  if( keyPressed )
  {
    if( key != activeKey )
    {
      activeKey = key;
      handleKey();
    }
  }
  canvas.endDraw();
  image(canvas, 0, 0);
  server.sendImage(canvas);
}

void createTiles() {
  tiles = new ArrayList<Tile>();
  soundfiles = new ArrayList<SoundFile>();
  
  tiles.add(new Tile( 0,   0,   200, "1"));
  soundfiles.add( new SoundFile(this, "1.aiff" ));

  tiles.add(new Tile( 200, 0,   200, "2"));
  soundfiles.add( new SoundFile(this, "2.aiff" ));

  tiles.add(new Tile( 400, 0,   200, "3"));
  soundfiles.add( new SoundFile(this, "3.aiff" ));

  tiles.add(new Tile( 0,   200, 200, "4" ));
  soundfiles.add( new SoundFile(this, "4.aiff" ));

  tiles.add(new Tile( 200, 200, 200, "5"));
  soundfiles.add( new SoundFile(this, "5.aiff" ));

  //tiles.add(new Tile( 400, 200, 200, "b_r"));
  //soundfiles.add( new SoundFile(this, "6.aiff" ));
}

/*
Should play the Tile corresponding to the number
key pressed, and pause all other Tiles.
*/
void handleKey()
{
  println("handling key: " + key);
  if( activeSoundFile != null )
  {
    activeSoundFile.stop();
  }
  for( int i = 0; i < 5; i ++ )
  {
    char cmd = getChar(i);
    if( cmd != '?' && key == cmd )
    {
      soundfiles.get(i).loop();
      activeSoundFile = soundfiles.get(i);
      tiles.get(i).play( soundfiles.get(i), amplitude );
      println("Tile " + i + " set to active");
    }
    else
    {
      println("Tile " + i + " set to inactive");
      tiles.get(i).setInactive();
    }
  }
}

class Tile
{
  float xPos,
        yPos,
        size,
        ampValue,
        mostSize,
        partSize,
        imgSize,
        scale,
        alpha,
        r,
        g,
        b;
  color colour;
  SoundFile sound;
  Amplitude amp;
  //FFT freq;
  boolean isActive;
  String name;
  PImage img;

  Tile( float anXPos,
        float aYPos,
        int aSize,
        String aName )
  {
    xPos = anXPos;
    yPos = aYPos;
    size = aSize;
    mostSize = (.25 * size);
    partSize = size - mostSize;
    isActive = false;
    name = aName;
    sound = null;
    amp = null;
    img = loadImage(aName + ".png");
    println("Tile '" + name + "' @ " + xPos + " / " + yPos + " size: " +  size);
  }

  void play( SoundFile aSound,
             Amplitude anAmplitude )
  {
    sound = aSound;
    println("Sound: " + sound.duration());
    amp = anAmplitude;
    // freq = aFreq;
    amp.input(sound);
    // freq.input(sound);
    isActive = true;
  }

  
  void setInactive()
  {
    isActive = false;
    amp = null;
    imgSize = 0.26 * size;
    scale = 1;
    alpha = 0;
  }

  void display()
  {
    if( isActive )
    {
      display_visual();
    }
    else
    {
      display_icon();
    }
  }
  
  // Display the generative visual for the held audio track
  void display_visual()
  {
    // println("Displaying visual for tile: " + name);
    ampValue = amp.analyze();
    //freq.analyze(spectrum);
    float p = 0;
    for ( int i = 0; i < in.bufferSize(); i++ )
    {
      p += abs( in.mix.get( i ) ) * 1;
    }
    p=map(p, 0, 35, 1, 2);
    //println("P values="+p);
    r = random(0, 150);
    g = random(0, 150);
    b = random(0, 150);
    float _r = r/2.0*p;
    float _g = g/2.0*p;  
    float _b = b/2.0*p;
    //println(_r + " | " + _g + " | " + _b);
    colour = randomColor(_r, _g, _b, getColor(name));
    canvas.fill(colour);
    float curSize = mostSize + (partSize)*(1-ampValue);
    canvas.stroke(255);
    canvas.rect( xPos+((size - curSize)/2), yPos+((size - curSize)/2), curSize, curSize );
    //canvas.fill(0,0,0);
}

color randomColor(float r, float g, float b, color mix)
{
    // mix the color
    r = (r + red(mix)) / 2;
    g = (g + green(mix)) / 2;
    b = (b + blue(mix)) / 2;

    return color(r, g, b, 100);
}

color getColor(String name)
{
  switch( name )
  {
    case "1":
    return color(240, 57, 58);
    
    case "2":
        return color(252, 145, 64);
    
    case "3":
        return color(238,232, 76);
    
    case "4":
        return color(83, 143, 74);
    
    case "5":
        return color(38, 38, 163);
    
    case "6":
        return color(114, 28, 149);
  }
  return 0;
}
  
  void display_icon()
  {
    // black background
    imgSize = imgSize + scale;
    alpha = alpha + (scale * 3);
    canvas.fill(0, 0, 0);
    canvas.rect(xPos, yPos, size, size);
    canvas.tint(255, alpha);
    canvas.image(img, xPos+((size-imgSize)/2), yPos+((size-imgSize)/2), imgSize, imgSize);
    // println("Icon for '" + name + "' @ " + xPos +" " + yPos + " " + imgSize);
    if( imgSize >= (0.5 * size) || imgSize <= (0.25 * size) )
    {
        scale = scale * -1;
    }
  }
}

/* Helper function: translate a loop index to a character from keyPressed */
char getChar( int i )
{
  switch( i )
  {
  case 0:
    return 'w';

  case 1:
    return 'a';

  case 2:
    return 's';

  case 3:
    return 'd';

  case 4:
    return 'f';

  case 5:
    return '6';

  default:
    return '?';
  }
}