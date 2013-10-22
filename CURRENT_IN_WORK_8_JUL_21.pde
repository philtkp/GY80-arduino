/*************************************************************************************
* This started out as the AHRS v1.41 and modified for the GY-80
* This is a learning leasson in progress.
*
* Test Sketch for Razor AHRS v1.4.1
* 9 Degree of Measurement Attitude and Heading Reference System
* for Sparkfun "9DOF Razor IMU" and "9DOF Sensor Stick"
*
* Released under GNU GPL (General Public License) v3.0
* Copyright (C) 2011-2012 Quality & Usability Lab, Deutsche Telekom Laboratories, TU Berlin
* Written by Peter Bartz (peter-bartz@gmx.de)
*
* Infos, updates, bug reports and feedback:
*     http://dev.qu.tu-berlin.de/projects/sf-razor-9dof-ahrs
*************************************************************************************/

/*
  NOTE: There seems to be a bug with the serial library in the latest Processing
  versions 1.5 and 1.5.1: "WARNING: RXTX Version mismatch ...". The previous version
  1.2.1 works fine and is still available on the web.
*/

import processing.opengl.*;
import processing.serial.*;

// IF THE SKETCH CRASHES OR HANGS ON STARTUP, MAKE SURE YOU ARE USING THE RIGHT SERIAL PORT:
// 1. Have a look at the Processing console output of this sketch.
// 2. Look for the serial port list and find the port you need (it's the same as in Arduino).
// 3. Set your port number here:
final static int SERIAL_PORT_NUM = 0;
// 4. Try again.


final static int SERIAL_PORT_BAUD_RATE = 57600;

float yaw = 0.0f;
float pitch = 0.0f;
float roll = 0.0f;
float yawOffset = 0.0f;
float SpanAngle=120;

int yawDeg = 0;
int NumberOfScaleMajorDivisions;
int NumberOfScaleMinorDivisions;

PFont font;
Serial serial;

boolean synched = false;

/**********************************************************/
/* Draw roll indicator                                    */
/**********************************************************/
void drawRoll() {
   
   pushMatrix();
     noStroke();
  
     fill(108, 156, 255); // Fill sky color
     ellipse(0, 100, 220, 220);
     textSize(20);
   
     fill(255);
     textAlign(LEFT);
     text("Roll: " + ((int) roll)+" Deg", -60, 275);  
   
     translate(0, 100);
    
     pushMatrix();
       rotate(HALF_PI);
       SpanAngle=180;
       NumberOfScaleMinorDivisions=36;  
       CircularScale(); 
     popMatrix();
  
     rotate(-radians((int)roll));
   
     noStroke();
     fill(208, 119, 0);  // Fill ground color
     arc(0, 0, 220, 220, -0, HALF_PI+HALF_PI, CHORD);
     
     pushMatrix();
    
       PitchScale();
       Axis();
   
       stroke(255);
       strokeWeight(3);
       noFill();
       ellipse(0, 0, 217, 217);
   
     popMatrix();
 
   popMatrix();

 }
/**********************************************************/
/* Draw Pitch indicator                                   */
/**********************************************************/
 void drawPitch() {
   
   pushMatrix();
     noStroke();
     translate(300, 100);
   
     fill(108, 156, 255); // Fill sky color
     ellipse(0, 0, 220, 220);
   
     translate(0, 0);
   
     fill(208, 119, 0);  // Fill ground color
     beginShape();
       vertex(-121, 121);
       vertex(121, 121);
       vertex(121, (int)pitch);
       vertex(-121, (int)pitch);
     endShape(CLOSE);
    
     pushMatrix();
       stroke(0,0,0);
       strokeWeight(45);
       noFill();
      
       ellipse(0, 0, 265, 265);
       fill(0);
       quad(100,100,145,100,145,145,100,145);
       quad(-100,100,-145,100,-145,145,-100,145);
     popMatrix();
     
     pushMatrix();
       rotate(HALF_PI);
       SpanAngle=180;
       NumberOfScaleMajorDivisions=18;
       NumberOfScaleMinorDivisions=36;  
       
       CircularScale(); 
     popMatrix();   
  
    PitchScale();
    Axis();
     
    stroke(255);
    strokeWeight(3);
    noFill();
     
    ellipse(0, 0, 217, 217);
  popMatrix();
     
  
  textSize(20);
  fill(255,255,255);
  textAlign(LEFT);
  text("Pitch: " + ((int) pitch)+" Deg", 230, 275); 
 }
 
