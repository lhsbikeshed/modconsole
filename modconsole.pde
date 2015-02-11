import processing.video.*;

import processing.serial.*;

import controlP5.*;
import java.awt.Point;
import oscP5.*;
import netP5.*;


//change these
boolean serialEnabled = false;
boolean useXboxController = false;
//BUT NOTHING PAST HERE

OscP5 oscP5;
ControlP5 cp5;

PFont font;

NetAddress myRemoteLocation;                            
String serverIP = "127.0.0.1";                           
//PanelSet[] displayList = new PanelSet[0];

HashMap<String, PanelSet> displayList = new HashMap<String, PanelSet>();


RadarPanel radarPanel;
String currentTab = "launch";
boolean ready = false;
float hull = 100;

Serial serialPort;

String[] tabList = { 
  "Launch", "Hyperspace", "Drop Scene", "Warzone Scene", "Landing", "Dead", "Comet"
};
ShipStatePanel sPanel;

JoyPanel jp;
public boolean joystickEnabled = false;
Joystick joy;

//video playing stuff for comms
FixedMovie movie;
long movieTimer = 0;
boolean waitingForMovieStart = false;

void setup() {   
  size(1024, 900, P3D);

  jp = new JoyPanel(500, 390, 200, 200);

  frameRate(25);
  if (serialEnabled) {
    serialPort = new Serial(this, "COM36", 9600);
  }

  cp5 = new ControlP5(this);
  oscP5 = new OscP5(this, 12005);
  myRemoteLocation = new NetAddress(serverIP, 12000);

  font = loadFont("HanzelExtendedNormal-48.vlw");

  sPanel = new ShipStatePanel("shipstate", this, oscP5, cp5 );
  sPanel.initGui();
  radarPanel = new RadarPanel();
  setupTabs();
  ready = true;
  delay(500);
  if (serialEnabled) {
    setLightState(true);
    setLightMode(3);
  }

  joy = new Joystick(oscP5, this, !useXboxController);
  joy.setEnabled(false);
}


void setupTabs() {  
  PanelSet p1 = new LaunchControl(tabList[0], this, oscP5, cp5);
  PanelSet p2  = new HyperControls(tabList[1], this, oscP5, cp5);
  PanelSet p3  = new DropControls(tabList[2], this, oscP5, cp5);
  PanelSet p4  = new WarzoneControls(tabList[3], this, oscP5, cp5);
  PanelSet p5  = new LandingControls(tabList[4], this, oscP5, cp5);
  PanelSet p6  = new DeadControls(tabList[5], this, oscP5, cp5);
  PanelSet p7  = new CometControls(tabList[6], this, oscP5, cp5);
  PanelSet p8  = new PreloadControls("boarding", this, oscP5, cp5);

  displayList.put(p1.sceneTag, p1);
  displayList.put(p2.sceneTag, p2);
  displayList.put(p3.sceneTag, p3);
  displayList.put(p4.sceneTag, p4);
  displayList.put(p5.sceneTag, p5);
  displayList.put(p6.sceneTag, p6);
  displayList.put(p7.sceneTag, p7);
    displayList.put(p8.sceneTag, p8);


  int i = 0;
  for (String key : displayList.keySet()) {
    
    PanelSet p = displayList.get(key);
    println("setting up tag:" + p.sceneTag);
    cp5.addTab(p.sceneTag)
      .setColorBackground(color(0, 160, 100))
        .setColorLabel(color(255))
          .setColorActive(color(255, 128, 0))
            .activateEvent(true)
            .setLabel(p.getName())
            .setId(i);
            

    p.initGui();
    i++;
  }

  cp5.getTab("default").setAlwaysActive( true);
}


void controlEvent(ControlEvent theControlEvent) {
  if (!ready) {
    return;
  }
  if (theControlEvent.isTab()) {
    currentTab = theControlEvent.getTab().getName();
  } 
  else {
    displayList.get(currentTab).controlEvent(theControlEvent);
    sPanel.controlEvent(theControlEvent);
  }
}