/**********************************************************/
/* Draw Yaw/Compass indicator                             */
/**********************************************************/
void drawYaw() {
  
 pushMatrix(); 
  
   noStroke();
   fill(108, 156, 255); // Fill sky color
   ellipse(-300, 100, 220, 220);
  
   if((int)yaw >= 1 && (int)yaw <= 180)
     yawDeg = (int)yaw;
   else yawDeg = 360 + (int)yaw;
  
   textSize(20);
   fill(255,255,255);
   textAlign(LEFT);
   text("Heading: " + (int) +yawDeg+" Deg", -390, 275);  
  
   translate(-300, 100);   
  
   CompassPointer(); 
  
 popMatrix();
 pushMatrix();
  /* Draws the circular scale on compass */
   translate(-300, 100); 
  
   stroke(255);
   strokeWeight(3);
   noFill();
   ellipse(0, 0, 215, 215);
   
   SpanAngle=180;
   NumberOfScaleMajorDivisions=18;
   NumberOfScaleMinorDivisions=36;  
   CircularScale(); 
   rotate(PI);
   SpanAngle=180;  
  
   CircularScale();
   rotate(-PI);
   
   translate(-300, 100);
   textSize(20);
   fill(255,255,255);
   textAlign(CENTER);
   text("W", 165, -92);
   text("E", 430, -92);
   text("N", 300, -224);
   text("S", 300, 42);
   rotate(PI/4);
   textSize(15);
   text("NW",-0, -280);
   text("SE",  275, -280);
  popMatrix();
  rotate(-PI/4);
  
  text("NE", -145, -135);
  text("SW",-420, -135);
  
 }
/***************************************************/
/* Draws the compass pointer                       */
/***************************************************/ 
 void CompassPointer()
{
  rotate(radians(yaw));  
  stroke(0);
  strokeWeight(2);
  fill(255,255,255);
  
  beginShape();
    vertex(0,-105);
    vertex(12, 100);
    vertex(0, 80);
    vertex(-12, 100);
  endShape(CLOSE);
  
  ellipse(0, 0, 9, 9);  
  ellipse(0, 0, 3, 3); 
}

/***************************************************/
/* Draw the pitch scale                            */
/***************************************************/
void PitchScale()
{  
  stroke(255);
  fill(255);
  strokeWeight(2);
  textSize(15);
  //textAlign(CENTER);
  for (int i=-4;i<5;i++)
  {  
    if ((i==0)==false)
    {
      line(40, 20*i, -40, 20*i);
    }  
   
  }
  //textAlign(CORNER);
  strokeWeight(2);
  for (int i=-9;i<10;i++)
  {  
    if ((i==0)==false)
    {    
      line(20, 10*i, -20, 10*i);
    }
  }
  pushMatrix();
    text("0",48,5);
    text("0",-58,5);
    text("20",45,25);
    text("20",-63,25);
    text("-20",45,-15);
    text("-20",-68,-15);
    text("40",45,45);
    text("40",-63,45);
    text("-40",45,-35);
    text("-40",-68,-35);
    text("60",45,65);
    text("60",-63,65);
    text("-60",45,-55);
    text("-60",-68,-55);
    text("80",45,85);
    text("80",-63,85);
    text("-80",45,-75);
    text("-80",-68,-75);
  popMatrix();
  
}
/***************************************************/
/* Draw red axis lines                             */
/***************************************************/
void Axis()
{
  stroke(255, 0, 0);
  strokeWeight(2);
  line(-45, 0, 45, 0);
  line(0, 90, 0, -90);
  fill(100, 255, 100);
  stroke(0);
  strokeWeight(1);
  triangle(0, -107, -6, -90, 6, -90);
  triangle(0, 107, -6, 90, 6, 90);
} 
/********************************************************/
/*    Draw cirular scale                                */
/* Code from Adrian Fernandez 4-19-2013                 */
/********************************************************/
void CircularScale()
{
  float GaugeWidth=304;  
  textSize(GaugeWidth/20);
  float StrokeWidth=1;
  float an;
  float DivxPhasorCloser;
  float DivxPhasorDistal;
  float DivyPhasorCloser;
  float DivyPhasorDistal;
  strokeWeight(2*StrokeWidth);
  stroke(255);
  noFill();
   

  float DivCloserPhasorLenght=GaugeWidth/2-GaugeWidth/9-StrokeWidth;
  float DivDistalPhasorLenght=GaugeWidth/2-GaugeWidth/7.5-StrokeWidth;

  for (int Division=0;Division<NumberOfScaleMinorDivisions+1;Division++)
  {
    an=SpanAngle/2+Division*SpanAngle/NumberOfScaleMinorDivisions;  
    DivxPhasorCloser=DivCloserPhasorLenght*cos(radians(an));
    DivxPhasorDistal=DivDistalPhasorLenght*cos(radians(an));
    DivyPhasorCloser=DivCloserPhasorLenght*sin(radians(an));
    DivyPhasorDistal=DivDistalPhasorLenght*sin(radians(an));  
     
    line(DivxPhasorCloser, DivyPhasorCloser, DivxPhasorDistal, DivyPhasorDistal);
  }

  DivCloserPhasorLenght=GaugeWidth/2-GaugeWidth/10-StrokeWidth;
  DivDistalPhasorLenght=GaugeWidth/2-GaugeWidth/7.4-StrokeWidth;

  for (int Division=0;Division<NumberOfScaleMajorDivisions+1;Division++)
  {
    an=SpanAngle/2+Division*SpanAngle/NumberOfScaleMajorDivisions;  
    DivxPhasorCloser=DivCloserPhasorLenght*cos(radians(an));
    DivxPhasorDistal=DivDistalPhasorLenght*cos(radians(an));
    DivyPhasorCloser=DivCloserPhasorLenght*sin(radians(an));
    DivyPhasorDistal=DivDistalPhasorLenght*sin(radians(an));
    if (Division==NumberOfScaleMajorDivisions/2|Division==0|Division==NumberOfScaleMajorDivisions)
    {
      strokeWeight(5);
      stroke(255);
      
      line(DivxPhasorCloser, DivyPhasorCloser, DivxPhasorDistal, DivyPhasorDistal);
      strokeWeight(3);
      stroke(100, 255, 100);
      
      line(DivxPhasorCloser, DivyPhasorCloser, DivxPhasorDistal, DivyPhasorDistal);
    }
    else
    {
      strokeWeight(3);
      stroke(255);
      line(DivxPhasorCloser, DivyPhasorCloser, DivxPhasorDistal, DivyPhasorDistal);
    }
  }
}
/*********************************************************/
/*  Setup cube                        a                   */
/*********************************************************/
void drawCube() {  
  pushMatrix();
    
    translate(500, 600, 0);
    //scale(4,4,4);
    
    rotateY(-radians(yaw - yawOffset));
    rotateX(-radians(pitch));
    rotateZ(radians(roll)); 
    
    buildBoxShape(); 
  
  popMatrix();
}
/*********************************************************/
/*  build cube                                           */
/*********************************************************/
void buildBoxShape() {
  //box(60, 10, 40);
  pushMatrix();
  
  translate(0, 0, 0);
  noStroke();
  beginShape(QUADS);
  
  //Z+ (to the drawing area)
  fill(#00ff00);
  vertex(-60, -10, 100);
  vertex(60, -10, 100);
  vertex(60, 10, 100);
  vertex(-60, 10, 100);
  
  //Z-
  fill(#0000ff);
  vertex(-60, -10, -100);
  vertex(60, -10, -100);
  vertex(60, 10, -100);
  vertex(-60, 10, -100);
  
  //X-
  fill(#ff0000);
  vertex(-60, -10, -100);
  vertex(-60, -10, 100);
  vertex(-60, 10, 100);
  vertex(-60, 10, -100);
  
  //X+
  fill(#ffff00);
  vertex(60, -10, -100);
  vertex(60, -10, 100);
  vertex(60, 10, 100);
  vertex(60, 10, -100);
  
  //Y-
  fill(#ff00ff);
  vertex(-60, -10, -100);
  vertex(60, -10, -100);
  vertex(60, -10, 100);
  vertex(-60, -10, 100);
  
  //Y+
  fill(#00ffff);
  vertex(-60, 10, -100);
  vertex(60, 10, -100);
  vertex(60, 10, 100);
  vertex(-60, 10, 100);
  
  endShape();
  
  // Draw base
  translate(0, 0, -115);
  fill(#FF8400);
  box(30, 20, 30);
  // Draw pointer
 
  beginShape(QUAD_STRIP);
   vertex(-40, -10 ,-10);
   vertex(40, -10, -10);
   vertex(-40, 10 ,-10);
   vertex(40, 10, -10);
   
   vertex(40, -10, -10);
   vertex(0,-10, -50);
   vertex(0, 10 ,-50);
   vertex(40, 10, -10);
   
   vertex(-40, -10, -10);
   vertex(0,-10, -50);
   vertex(0, 10 ,-50);
   vertex(-40, 10, -10);
  endShape();
  beginShape(TRIANGLES);
    vertex(-40, -10, -10);
    vertex(40, -10, -10);
    vertex(0, -10, -50);
    vertex(-40, 10, -10);
   vertex(40, 10, -10);
   vertex(0, 10, -50);
  endShape();
  
  popMatrix();
}

/*********************************************************/
/*                                                       */
/*********************************************************/
// Skip incoming serial stream data until token is found
boolean readToken(Serial serial, String token) {
  // Wait until enough bytes are available
  if (serial.available() < token.length())
    return false;
  
  // Check if incoming bytes match token
  for (int i = 0; i < token.length(); i++) {
    if (serial.read() != token.charAt(i))
      return false;
  }
  
  return true;
}

// Global setup
void setup() {
  // Setup graphics
  size(1000, 800, OPENGL);
  
  noStroke();
  frameRate(50);
  
  //Load font
  font = loadFont("Univers-66.vlw");
  textFont(font);
  
  // Setup serial port I/O
  println("AVAILABLE SERIAL PORTS:");
  println(Serial.list());
  String portName = Serial.list()[SERIAL_PORT_NUM];
  println();
  println("HAVE A LOOK AT THE LIST ABOVE AND SET THE RIGHT SERIAL PORT NUMBER IN THE CODE!");
  println("  -> Using port " + SERIAL_PORT_NUM + ": " + portName);
  serial = new Serial(this, portName, SERIAL_PORT_BAUD_RATE);
}

void setupRazor() {
  println("Trying to setup and synch Device...");
  
  // On Mac OSX and Linux (Windows too?) the board will do a reset when we connect, which is really bad.
  // See "Automatic (Software) Reset" on http://www.arduino.cc/en/Main/ArduinoBoardProMini
  // So we have to wait until the bootloader is finished and the Razor firmware can receive commands.
  // To prevent this, disconnect/cut/unplug the DTR line going to the board. This also has the advantage,
  // that the angles you receive are stable right from the beginning. 
  delay(3000);  // 3 seconds should be enough
  
  // Set Razor output parameters
  serial.write("#ob");  // Turn on binary output
  serial.write("#o1");  // Turn on continuous streaming output
  serial.write("#oe0"); // Disable error message output
  
  // Synch with Razor
  serial.clear();  // Clear input buffer up to here
  serial.write("#s00");  // Request synch token
}

float readFloat(Serial s) {
  // Convert from little endian (Razor) to big endian (Java) and interpret as float
  return Float.intBitsToFloat(s.read() + (s.read() << 8) + (s.read() << 16) + (s.read() << 24));
}

void draw() {
  // Reset scene
  background(0);
  // lights();

  // Sync with Razor 
  if (!synched) {
    textAlign(CENTER);
    //textSize(25);
    fill(255);
    text("Connecting to Device...", width/2, height/2, -200);
    
    if (frameCount == 2)
      setupRazor();  // Set ouput params and request synch token
   else if (frameCount > 2)
     synched = readToken(serial, "#SYNCH00\r\n");  // Look for synch token
    return;
  }
  
  // Read angles from serial port
  while (serial.available() >= 12) {
    yaw = readFloat(serial);
    pitch = readFloat(serial);
    roll = readFloat(serial);
  }

  // Draw Roll
   pushMatrix();
   translate(width/2, 50);
   drawRoll();
   drawPitch();
   drawYaw();
   popMatrix();
   
   
   drawCube();
   
  textSize(20);
  fill(255);
  textAlign(LEFT);

  // Output info text
 // text("Working on the Yaw indicator", 10, 25);

  // Output angles
  pushMatrix();
  translate(200,600);
  textAlign(LEFT);
  text("Yaw: " + ((int) yaw), 0, -40);
  text("Pitch: " + ((int) pitch), 0, 0);
  text("Roll: " + ((int) roll), 0, 40);
  popMatrix();
}

void keyPressed() {
  switch (key) {
    case '0':  // Turn Razor's continuous output stream off
      serial.write("#o0");
      break;
    case '1':  // Turn Razor's continuous output stream on
      serial.write("#o1");
      break;
    case 'f':  // Request one single yaw/pitch/roll frame from Razor (use when continuous streaming is off)
      serial.write("#f");
      break;
    case 'a':  // Align screen with Razor
      yawOffset = yaw;
  }
}