void draw() {
  background(0, 0, 0);
  textFont(font, 30);
  text(displayList.get(currentTab).name, 700, 40);

  stroke(255, 255, 255);
  line (0, 380, width, 380);
  PanelSet p = displayList.get(currentTab);
  if(p != null){
    p.draw();
  }
  sPanel.draw();
  // radarPanel.draw();

  jp.draw();
  if (movie != null) {

    if (movie.isPlaying() == false && movieTimer + 2000 < millis() && waitingForMovieStart ) {
      movie.play();
      waitingForMovieStart = false;
    }
    if (movie.available()) {
      movie.read();
    }
  }
}

void oscEvent(OscMessage theOscMessage) {
  if (!ready) { 
    return;
  }
  // println(theOscMessage);
  if (theOscMessage.checkAddrPattern("/scene/change")==true) {
    String val = theOscMessage.get(0).stringValue();

    PanelSet p = displayList.get(val);
    if(p != null){
      displayList.get(currentTab).reset();
      currentTab = val;
      cp5.getTab(displayList.get(currentTab).sceneTag).bringToFront();
    }

    if (val.equals("drop")) { //  char[] lightMap = {'i', 'w', 'r', 'b'};

      setLightMode(2);
    } 
    else if (val.equals("warzone-landing")) {
      setLightMode(0);
    } 
    else if (val.equals("hyper1")) {
      setLightMode(1);
    } 
    else if (val.equals( "preload")) {
      lightReset();
    } 
    else if (val.equals("landing")) {
      setLightMode(0);
    } 
    else {
      setLightMode(0);
    }

    return;
  }
  else if (theOscMessage.checkAddrPattern("/system/reactor/stateUpdate")==true) {
    int s = theOscMessage.get(0).intValue();
    if (s == 0) {
      sPanel.reactorState = false;
      setLightState(false);
    } 
    else {
      sPanel.reactorState = true;
      setLightState(true);
    }
  } 
  else if (theOscMessage.checkAddrPattern("/ship/undercarriage/contact") == true) {
    sPanel.canClampBeEnabled = theOscMessage.get(0).intValue() == 1 ? true : false;
  }
  else if (theOscMessage.checkAddrPattern("/scene/youaredead") == true) {
    serialPort.write('k');
  } 
  else if (theOscMessage.checkAddrPattern("/game/reset") == true) {
    //reset the entire game
    resetScreens();
  } 
  else if (theOscMessage.checkAddrPattern("/radar/update") == true) {
    radarPanel.oscMessage(theOscMessage);
  }
  else if (theOscMessage.checkAddrPattern("/ship/damage") == true) {

    lightDamage();
  }
  else if (theOscMessage.checkAddrPattern("/ship/effect/heartbeat") == true) {

    lightHeartBeat();
  }
  else if (theOscMessage.checkAddrPattern("/ship/jumpStatus") == true) {  
    boolean a = theOscMessage.get(0).intValue() == 1 ? true : false;
    sPanel.canJump = a;
  } 
  else if (theOscMessage.checkAddrPattern("/ship/stats") == true) {  


    float newHull = theOscMessage.get(2).floatValue();
    if (newHull < 10 && hull <= 10) {
      setLightMode(2);
    } 
    else if (newHull > 10 && hull <= 10) {
      setLightMode(0);
    }
    hull = newHull;
    sPanel.hull = hull;
    sPanel.jumpCharge = theOscMessage.get(0).floatValue() * 100.0;
    sPanel.oxygenLevel = theOscMessage.get(1).floatValue();
  } 
  else if (theOscMessage.checkAddrPattern("/system/powerManagement/failureCount")) {
    sPanel.failureCount = theOscMessage.get(0).intValue();
  } 
  else if (theOscMessage.checkAddrPattern("/ship/undercarriage")) {
    sPanel.undercarriageState = theOscMessage.get(0).intValue();
  } 
  else if (theOscMessage.checkAddrPattern("/system/control/controlState") ) {
    int state = theOscMessage.get(0).intValue();


    if (state == 1) {
      println("turning stick on");
      joy.setEnabled(true);
    } 
    else {
      println("Stick off");
      joy.setEnabled(false);
    }
  } 
  else if (theOscMessage.checkAddrPattern("/system/effect/lightingMode")) {
    int mode = theOscMessage.get(0).intValue();
    setLightMode(mode);
  } 
  else if (theOscMessage.checkAddrPattern("/system/effect/lightingPower")) {
    int mode = theOscMessage.get(0).intValue();
    setLightState(mode == 1 ? true : false);
    println("light");
  }
  else if (theOscMessage.checkAddrPattern("/system/effect/seatbeltLight")) {
    int mode = theOscMessage.get(0).intValue();

    if (serialEnabled) {
      if (mode == 1) {
        serialPort.write('S');
      } 
      else {
        serialPort.write('s');
      }
    }
  }
  else if (theOscMessage.checkAddrPattern("/system/effect/prayLight")) {
    int mode = theOscMessage.get(0).intValue();
    if (serialEnabled) {
      if (mode == 1) {
        serialPort.write('P');
      } 
      else {
        serialPort.write('p');
      }
    }
  } 
  else if (theOscMessage.checkAddrPattern("/system/effect/airlockLight")) {
    int m = theOscMessage.get(0).intValue();
    if (serialEnabled) {
      if (m == 1) {
        serialPort.write("A");
      } 
      else {
        serialPort.write("a");
      }
    }
  }  
  else if (theOscMessage.checkAddrPattern("/ship/comms/hangupCall")) {
    // stop any playing videos
    if (movie!=null) {
      println("stopping movie");
      movie.stop();
      waitingForMovieStart = false;
    }
  } 
  else if (theOscMessage.checkAddrPattern("/clientscreen/CommsStation/playVideo")) {
    String file = theOscMessage.get(0).stringValue();
    println("preparing for video " + file);
    movie = new FixedMovie(this, file);
  }
  else if (theOscMessage.checkAddrPattern("/ship/comms/incomingCall")) {
    println("playing pre-prepared video");
    if (movie != null) {
      movieTimer = millis();
      waitingForMovieStart = true;
    }
  }   
  else {
    displayList.get(currentTab).oscMessage(theOscMessage);
  }
  if (sPanel != null) {
    sPanel.oscMessage(theOscMessage);
  }
}

void lightDamage() {
  if (serialEnabled) {
    serialPort.write('d');
  }
}
void lightHeartBeat() {
  if (serialEnabled) {
    serialPort.write('h');
  }
}

void setLightState(boolean state) {
  if (serialEnabled) {
    if (state == true) {
      serialPort.write('o');
    } 
    else {
      serialPort.write('k');
    }
  } 
  else {
    println("Setting lights to: " + state);
  }
}

void lightReset() {
  if (serialEnabled) {
    serialPort.write('R');
  }
}

void setLightMode(int mode) {
  char[] lightMap = {
    'i', 'w', 'r', 'b'
  };

  if (serialEnabled) {
    if (mode >= 0 && mode < lightMap.length) {
      serialPort.write(lightMap[mode]);
    }
  }  
  else {
    println("Setting light to : " + lightMap[mode]);
  }
}

void mouseClicked() {
  println (":" + mouseX + "," + mouseY);
}

void keyPressed() {
  jp.keyPressed(key);
}

void keyReleased() {
  jp.keyReleased(key);
}

void resetScreens() {
  for (String key : displayList.keySet()) {
    
    displayList.get(key).reset();
  }
}

/* change this scene to show the altitude and predicted death time*/
public abstract class PanelSet {

  PApplet parent;
  OscP5 oscP5;
  ControlP5 cp5;
  String name;
  public String sceneTag = "";

  public PanelSet(String name, PApplet parent, OscP5 p5, ControlP5 cp5) {
    this.parent = parent;
    this.oscP5 = p5;
    this.name = name;
    this.cp5 = cp5;
  }
  
  public String getName(){
    return name;
  }

  public void reset() {
  }
  public void initGui() {
  }
  public void draw() {
  }
  public void oscMessage(OscMessage msg) {
  }
  public void controlEvent(ControlEvent theControlEvent) {
  }
}

